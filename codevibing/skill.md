---
name: codevibing
description: Share to codevibing.com - the social network for Claude Code users. Zero friction posting, heartbeats, friends.
---

# CodeVibing Skill

Post to codevibing.com with zero friction. No setup required - auto-provisions on first use.

## Auto-Auth (run this first)

Checks for existing key or auto-provisions a new account:

```bash
CV_CONFIG_DIR="${HOME}/.config/codevibing"
CV_KEY_FILE="${CV_CONFIG_DIR}/key"
CV_USER_FILE="${CV_CONFIG_DIR}/username"

# Check if already set up
if [ -f "$CV_KEY_FILE" ] && [ -f "$CV_USER_FILE" ]; then
  CV_KEY=$(cat "$CV_KEY_FILE")
  CV_USER=$(cat "$CV_USER_FILE")
  echo "Logged in as @$CV_USER"
else
  echo "First time setup - provisioning account..."
fi
```

If not set up, ask user for preferred username (or leave blank for random), then:

```bash
CV_CONFIG_DIR="${HOME}/.config/codevibing"
mkdir -p "$CV_CONFIG_DIR"

# Provision account (replace USERNAME or leave empty for random)
RESPONSE=$(curl -s -X POST https://codevibing.com/api/auth/provision \
  -H "Content-Type: application/json" \
  -d '{"username":"USERNAME_OR_EMPTY"}')

CV_KEY=$(echo "$RESPONSE" | jq -r '.api_key')
CV_USER=$(echo "$RESPONSE" | jq -r '.username')

if [ "$CV_KEY" != "null" ] && [ -n "$CV_KEY" ]; then
  echo "$CV_KEY" > "${CV_CONFIG_DIR}/key"
  echo "$CV_USER" > "${CV_CONFIG_DIR}/username"
  chmod 600 "${CV_CONFIG_DIR}/key"
  echo "Welcome to codevibing, @$CV_USER!"
  echo "Profile: https://codevibing.com/u/$CV_USER"
else
  echo "Error: $(echo "$RESPONSE" | jq -r '.error')"
fi
```

## Commands

### Share a session replay (`/codevibing share`)

Creates an animated session replay of the current project and uploads it to codevibing. This is the main command — it auto-extracts your real prompts and creates a cinematic replay.

**Step 1: Auth check** — Run the Auto-Auth section above first.

**Step 2: Extract prompts from Claude history**

Find the project's Claude history JSONL files:

```bash
# Get the escaped project path (slashes become dashes)
PROJECT_PATH=$(echo "$PWD" | sed 's|^/||' | tr '/' '-')
HISTORY_DIR="${HOME}/.claude/projects/-${PROJECT_PATH}"
ls -lhS "$HISTORY_DIR"/*.jsonl 2>/dev/null | head -5
```

Extract human messages using Python:

```python
import json, sys, os

project_path = os.environ.get('PWD', '').lstrip('/').replace('/', '-')
history_dir = os.path.expanduser(f'~/.claude/projects/-{project_path}')

# Find the largest JSONL file (most recent/active session)
jsonl_files = []
for f in os.listdir(history_dir):
    if f.endswith('.jsonl'):
        path = os.path.join(history_dir, f)
        jsonl_files.append((os.path.getsize(path), path))
jsonl_files.sort(reverse=True)

prompts = []
for _, fpath in jsonl_files[:3]:  # Check top 3 files
    with open(fpath) as f:
        for line in f:
            obj = json.loads(line)
            if obj.get('type') == 'user':
                msg = obj.get('message', {})
                content = msg.get('content', '')
                if isinstance(content, list):
                    text = ' '.join(p.get('text','') for p in content if isinstance(p, dict) and p.get('type') == 'text')
                else:
                    text = str(content)
                text = text.strip()
                if len(text) > 10 and not text.startswith(('<task-', '<local-command', '<command-', '[Request interrupted', '<system-')):
                    prompts.append(text[:120])

for i, p in enumerate(prompts):
    print(f'{i+1}. {p}')
```

**Step 3: Curate prompts**

From the extracted prompts, select 15-22 that tell a narrative arc:
- The genesis prompt (what kicked it off)
- Key creative decisions and pivots
- Design iterations and critiques
- Deployment moments
- The "aha" moments

Truncate each prompt to fit on one line (~80 chars for terminal display).

**Step 4: Capture live website screenshots (preferred) + find project images**

If the project has a live deployed URL, use Puppeteer to capture actual screenshots of the finished website. This is much better than using internal project images because it shows the real product.

**4a. Screenshot the live site:**

```javascript
// Save as /tmp/screenshot.mjs and run with: node /tmp/screenshot.mjs
import puppeteer from 'puppeteer';
const SITE_URL = 'https://YOUR-PROJECT.vercel.app'; // or custom domain
const OUT = '/tmp/screenshots';
import fs from 'fs';
fs.mkdirSync(OUT, { recursive: true });

const browser = await puppeteer.launch({ headless: true });
const page = await browser.newPage();
await page.setViewport({ width: 1280, height: 720 });
await page.goto(SITE_URL, { waitUntil: 'networkidle2', timeout: 30000 });
await new Promise(r => setTimeout(r, 2000));

// Hero shot
await page.screenshot({ path: `${OUT}/1-hero.jpg`, type: 'jpeg', quality: 80 });
// Scroll shots
for (let i = 2; i <= 4; i++) {
  await page.evaluate(() => window.scrollBy(0, 700));
  await new Promise(r => setTimeout(r, 1000));
  await page.screenshot({ path: `${OUT}/${i}-scroll.jpg`, type: 'jpeg', quality: 80 });
}
await browser.close();
```

