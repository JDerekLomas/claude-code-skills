#!/bin/bash
# Supervise a cmux pane by reading its screen on an interval and emitting ONE
# stdout line whenever its state changes: NEEDS-INPUT, ERROR, DONE (returned to
# a shell prompt), or ACTIVE (producing output again). Each transition also
# fires a cmux tab ring + macOS notification.
#
# Emitting on stdout means this composes with Claude Code's Monitor tool: run it
# under Monitor and every transition becomes a chat event, so an orchestrating
# Claude can PushNotification the user on NEEDS-INPUT / ERROR.
#
# usage: watch.sh --surface surface:3 [--label "OCR batch"] [--interval 5]
#                 [--workspace workspace:2] [--idle-ticks 2]
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$HERE/lib.sh"

SURFACE=""; WORKSPACE=""; LABEL=""; INTERVAL=5; IDLE_TICKS=2
while [ $# -gt 0 ]; do case "$1" in
  --surface) SURFACE="$2"; shift 2;;
  --workspace) WORKSPACE="$2"; shift 2;;
  --label) LABEL="$2"; shift 2;;
  --interval) INTERVAL="$2"; shift 2;;
  --idle-ticks) IDLE_TICKS="$2"; shift 2;;
  *) die "unknown arg: $1";;
esac; done
[ -n "$SURFACE" ] || die "need --surface (see: cmux --json list-pane-surfaces)"
[ -n "$LABEL" ] || LABEL="$SURFACE"
cmux_up || die "socket not answering (is cmux running / access allowed?)"

wsflag=(); [ -n "$WORKSPACE" ] && wsflag=(--workspace "$WORKSPACE")

# Patterns. NEEDS-INPUT = genuinely waiting on a human (not "esc to interrupt",
# which means a Claude pane is busy). ERROR is only trusted on freshly-changed
# output so a static banner can't pin the state.
NEEDS_RE='\(y/n\)|\[y/N\]|\[Y/n\]|Do you want|Continue\?|Proceed\?|Overwrite\?|password:|Password:|❯ [0-9]|Select an option|❯ 1\.|1\. Yes'
ERROR_RE='(^|[^a-z])[Ee]rror[: ]|Traceback \(most recent|FAILED|fatal:|panic:|✗ |command not found|No such file|Permission denied'
PROMPT_RE='[%$#][[:space:]]*$|➜[[:space:]]*$|❯[[:space:]]*$'

state="INIT"; prevhash=""; idle=0; first=1
emit(){ printf '%s | %s | %s\n' "$(date +%H:%M:%S)" "$LABEL" "$1"; }

trap 'emit "watch stopped"; exit 0' INT TERM

while :; do
  screen="$(rc read-screen "${wsflag[@]}" --surface "$SURFACE" 2>/dev/null)"
  # last few non-empty lines carry the current status
  tail5="$(printf '%s\n' "$screen" | grep -v '^[[:space:]]*$' | tail -5)"
  hash="$(printf '%s' "$screen" | cksum | cut -d' ' -f1)"
  changed=0; [ "$hash" != "$prevhash" ] && changed=1
  prevhash="$hash"

  # First read only establishes a baseline — never emit on it.
  if [ "$first" -eq 1 ]; then first=0; continue; fi

  new=""
  if printf '%s' "$tail5" | grep -qE "$NEEDS_RE"; then
    new="NEEDS-INPUT"
  elif [ "$changed" -eq 1 ] && printf '%s' "$tail5" | grep -qE "$ERROR_RE"; then
    new="ERROR"
  elif [ "$changed" -eq 1 ]; then
    idle=0; new="ACTIVE"
  else
    idle=$((idle+1))
    if [ "$idle" -ge "$IDLE_TICKS" ] && printf '%s' "$tail5" | tail -1 | grep -qE "$PROMPT_RE"; then
      new="DONE"
    fi
  fi

  if [ -n "$new" ] && [ "$new" != "$state" ]; then
    state="$new"
    emit "$new"
    case "$new" in
      NEEDS-INPUT) notify "cmux: $LABEL" "needs your input";;
      ERROR)       notify "cmux: $LABEL" "hit an error";;
      DONE)        notify "cmux: $LABEL" "finished — back at prompt";;
    esac
  fi
  sleep "$INTERVAL"
done
