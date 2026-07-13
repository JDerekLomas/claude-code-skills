#!/bin/bash
# cmux-conductor shared helpers.
# Sourced by rig.sh and watch.sh. Works whether run inside a cmux pane
# (ancestry-authed) or from an outside shell with the socket opened to the
# local user (Settings > Advanced > "Allow external local automation clients").

# Run a cmux command with a hard 10s timeout, no job-control noise.
# The alarm() timer survives exec, so cmux itself is killed if it hangs.
rc(){ perl -e 'alarm 10; exec @ARGV' cmux "$@" 2>&1; }

# Confirm the socket answers before we try to drive it.
cmux_up(){ [ "$(rc ping 2>/dev/null)" = "PONG" ]; }

# Parse "OK surface:4 pane:4 workspace:2" style replies for a given ref kind.
# usage: ref_of surface "OK surface:4 pane:4"  ->  surface:4
ref_of(){ echo "$2" | grep -oE "$1:[0-9]+" | head -1; }

# Parse the UUID a create command returns ("OK 15D1...-...").
uuid_of(){ echo "$1" | grep -oiE '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' | head -1; }

# Fire a notification through cmux (rings the tab) AND the macOS banner.
notify(){ # title, body
  rc notify --title "$1" --body "$2" >/dev/null 2>&1
  osascript -e "display notification \"$2\" with title \"$1\"" >/dev/null 2>&1
}

die(){ echo "cmux-conductor: $*" >&2; exit 1; }
