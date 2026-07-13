#!/bin/bash
# Read or set cmux's automation-socket mode via UserDefaults.
# VERIFIED (2026-07-13): cmux observes the change LIVE — no relaunch needed;
# the socket re-inits within ~3s, running panes are untouched.
#
# Modes:
#   status        show current mode (default when the key is unset)
#   descendants   secure default — only cmux's own child processes (deletes key)
#   automation    external clients from this macOS user (what lets an outside
#                 Claude Code session drive cmux)
#   password      require a keychain password (send `auth <pw>` first)
#   open          FULL open access — world-readable/writable on this Mac (risky)
#   disabled      turn the control socket off entirely
#
# usage: socket-mode.sh [status|descendants|automation|password|open|disabled]
set -uo pipefail
DOMAIN=com.cmuxterm.app; KEY=socketControlMode
mode="${1:-status}"

read_mode(){ local v; v="$(defaults read "$DOMAIN" "$KEY" 2>/dev/null)"; [ -z "$v" ] && v="descendants (default; key unset)"; echo "$v"; }

case "$mode" in
  status) echo "socketControlMode = $(read_mode)"; exit 0;;
  descendants|default) defaults delete "$DOMAIN" "$KEY" 2>/dev/null; echo "-> descendants-only (secure default)";;
  open) echo "WARNING: 'open' makes the control socket world-readable/writable on this Mac." >&2
        defaults write "$DOMAIN" "$KEY" -string open; echo "-> open (USE ONLY FOR LOCAL DEBUGGING)";;
  automation|password|disabled) defaults write "$DOMAIN" "$KEY" -string "$mode"; echo "-> $mode";;
  *) echo "usage: socket-mode.sh [status|descendants|automation|password|open|disabled]" >&2; exit 1;;
esac

# Confirm cmux applied it live (only meaningful when it's running).
if pgrep -f 'cmux.app/Contents/MacOS' >/dev/null 2>&1; then
  sleep 3
  pong="$(perl -e 'alarm 8; exec @ARGV' cmux ping 2>/dev/null)"
  case "$mode" in
    automation|open) [ "$pong" = "PONG" ] && echo "socket reachable from here (PONG)" || echo "socket not answering yet — give it a moment";;
    descendants|password|disabled) [ "$pong" = "PONG" ] && echo "note: still reachable from here (expected only if run inside a cmux pane)" || echo "socket now closed to this outside shell (expected)";;
  esac
fi