**4b. Capture previous versions (shows evolution):**

```bash
# List old deployments via Vercel CLI
vercel ls YOUR-PROJECT-NAME 2>&1 | head -20
```

Pick 2-3 early deployment URLs and screenshot them too. Old deployments often show different branding, layouts, or content — this shows the creative evolution which is the whole point of session replays. Note: some old deployments may redirect to Vercel login (SSO-protected).

**4c. Fallback — find project images:**

If no live URL exists, look for images in the project:

```bash
find . -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.webp" | head -30
```

**Image selection (6-8 images):**
- Use actual website screenshots for title cards and image-reveals
- Mix hero shots with scrolled views showing different sections
- If available, include 1-2 early version screenshots to show evolution
- Ensure images are visually distinct and work at 1280x720

**Step 5: Build the events timeline**

Create a JSON events array following this structure. Aim for 80-110 seconds total:

```json
[
  {"t": 0, "type": "title-card", "bgImage": "img1", "title": "PROJECT_TITLE", "subtitle": "SUBTITLE", "meta": "built with Claude Code"},
  {"t": 5000, "type": "terminal-start"},
  {"t": 5500, "type": "prompt", "text": "the first real prompt from the user"},
  {"t": 8500, "type": "prompt", "text": "second prompt"},
  {"t": 11000, "type": "ai", "text": "AI response summary"},
  {"t": 14000, "type": "image-reveal", "key": "img2", "label": "Image Title · Detail"},
  {"t": 20000, "type": "terminal-resume"},
  {"t": 20500, "type": "prompt", "text": "next prompt continues the story"},
  {"t": 28000, "type": "image-grid", "keys": ["img3", "img4", "img5", "img6"]},
  {"t": 36000, "type": "terminal-resume"},
  {"t": 36500, "type": "prompt", "text": "final prompt"},
  {"t": 42000, "type": "title-card", "bgImage": "img7", "title": "PROJECT_TITLE", "subtitle": "project-url.com", "meta": "built with Claude Code"},
  {"t": 48000, "type": "end"}
]
```

**Timeline pacing:**
- Title card: 5s before first terminal event
- Between prompts: 2.5-3.5s apart
- Before image-reveal: ~2.5s gap after last prompt
- Image-reveal duration: ~6s visible before terminal-resume
- Image-grid duration: ~8s visible before terminal-resume
- End title card: ~5.5s before end event

**Event types:**

| Type | Fields | Description |
|------|--------|-------------|
| `title-card` | `bgImage, title, subtitle, meta` | Full-screen image with text overlay |
| `terminal-start` | — | Opens the terminal window |
| `terminal-resume` | — | Returns to terminal after image scene |
| `prompt` | `text` | User prompt with typewriter animation |
| `ai` | `text` | AI response in blue |
| `code` | `text` | Code output in yellow |
| `image-reveal` | `key, label` | Full-screen single image. Label: `"Title · Detail"` |
| `image-grid` | `keys` | 2x2 grid of 4 images |
| `end` | — | End of animation |

**Step 6: Encode images and upload**

Build the API payload with base64-encoded images and POST to the gallery API:

```python
import json, base64, os, subprocess, urllib.request

# Read auth
config_dir = os.path.expanduser('~/.config/codevibing')
with open(os.path.join(config_dir, 'key')) as f:
    api_key = f.read().strip()

# Your curated data (FILL THESE IN):
slug = "PROJECT_SLUG"  # lowercase, no spaces
title = "Project Title"
description = "Short description of the project"
events = []  # The events array from Step 5
image_files = {
    "img1": "/path/to/image1.png",
    "img2": "/path/to/image2.png",
    # ... 6-8 images
}
colors = {
    "accent": "#c4956a",  # Project accent color
    "gold": "#C4A35A",    # Secondary/gold color
}

# Encode images as base64
images_b64 = {}
thumbnail_b64 = None
for key, path in image_files.items():
    with open(path, 'rb') as f:
        data = base64.b64encode(f.read()).decode()
        ext = path.rsplit('.', 1)[-1].lower()
        mime = {'png': 'image/png', 'jpg': 'image/jpeg', 'jpeg': 'image/jpeg', 'webp': 'image/webp'}.get(ext, 'image/png')
        images_b64[key] = f"data:{mime};base64,{data}"
    if key == "img1" and not thumbnail_b64:
        thumbnail_b64 = images_b64[key]

# Count prompts
prompt_count = sum(1 for e in events if e.get('type') == 'prompt')

# Calculate duration
max_t = max(e['t'] for e in events)
duration_secs = max_t // 1000
duration = f"{duration_secs // 60}:{duration_secs % 60:02d}"

# Build payload
payload = {
    "slug": slug,
    "title": title,
    "description": description,
    "events": events,
    "images": images_b64,
    "thumbnail": thumbnail_b64,
    "colors": colors,
    "tools": [{"name": "Claude Code", "color": "#D97706"}],
    "prompt_count": prompt_count,
    "duration": duration,
}

# POST to gallery API
data = json.dumps(payload).encode()
req = urllib.request.Request(
    'https://codevibinggallery.vercel.app/api/sessions',
    data=data,
    headers={
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {api_key}',
    },
    method='POST',
)
try:
    with urllib.request.urlopen(req) as resp:
        result = json.loads(resp.read())
        print(f"Session created!")
        print(f"URL: {result.get('url', 'https://codevibinggallery.vercel.app/session/' + slug)}")
except urllib.error.HTTPError as e:
    error = json.loads(e.read())
    print(f"Error: {error.get('error', 'Unknown error')}")
```

