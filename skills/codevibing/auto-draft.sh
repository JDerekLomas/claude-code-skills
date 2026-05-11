#!/bin/bash
# Daily codevibing auto-drafter.
# Headlessly invokes `claude -p` to draft candidate posts about the user's
# recent work. Drafts are saved to ~/.config/codevibing/drafts/ for review
# via /codevibing drafts. NEVER posts automatically.

set -u
DRAFTS_DIR="${HOME}/.config/codevibing/drafts"
LOG="${HOME}/.config/codevibing/auto-draft.log"
mkdir -p "$DRAFTS_DIR"
TIMESTAMP=$(date +%Y-%m-%d-%H%M)

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG"; }

[ ! -f "${HOME}/.config/codevibing/key" ] && { log "skip: no codevibing auth"; exit 0; }

# Cooldown: skip if a draft was generated in the last 12 hours
RECENT=$(find "$DRAFTS_DIR" -name '*.txt' -mtime -0.5 2>/dev/null | head -1)
[ -n "$RECENT" ] && { log "skip: recent draft exists ($RECENT)"; exit 0; }

# Build context: recent git activity across known repos
CONTEXT_FILE=$(mktemp)
trap 'rm -f "$CONTEXT_FILE" "$PROMPT_FILE"' EXIT

for d in "${HOME}/sourcelibrary" "${HOME}/codevibing-app" "${HOME}/projects"/*; do
    [ -d "$d/.git" ] || continue
    recent=$(git -C "$d" log --since='1 day ago' --pretty=format:'%h %s' 2>/dev/null | head -8)
    [ -z "$recent" ] && continue
    {
        echo "── $(basename "$d") ──"
        echo "$recent"
        echo
    } >> "$CONTEXT_FILE"
done

if [ ! -s "$CONTEXT_FILE" ]; then
    log "no git activity in last 24h"
    exit 0
fi

# Read voice card (if missing, use a default)
VOICE_FILE="${HOME}/.config/codevibing/voice.md"
if [ ! -f "$VOICE_FILE" ]; then
    VOICE_FILE=$(mktemp)
    echo "Concise, no fluff, no emojis. Builder voice, dry humor allowed. Short paragraphs." > "$VOICE_FILE"
fi

# Assemble prompt in a temp file — avoids shell quoting issues
PROMPT_FILE=$(mktemp)
{
    echo "You are drafting candidate posts for codevibing.com on behalf of @dereklomas."
    echo "You do NOT post anything — only produce draft text. A human will review."
    echo
    echo "# Voice (talk like this)"
    cat "$VOICE_FILE"
    echo
    echo "# Recent git activity (last 24h)"
    cat "$CONTEXT_FILE"
    echo
    echo "# Task"
    echo "Pick 1-3 of the commits/themes above that would make a genuinely interesting"
    echo "post — something concrete that someone building with Claude Code might find"
    echo "useful. Skip vague commits. Skip anything that names a client or leaks internals."
    echo
    echo "For each draft:"
    echo "- One paragraph, around 280 characters"
    echo "- Concrete: what I built, what it does, what is interesting about it"
    echo "- In my voice (see above)"
    echo "- No emojis. No hype. No hashtags."
    echo "- Privacy check: no client names, no secrets, no internal terminology"
    echo
    echo "# Output format"
    echo "Output ONLY the draft text. Separate multiple drafts with a line containing"
    echo "just three dashes (---). Do not include numbering, headers, or commentary."
    echo "If nothing above is worth drafting, output the single word: NOTHING_TO_DRAFT"
} > "$PROMPT_FILE"

OUT="${DRAFTS_DIR}/${TIMESTAMP}.txt"

# Invoke Claude headlessly with a portable 90s timeout
RESULT=$(perl -e 'alarm 90; exec @ARGV' claude -p "$(cat "$PROMPT_FILE")" --output-format text 2>>"$LOG")
EXIT=$?
if [ $EXIT -ne 0 ]; then
    log "claude -p failed (exit $EXIT)"
    exit 1
fi

# Trim whitespace, check for no-op signal
TRIMMED=$(printf '%s' "$RESULT" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
if [ -z "$TRIMMED" ] || printf '%s' "$TRIMMED" | grep -q "NOTHING_TO_DRAFT"; then
    log "claude returned NOTHING_TO_DRAFT"
    exit 0
fi

printf '%s\n' "$TRIMMED" > "$OUT"
COUNT=$(grep -c '^---$' "$OUT" 2>/dev/null || echo 0)
COUNT=$((COUNT + 1))
log "drafted $COUNT candidate(s) -> $OUT"
