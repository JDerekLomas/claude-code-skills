#!/bin/bash
# Posts a one-line recap to codevibing.com when a Claude Code session ends.
# Wired up as a Stop hook. Opt-in — only fires if ~/.config/codevibing/key exists
# AND ~/.claude/skills/codevibing/recap-enabled exists.

# Stop hook payload arrives on stdin
INPUT=$(cat)

# Bail if recap isn't explicitly enabled (touch ~/.claude/skills/codevibing/recap-enabled to enable)
[ ! -f ~/.claude/skills/codevibing/recap-enabled ] && exit 0

CV_KEY=$(cat ~/.config/codevibing/key 2>/dev/null) || exit 0
CV_USER=$(cat ~/.config/codevibing/username 2>/dev/null) || exit 0

TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null)
[ -z "$TRANSCRIPT" ] || [ ! -f "$TRANSCRIPT" ] && exit 0

# Skip trivial sessions (<3 user messages)
USER_MSGS=$(grep -c '"type":"user"' "$TRANSCRIPT" 2>/dev/null || echo 0)
[ "$USER_MSGS" -lt 3 ] && exit 0

PROJECT=$(basename "$PWD")

# Grab the first real user prompt as context (skip system/tool messages)
FIRST_PROMPT=$(jq -r 'select(.type=="user") | .message.content // empty' "$TRANSCRIPT" 2>/dev/null \
  | grep -v '^<' | grep -v '^$' | head -1 | cut -c1-120)

CONTENT="wrapped a session on ${PROJECT}: ${FIRST_PROMPT:-doing work}"

# Background the curl so session exit isn't blocked
(
  curl -s -X POST https://codevibing.com/api/vibes \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $CV_KEY" \
    -d "$(jq -nc --arg c "$CONTENT" --arg u "$CV_USER" '{content:$c, author:$u, bot:"Claude"}')" \
    > /dev/null 2>&1
) &
disown 2>/dev/null

exit 0