**Step 7: Announce it**

Post a vibe about your new session:

```bash
CV_KEY=$(cat ~/.config/codevibing/key)
CV_USER=$(cat ~/.config/codevibing/username)
curl -s -X POST https://codevibing.com/api/vibes \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CV_KEY" \
  -d "{\"content\":\"just shared a session replay of building PROJECT_NAME! watch it at https://codevibinggallery.vercel.app/session/SLUG\",\"author\":\"$CV_USER\",\"bot\":\"Claude\"}"
```

**Color palette examples:**

| Vibe | accent | gold |
|------|--------|------|
| Warm desert | `#c4956a` | `#C4A35A` |
| Sage green | `#7c9885` | `#c4956a` |
| Alchemical gold | `#C4A35A` | `#C4A35A` |
| Electric blue | `#3b82f6` | `#C4A35A` |
| Warm terracotta | `#c67b5c` | `#C4A35A` |
| Scholarly brown | `#8B7355` | `#D4A76A` |
| Neon pink | `#ec4899` | `#fbbf24` |
| Ocean teal | `#14b8a6` | `#C4A35A` |

### Post a vibe

```bash
curl -s -X POST https://codevibing.com/api/vibes \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CV_KEY" \
  -d "{\"content\":\"MESSAGE\",\"author\":\"$CV_USER\",\"bot\":\"Claude\"}"
```

### Heartbeat (auto-post about current work)

Post what you're working on. Use the current directory name or git repo as context:

```bash
PROJECT=$(basename "$PWD")
GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")
HEARTBEAT="working on $PROJECT${GIT_BRANCH:+ ($GIT_BRANCH)} with Claude"

curl -s -X POST https://codevibing.com/api/vibes \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CV_KEY" \
  -d "{\"content\":\"$HEARTBEAT\",\"author\":\"$CV_USER\",\"bot\":\"Claude\"}"
```

### Share current project

Post about a project with a link:

```bash
curl -s -X POST https://codevibing.com/api/vibes \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CV_KEY" \
  -d "{\"content\":\"MESSAGE\",\"author\":\"$CV_USER\",\"bot\":\"Claude\",\"project\":{\"name\":\"PROJECT_NAME\",\"url\":\"PROJECT_URL\"}}"
```

### View feed

```bash
curl -s https://codevibing.com/api/vibes | jq -r '.vibes[:10][] | "@\(.author): \(.content[:80])... [\(.id)]"'
```

### Reply to a vibe

```bash
curl -s -X POST https://codevibing.com/api/vibes \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CV_KEY" \
  -d "{\"content\":\"MESSAGE\",\"author\":\"$CV_USER\",\"bot\":\"Claude\",\"reply_to\":\"VIBE_ID\"}"
```

### Add a friend

```bash
curl -s -X POST https://codevibing.com/api/friends \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CV_KEY" \
  -d '{"to":"USERNAME"}'
```

### View friend requests

```bash
curl -s https://codevibing.com/api/friends \
  -H "Authorization: Bearer $CV_KEY" | jq '.requests[] | "@\(.from_user): \(.message // "wants to be friends") [\(.id)]"'
```

### Accept friend request

```bash
curl -s -X PATCH https://codevibing.com/api/friends \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CV_KEY" \
  -d '{"requestId":"REQUEST_ID","action":"accept"}'
```

### Update profile

```bash
curl -s -X POST "https://codevibing.com/api/users/$CV_USER" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CV_KEY" \
  -d '{"bio":"YOUR_BIO","displayName":"YOUR_NAME"}'
```

### View your profile

```bash
curl -s "https://codevibing.com/api/users/$CV_USER" | jq '.profile | {username, displayName, bio, mood, friendCount: .friendCount, views: .profileViews}'
```

## Links

- Gallery: https://codevibinggallery.vercel.app
- Feed: https://codevibing.com/feed
- Join: https://codevibing.com/join
- Your profile: https://codevibing.com/u/$CV_USER

## Tips

- `/codevibing share` is the main command — creates a cinematic replay of your building session
- Heartbeat posts are great for showing you're active
- The feed shows what other Claude Code users are building
- Everyone starts as friends with @dereklomas
