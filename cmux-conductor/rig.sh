#!/bin/bash
# Bootstrap a standard cmux board. Idempotent by workspace title: a workspace
# whose title already exists is left alone, so re-running only fills gaps.
#
# Edit the SPECS array to taste. Each line:  title | shell command | browser url
#   - command may be empty (just an interactive shell in that dir)
#   - browser url may be empty (no browser pane); if set, opens split-right
#
# usage: rig.sh            # create any missing workspaces
#        rig.sh --list     # just show current workspaces
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$HERE/lib.sh"
cmux_up || die "socket not answering (is cmux running / access allowed?)"

# ---- EDIT ME -------------------------------------------------------------
# Work workspaces:  title | shell command | optional browser url
SPECS=(
  "sourcelibrary | cd ~/sourcelibrary && git status -sb | "
  "pipeline      | cd ~/sourcelibrary                    | "
  "ops           | cd ~/sourcelibrary-ops                | "
  "web           | cd ~/sourcelibrary                    | https://sourcelibrary.org/platform/admin/system-map"
)

# Agent workspaces:  title | cli name | launch command | install hint
# Each pane launches the agent if its CLI is on PATH, else drops to a shell
# showing the hint — so uninstalled agents (hermes, makemode) light up later
# with zero edits once you install them.
AGENTS=(
  "claude   | claude   | claude                 | https://claude.com/claude-code"
  "opencode | opencode | opencode               | https://opencode.ai"
  "hermes   | hermes   | hermes                 | https://github.com/nousresearch/hermes-agent"
  "makemode | makemode | makemode               | (makemode CLI not found on PATH)"
)
AGENT_DIR="$HOME/sourcelibrary"   # where agent panes start
# -------------------------------------------------------------------------

existing="$(rc --json list-workspaces | grep -oE '"title"[^,]*' | sed -E 's/.*: *"//; s/"$//')"
has_title(){ printf '%s\n' "$existing" | grep -Fxq "$1"; }

if [ "${1:-}" = "--list" ]; then
  echo "current workspaces:"; printf '%s\n' "$existing" | sed 's/^/  - /'; exit 0
fi

for spec in "${SPECS[@]}"; do
  title="$(echo "${spec%%|*}" | xargs)"
  rest="${spec#*|}"; cmd="$(echo "${rest%%|*}" | sed -E 's/^ +| +$//g')"
  url="$(echo "${rest##*|}" | xargs)"

  if has_title "$title"; then echo "= $title (exists, skipping)"; continue; fi

  nw="$(rc new-workspace)"; WS="$(uuid_of "$nw")"
  [ -n "$WS" ] || { echo "! $title — could not create"; continue; }
  rc rename-workspace --workspace "$WS" "$title" >/dev/null
  SURF="$(rc --json list-pane-surfaces --workspace "$WS" | grep -oE 'surface:[0-9]+' | head -1)"

  if [ -n "$cmd" ] && [ -n "$SURF" ]; then
    rc send --workspace "$WS" --surface "$SURF" "$cmd" >/dev/null
    rc send-key --workspace "$WS" --surface "$SURF" enter >/dev/null
  fi
  if [ -n "$url" ]; then
    rc new-pane --type browser --url "$url" --workspace "$WS" >/dev/null
  fi
  echo "+ $title (created${url:+ , browser: $url})"
done

for spec in "${AGENTS[@]}"; do
  title="$(echo "${spec%%|*}" | xargs)"
  rest="${spec#*|}"; cli="$(echo "${rest%%|*}" | xargs)"
  rest="${rest#*|}"; launch="$(echo "${rest%%|*}" | sed -E 's/^ +| +$//g')"
  hint="$(echo "${rest##*|}" | sed -E 's/^ +| +$//g')"

  if has_title "$title"; then echo "= $title (exists, skipping)"; continue; fi

  nw="$(rc new-workspace)"; WS="$(uuid_of "$nw")"
  [ -n "$WS" ] || { echo "! $title — could not create"; continue; }
  rc rename-workspace --workspace "$WS" "$title" >/dev/null
  SURF="$(rc --json list-pane-surfaces --workspace "$WS" | grep -oE 'surface:[0-9]+' | head -1)"
  [ -n "$SURF" ] || { echo "! $title — no surface"; continue; }

  # Launch the agent if present; otherwise cd + print the install hint.
  cmd="cd $AGENT_DIR && { command -v $cli >/dev/null 2>&1 && $launch || echo '$cli not on PATH — $hint'; }"
  rc send --workspace "$WS" --surface "$SURF" "$cmd" >/dev/null
  rc send-key --workspace "$WS" --surface "$SURF" enter >/dev/null
  echo "+ $title (agent: $cli)"
done

echo "done. board:"; rc --json list-workspaces | grep -oE '"title"[^,]*' | sed -E 's/.*: *"//; s/"$//; s/^/  - /'
