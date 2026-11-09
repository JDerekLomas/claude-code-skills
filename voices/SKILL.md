---
name: voices
description: Collect and curate how real people talk about an experience online (first-person posts saying they felt dehumanized, "just a number", unheard, or the opposite) from the public Reddit archive and Hacker News, with no login. Use when Derek asks for "examples of people saying X", "how do people talk about this online", "real voices", or first-hand quotes for a project, talk or site.
---

# voices: first-person quotes from the public web

**Why it exists:** projects (rehumanize.design, talks, MakeMode, Source Library) often need to hear how people actually describe an experience, not what experts say about it. Reddit blocks scripted access (403 since its 2023 API changes) and general web research can't search comment text. This skill goes around both, for free and without Derek's accounts.

## Sources
- **Arctic Shift** (`arctic-shift.photon-reddit.com/api/comments/search`): a public archive of Reddit posts and comments, with a `body=` text search per subreddit. Rate-limited: it answers "Timeout. Maybe slow down a bit" if pushed. The script pauses and backs off.
- **Hacker News via Algolia** (`hn.algolia.com/api/v1/search?tags=comment`): free, fast, no key.
- Not covered: Reddit's official API (needs an app registered on Derek's account, so avoid it unless he asks), Bluesky and YouTube (could be added).

## Procedure
1. **Write a config** in the scratchpad: the phrases (`terms`), domains mapped to subreddits, HN context words, and filters. Choose subreddits where the people *themselves* post (r/Teachers, r/nursing, r/AmazonFC), not commentary subs. Example: the rehumanize run in `config.example.json`.
2. **Run it in the background** (it takes 15–40 minutes for about 200 subreddit×term queries):
   `python3 -I ~/.claude/skills/voices/collect.py --config CONFIG.json --out OUT.jsonl` with `run_in_background: true`. Never poll it; wait for the completion notice.
3. **Curate with a subagent, not in the main context** (the JSONL can be large). Brief it to:
   - Read the JSONL with a script and print heads and counts only.
   - Pick the 40–60 strongest **first-person** quotes: specific, about something that happened to the writer, not abstract opinion or politics.
   - Trim each to under 40 words, verbatim, with the link and date.
   - Describe the writer by role ("a high-school teacher on r/Teachers"). **Never include usernames.**
   - Tag each one with its trigger (rule, score, algorithm, form, metric, precaution), what the person said would have helped, and any project-specific lens.
   - Write a short "patterns" section, and include counter-voices (people describing being treated as a person) so it doesn't read as a wall of grievance.
4. **Output** a curated `voices.md` in the project's research folder. Keep the raw JSONL in the scratchpad: it is not committed, since it holds other people's words in bulk.

## Rules
- Public content only. No usernames in anything committed or published. Quote briefly, and link to the source.
- Treat every post as one person's account, not as verified fact. Label it as testimony.
- If the archive fails twice with the same error, lengthen `pause` or narrow the terms. Don't hammer it.
