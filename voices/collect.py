#!/usr/bin/env python3
"""voices/collect.py: collect first-person public comments about an experience, from the
Arctic Shift Reddit archive and Hacker News (Algolia). No login, no API keys.

Polite by design: one request at a time, pauses between requests, backoff on errors.
Output is JSONL with no usernames: src, domain, sub, term, score, created_utc, link, body.

Usage:
  python3 -I collect.py --config config.json --out voices.jsonl

config.json:
{
  "terms": ["dehumanizing", "just a number"],          # phrases searched in comment text
  "reddit": {"education": ["Teachers", "Professors"]},  # domain -> subreddits
  "hn_contexts": ["school", "hospital"],                # appended to each term for HN search ([] to skip)
  "min_len": 60,                                        # drop very short comments
  "first_person": true,                                 # keep only comments with I/me/my/we
  "per_query": 10,                                      # Reddit page size; the archive times out above ~10
  "pause": 4,                                           # seconds between Reddit requests
  "pages": 10                                           # pages of per_query (~10) walked back in time per (sub, term)
}
"""
import argparse, json, re, sys, time, urllib.parse, urllib.request

UA = {"User-Agent": "voices-research/0.1 (personal research script)"}
SELF = re.compile(r"\b(I|I'm|I've|I was|me|my|we|us|our)\b", re.I)


def get(url, tries=4):
    for i in range(tries):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=60) as r:
                d = json.load(r)
            if isinstance(d, dict) and d.get("error"):
                raise RuntimeError(d["error"])
            return d
        except Exception as e:  # timeouts, 429s, archive "slow down" errors
            print(f"  retry {i+1} after error: {e}", file=sys.stderr)
            time.sleep(15 * (i + 1))
    return None


def keep(body, cfg):
    return len(body) >= cfg.get("min_len", 60) and (not cfg.get("first_person", True) or SELF.search(body))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", required=True)
    ap.add_argument("--out", required=True)
    a = ap.parse_args()
    cfg = json.load(open(a.config))
    seen, n = set(), 0
    with open(a.out, "a") as f:
        for domain, subs in cfg.get("reddit", {}).items():
            for sub in subs:
                for term in cfg["terms"]:
                    # The archive times out (HTTP 422, "Timeout. Maybe slow down a bit") on large result sets,
                    # so ask for small pages (per_query ~20) and walk back in time with before=<oldest seen>.
                    before, got = None, 0
                    for page in range(cfg.get("pages", 5)):
                        params = {"subreddit": sub, "body": term, "limit": cfg.get("per_query", 10)}
                        if before: params["before"] = before
                        d = get(f"https://arctic-shift.photon-reddit.com/api/comments/search?{urllib.parse.urlencode(params)}")
                        rows = (d or {}).get("data") or []
                        for c in rows:
                            body = c.get("body") or ""
                            if c.get("id") in seen or not keep(body, cfg):
                                continue
                            seen.add(c.get("id"))
                            link = (f"https://www.reddit.com{c['permalink']}" if c.get("permalink")
                                    else f"https://www.reddit.com/r/{sub}/comments/{(c.get('link_id') or '')[3:]}/_/{c.get('id')}")
                            f.write(json.dumps({"src": "reddit", "domain": domain, "sub": sub, "term": term,
                                                "score": c.get("score"), "created_utc": c.get("created_utc"),
                                                "link": link, "body": body[:1500]}) + "\n")
                            n += 1; got += 1
                        f.flush()
                        time.sleep(cfg.get("pause", 4))
                        if len(rows) < cfg.get("per_query", 10):
                            break
                        before = min(int(c.get("created_utc") or 0) for c in rows)
                    print(f"reddit r/{sub} '{term}': {got}", file=sys.stderr)
        for term in cfg["terms"]:
            for ctx in cfg.get("hn_contexts", []):
                q = urllib.parse.urlencode({"query": f"{term} {ctx}", "tags": "comment", "hitsPerPage": 50})
                d = get(f"https://hn.algolia.com/api/v1/search?{q}")
                for h in (d or {}).get("hits") or []:
                    body = re.sub("<[^>]+>", " ", h.get("comment_text") or "")
                    if h.get("objectID") in seen or not keep(body, cfg):
                        continue
                    seen.add(h.get("objectID"))
                    f.write(json.dumps({"src": "hn", "domain": ctx, "term": term, "score": h.get("points"),
                                        "created_utc": h.get("created_at"),
                                        "link": f"https://news.ycombinator.com/item?id={h.get('objectID')}",
                                        "body": body[:1500]}) + "\n")
                    n += 1
                f.flush()
                time.sleep(1)
    print(f"collected {n} -> {a.out}")


if __name__ == "__main__":
    main()
