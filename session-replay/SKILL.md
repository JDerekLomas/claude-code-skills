---
name: session-replay
description: Create a codevibing session replay — an animated canvas-based video that replays a Claude Code building session with real prompts, AI responses, and project images. Use when asked to create a session, session replay, or codevibing video for a project.
---

# Session Replay Creation

Create cinematic canvas-animated replays of Claude Code sessions for codevibing.com. Each session is a standalone HTML file that autoplays a timeline of typed prompts, AI responses, and image reveals.

## Overview

1. Find the project and extract real prompts from Claude history
2. Copy 6-8 representative images to `public/<slug>/`
3. Write the session HTML to `public/sessions/<slug>.html`
4. Add the session to the gallery in `src/app/sessions/page.tsx`

## Step 1: Find Prompts

Search Claude history JSONL files for the project:

```bash
ls -lhS ~/.claude/projects/-Users-dereklomas-<project-path>/
```

Extract human messages from the largest JSONL file(s):

```python
import json
fname = '<session-id>.jsonl'
with open(fname) as f:
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
            if len(text) > 10 and not text.startswith(('<task-', '<local-command', '<command-', '[Request interrupted')):
                ts = obj.get('timestamp', '')
                print(f'[{ts}] {text[:120]}')
```

Curate to ~15-22 prompts that tell the narrative arc. Look for:
- The genesis prompt (what kicked it off)
- Key creative decisions and pivots
- Design critiques and iterations
- Review interfaces (thumbs up/down, card review UIs, approval workflows)
- Deployment moments (github, vercel, domain setup)
- New websites going live (show as `ai` events: "Deployed to project.vercel.app")
- The "aha" moments

**Important**: Don't skip process moments like review UIs, feedback loops, and deployments — these show the human-AI collaboration workflow that makes sessions interesting.

Also check git log for context: `git -C ~/path/to/project log --oneline`

## Step 2: Copy Images

Pick 6-8 representative images from the project that show the visual output. Copy them to the codevibing2 public directory:

```bash
mkdir -p ~/codevibing2/public/<slug>/
cp ~/project/path/to/images/*.png ~/codevibing2/public/<slug>/
```

Choose images that:
- Show different stages or categories of the project
- Work well as backgrounds (title cards) and in 2x2 grids
- Are visually distinct from each other

## Step 3: Write the Session HTML

Create `public/sessions/<slug>.html` using this template. Customize the marked sections.

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<!-- CUSTOMIZE: title and meta tags -->
<title>PROJECT_TITLE — codevibing session</title>
<meta property="og:title" content="PROJECT_TITLE — SUBTITLE">
<meta property="og:description" content="Watch DESCRIPTION get built with AI">
<meta name="twitter:card" content="summary_large_image">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { background: #08080c; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 100vh; font-family: -apple-system, sans-serif; color: white; }
  canvas { border-radius: 12px; max-width: 100%; height: auto; cursor: pointer; }
  .back { position: fixed; top: 20px; left: 20px; color: #6a6a80; text-decoration: none; font-size: 14px; z-index: 10; }
  .back:hover { color: #f0ece4; }
</style>
</head>
<body>

<a href="/sessions" class="back">&larr; all sessions</a>
<canvas id="canvas" width="1280" height="720"></canvas>

<script>
const canvas = document.getElementById('canvas');
const ctx = canvas.getContext('2d');
const W = 1280, H = 720;

// CUSTOMIZE: accent and gold colors to match project aesthetic
const C = {
  bg: '#08080c',
  surface: '#101018',
  border: '#1c1c2c',
  text: '#f0ece4',
  dim: '#7a7068',
  prompt: '#6ee7b7',
  ai: '#93c5fd',
  code: '#fbbf24',
  accent: '#c4956a',   // CUSTOMIZE: project accent color
  violet: '#a78bfa',
  rust: '#c67b5c',
  lapis: '#4a7bbd',
  gold: '#C4A35A',     // CUSTOMIZE: project gold/secondary color
};

// CUSTOMIZE: image sources from public/<slug>/
const images = {};
const imageSources = {
  img1: '/<slug>/image1.png',
  img2: '/<slug>/image2.png',
  // ... 6-8 images
};

let imagesLoaded = 0;
Object.entries(imageSources).forEach(([key, src]) => {
  const img = new Image();
  img.onload = () => { imagesLoaded++; };
  img.onerror = () => { imagesLoaded++; };
  img.src = src;
  images[key] = img;
});

// CUSTOMIZE: the entire events timeline
const events = [
  // --- TITLE CARD (0-5s) ---
  { t: 0, type: 'title-card', bgImage: 'img1', title: 'PROJECT_TITLE', subtitle: 'SUBTITLE', meta: 'built with Claude Code · DATE' },

  // --- TERMINAL SESSION ---
  { t: 5000, type: 'terminal-start' },
  { t: 5500, type: 'prompt', text: "the first real prompt from the user" },
  { t: 8500, type: 'prompt', text: "second prompt" },
  { t: 11000, type: 'ai', text: "AI response summary" },

  // --- IMAGE REVEAL (full-screen single image) ---
  { t: 14000, type: 'image-reveal', key: 'img2', label: 'Image Title · Detail' },

  // --- RETURN TO TERMINAL ---
  { t: 20000, type: 'terminal-resume' },
  { t: 20500, type: 'prompt', text: "next prompt continues the story" },

  // --- IMAGE GRID (2x2 grid of 4 images) ---
  { t: 28000, type: 'image-grid', keys: ['img1', 'img2', 'img3', 'img4'] },

  // --- END TITLE CARD ---
  { t: 36000, type: 'title-card', bgImage: 'img3', title: 'PROJECT_TITLE', subtitle: 'project-url.vercel.app', meta: 'built with Claude Code' },

  { t: 42000, type: 'end' },
];

let startTime = null;
let animFrame = null;
let currentElapsed = 0;
let animRunning = false;
let zoom = 1, zoomTarget = 1, panY = 0, panYTarget = 0;

function lerp(a, b, t) { return a + (b - a) * Math.min(Math.max(t, 0), 1); }
function easeOut(t) { return 1 - Math.pow(1 - Math.min(t, 1), 3); }

function drawRoundRect(x, y, w, h, r) {
  ctx.beginPath();
  ctx.moveTo(x + r, y); ctx.lineTo(x + w - r, y);
  ctx.quadraticCurveTo(x + w, y, x + w, y + r); ctx.lineTo(x + w, y + h - r);
  ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h); ctx.lineTo(x + r, y + h);
  ctx.quadraticCurveTo(x, y + h, x, y + h - r); ctx.lineTo(x, y + r);
  ctx.quadraticCurveTo(x, y, x + r, y); ctx.closePath();
}

function drawImageCover(img, x, y, w, h) {
  if (!img || !img.complete || !img.naturalWidth) return;
  const imgR = img.naturalWidth / img.naturalHeight, boxR = w / h;
  let sx = 0, sy = 0, sw = img.naturalWidth, sh = img.naturalHeight;
  if (imgR > boxR) { sw = sh * boxR; sx = (img.naturalWidth - sw) / 2; }
  else { sh = sw / boxR; sy = (img.naturalHeight - sh) / 2; }
  ctx.drawImage(img, sx, sy, sw, sh, x, y, w, h);
}

function getActiveMode(elapsed) {
  const visible = events.filter(e => e.t <= elapsed);
  for (let i = visible.length - 1; i >= 0; i--) {
    const t = visible[i].type;
    if (t === 'title-card') return 'title-card';
    if (t === 'image-reveal') return 'image-reveal';
    if (t === 'image-grid') return 'image-grid';
    if (t === 'terminal-resume' || t === 'terminal-start') return 'terminal';
    if (['prompt','ai','code'].includes(t)) return 'terminal';
  }
  return 'title-card';
}

function drawTitleCard(elapsed) {
  const cards = events.filter(e => e.t <= elapsed && e.type === 'title-card');
  const card = cards[cards.length - 1];
  if (!card) return;
  const age = elapsed - card.t;
  const img = images[card.bgImage];

  if (img && img.complete && img.naturalWidth) {
    ctx.globalAlpha = easeOut(Math.min(age / 1200, 1));
    drawImageCover(img, 0, 0, W, H);
    const ov = ctx.createLinearGradient(0, 0, 0, H);
    ov.addColorStop(0, 'rgba(8,8,12,0.4)');
    ov.addColorStop(0.4, 'rgba(8,8,12,0.3)');
    ov.addColorStop(0.7, 'rgba(8,8,12,0.6)');
    ov.addColorStop(1, 'rgba(8,8,12,0.85)');
    ctx.fillStyle = ov; ctx.fillRect(0, 0, W, H);
    ctx.globalAlpha = 1;
  }

  ctx.globalAlpha = Math.max(easeOut(Math.min((age - 500) / 800, 1)), 0);
  const tx = 80, ty = H - 120;
  ctx.shadowColor = 'rgba(0,0,0,0.7)'; ctx.shadowBlur = 24;
  ctx.font = '700 72px -apple-system, sans-serif';
  ctx.fillStyle = '#fff'; ctx.textAlign = 'left';
  ctx.fillText(card.title, tx, ty);
  ctx.font = '300 28px -apple-system, sans-serif';
  ctx.fillStyle = C.gold; ctx.shadowBlur = 12;
  ctx.fillText(card.subtitle, tx, ty + 42);
  if (card.meta) {
    ctx.font = '400 15px -apple-system, sans-serif';
    ctx.fillStyle = 'rgba(255,255,255,0.5)'; ctx.shadowBlur = 6;
    ctx.fillText(card.meta, tx, ty + 72);
  }
  ctx.shadowBlur = 0; ctx.globalAlpha = 1;
}

function drawTerminal(elapsed) {
  zoom = lerp(zoom, zoomTarget, 0.06);
  panY = lerp(panY, panYTarget, 0.06);
  ctx.save();
  ctx.translate(W/2, H/2); ctx.scale(zoom, zoom); ctx.translate(-W/2, -H/2 + panY);

  const tX = 60, tY = 30, tW = W - 120, tH = H - 60;
  drawRoundRect(tX, tY, tW, tH, 14); ctx.fillStyle = C.surface; ctx.fill();
  ctx.strokeStyle = C.border; ctx.lineWidth = 1; ctx.stroke();

  drawRoundRect(tX, tY, tW, 44, 14); ctx.fillStyle = '#141420'; ctx.fill();
  ctx.fillStyle = C.surface; ctx.fillRect(tX + 1, tY + 30, tW - 2, 14);

  const dY = tY + 22;
  [[tX+22,'#ff5f57'],[tX+42,'#ffbd2e'],[tX+62,'#28c840']].forEach(([dx,c]) => {
    ctx.beginPath(); ctx.arc(dx, dY, 6, 0, Math.PI*2);
    ctx.fillStyle = c; ctx.globalAlpha = 0.85; ctx.fill(); ctx.globalAlpha = 1;
  });
  // CUSTOMIZE: terminal title bar path
  ctx.font = '500 13px "SF Mono", monospace'; ctx.fillStyle = C.dim;
  ctx.fillText('~/project-path · claude', tX + 86, dY + 4);
  const secs = Math.floor(elapsed / 1000);
  ctx.textAlign = 'right'; ctx.font = '12px "SF Mono", monospace';
  ctx.fillText(`${Math.floor(secs/60)}:${String(secs%60).padStart(2,'0')}`, tX + tW - 18, dY + 4);
  ctx.textAlign = 'left';

  const content = events.filter(e => e.t <= elapsed && ['prompt','ai','code'].includes(e.type));
  const lH = 48, sY = tY + 78, sX = tX + 32;
  const maxL = Math.floor((tH - 90) / lH);
  content.slice(-maxL).forEach((ev, i) => {
    const y = sY + i * lH, age = elapsed - ev.t;
    ctx.globalAlpha = easeOut(Math.min(age / 350, 1));
    const fs = 20;
    if (ev.type === 'prompt') {
      ctx.font = `bold ${fs}px "SF Mono", monospace`; ctx.fillStyle = C.prompt;
      ctx.fillText('> ', sX, y);
      const pw = ctx.measureText('> ').width;
      ctx.font = `${fs}px "SF Mono", monospace`; ctx.fillStyle = C.text;
      const ch = Math.min(Math.floor(age / 28), ev.text.length);
      ctx.fillText(ev.text.substring(0, ch), sX + pw, y);
      if (ch < ev.text.length && Math.floor(elapsed/530)%2===0) {
        ctx.fillStyle = C.violet;
        ctx.fillRect(sX + pw + ctx.measureText(ev.text.substring(0,ch)).width + 2, y-15, 11, 22);
      }
    } else if (ev.type === 'ai') {
      ctx.font = `${fs}px "SF Mono", monospace`; ctx.fillStyle = C.ai;
      ctx.fillText(ev.text.substring(0, Math.min(Math.floor(age/22), ev.text.length)), sX+12, y);
    } else if (ev.type === 'code') {
      ctx.font = `${fs-1}px "SF Mono", monospace`; ctx.fillStyle = C.code;
      ctx.fillText(ev.text.substring(0, Math.min(Math.floor(age/18), ev.text.length)), sX+12, y);
    }
    ctx.globalAlpha = 1;
  });

  const pY = tY+tH-14, pX = tX+20, pW = tW-40;
  ctx.fillStyle = C.border; ctx.fillRect(pX, pY, pW, 2);
  const maxT = events[events.length-1].t;
  const g = ctx.createLinearGradient(pX,0,pX+pW,0);
  g.addColorStop(0,C.rust); g.addColorStop(1,C.gold);
  ctx.fillStyle = g; ctx.fillRect(pX, pY, Math.max((elapsed/maxT)*pW,2), 2);
  ctx.restore();
}

function drawImageReveal(elapsed) {
  const reveals = events.filter(e => e.type==='image-reveal' && e.t<=elapsed);
  const cur = reveals[reveals.length-1]; if (!cur) return;
  const age = elapsed - cur.t, img = images[cur.key];
  ctx.fillStyle = C.bg; ctx.fillRect(0,0,W,H);

  const iW=520, iH=620, iX=W-iW-60, iY=(H-iH)/2;
  ctx.globalAlpha = easeOut(Math.min(age/800,1));
  ctx.save(); drawRoundRect(iX,iY,iW,iH,8); ctx.clip();
  drawImageCover(img, iX, iY, iW, iH); ctx.restore();

  ctx.globalAlpha = Math.max(easeOut(Math.min((age-400)/600,1)),0);
  const lX=80, lY=H/2;
  ctx.font='500 12px -apple-system, sans-serif'; ctx.fillStyle=C.dim;
  // CUSTOMIZE: image reveal label
  ctx.fillText('PROJECT LABEL', lX, lY-50);
  const parts = cur.label.split(' · ');
  ctx.font='600 36px -apple-system, sans-serif'; ctx.fillStyle=C.text;
  ctx.fillText(parts[0], lX, lY-10);
  if (parts[1]) { ctx.font='300 22px -apple-system, sans-serif'; ctx.fillStyle=C.gold; ctx.fillText(parts[1], lX, lY+25); }
  ctx.globalAlpha = 1;
}

function drawImageGrid(elapsed) {
  const grids = events.filter(e => e.type==='image-grid' && e.t<=elapsed);
  const cur = grids[grids.length-1]; if (!cur) return;
  const age = elapsed - cur.t;
  ctx.fillStyle = C.bg; ctx.fillRect(0,0,W,H);

  const gap=16, tW=W-160, tH=H-120, cW=(tW-gap)/2, cH=(tH-gap)/2;
  cur.keys.forEach((key, i) => {
    const col=i%2, row=Math.floor(i/2);
    const x=80+col*(cW+gap), y=60+row*(cH+gap), delay=i*400, ca=age-delay;
    if (ca<0) return;
    const fade=easeOut(Math.min(ca/600,1)), scale=lerp(0.92,1,easeOut(Math.min(ca/800,1)));
    ctx.globalAlpha=fade;
    ctx.save();
    const cx=x+cW/2, cy=y+cH/2;
    ctx.translate(cx,cy); ctx.scale(scale,scale); ctx.translate(-cx,-cy);
    drawRoundRect(x,y,cW,cH,10); ctx.clip();
    drawImageCover(images[key], x, y, cW, cH);
    ctx.restore(); ctx.globalAlpha=1;
  });
}

function drawFrame(elapsed) {
  ctx.fillStyle = C.bg; ctx.fillRect(0,0,W,H);
  const mode = getActiveMode(elapsed);
  if (mode==='title-card') drawTitleCard(elapsed);
  else if (mode==='image-reveal') drawImageReveal(elapsed);
  else if (mode==='image-grid') drawImageGrid(elapsed);
  else drawTerminal(elapsed);

  ctx.globalAlpha=0.2; ctx.font='bold 13px -apple-system, sans-serif';
  ctx.fillStyle=C.dim; ctx.textAlign='right';
  ctx.fillText('codevibing', W-24, H-12);
  ctx.textAlign='left'; ctx.globalAlpha=1;

  const maxT=events[events.length-1].t;
  ctx.fillStyle='rgba(255,255,255,0.04)'; ctx.fillRect(0,H-3,W,3);
  const g=ctx.createLinearGradient(0,0,W,0);
  g.addColorStop(0,C.rust); g.addColorStop(1,C.violet);
  ctx.fillStyle=g; ctx.fillRect(0,H-3,Math.max((elapsed/maxT)*W,2),3);
}

function animate(ts) {
  if (!startTime) startTime = ts;
  currentElapsed = ts - startTime;
  drawFrame(currentElapsed);
  const maxT = events[events.length-1].t;
  if (currentElapsed < maxT + 2000) {
    animFrame = requestAnimationFrame(animate);
  } else {
    animRunning = false;
  }
}

function play() {
  startTime = null; zoom=1; zoomTarget=1; panY=0; panYTarget=0;
  currentElapsed = 0; animRunning = true;
  if (animFrame) cancelAnimationFrame(animFrame);
  animFrame = requestAnimationFrame(animate);
}

function jumpTo(t) {
  startTime = performance.now() - t;
  currentElapsed = t;
  if (!animRunning) {
    animRunning = true;
    animFrame = requestAnimationFrame(animate);
  }
}

canvas.addEventListener('click', () => {
  const maxT = events[events.length - 1].t;
  if (!animRunning || currentElapsed >= maxT) {
    play(); return;
  }
  const next = events.find(e => e.t > currentElapsed + 200);
  if (next) {
    jumpTo(next.t);
  } else {
    jumpTo(maxT);
  }
});

function autoplay() {
  if (imagesLoaded >= Object.keys(imageSources).length) { play(); return; }
  if (imagesLoaded > 0) { play(); return; }
  setTimeout(play, 2000);
}
setTimeout(autoplay, 500);
</script>
</body>
</html>
```

## Step 4: Update the Gallery

Add a new entry to the `sessions` array in `src/app/sessions/page.tsx`:

```typescript
{
  slug: "<slug>",
  title: "Project Title",
  subtitle: "Short description",
  thumbnail: "/<slug>/thumbnail-image.png",
  date: "Mon YYYY",
  duration: "1:XX",  // total timeline seconds formatted as m:ss
  tool: "Claude Code",
  prompts: 20,       // number of prompt events in timeline
},
```

## Event Types Reference

| Type | Fields | Description |
|------|--------|-------------|
| `title-card` | `bgImage, title, subtitle, meta` | Full-screen image with text overlay. Use for opening and closing. |
| `terminal-start` | — | Opens the terminal window. Use once at the beginning. |
| `terminal-resume` | — | Returns to terminal after an image scene. |
| `prompt` | `text` | User prompt with typewriter animation and green `>` prefix. |
| `ai` | `text` | AI response in blue. |
| `code` | `text` | Code output in yellow. |
| `image-reveal` | `key, label` | Full-screen single image reveal. Label format: `"Title · Detail"` |
| `image-grid` | `keys` | 2x2 grid of 4 images with staggered fade-in. |
| `end` | — | Marks the end of the animation. |

## Timeline Pacing Guidelines

- **Title card**: 5 seconds before first terminal event
- **Between prompts**: 2.5-3.5 seconds apart
- **Before image-reveal**: leave ~2.5s gap after last prompt
- **Image-reveal duration**: ~6 seconds visible before terminal-resume
- **Image-grid duration**: ~8 seconds visible before terminal-resume
- **End title card**: ~5.5 seconds before `end` event
- **Total runtime**: 80-110 seconds (aim for ~1:30)

## Customization Checklist

When creating a new session, customize these items:
- [ ] `<title>` and OG meta tags
- [ ] Color scheme (`accent` and `gold` in `C` object)
- [ ] `imageSources` dictionary (keys and paths)
- [ ] Terminal title bar path (e.g., `~/project-path · claude`)
- [ ] Image reveal label text (e.g., `'PROJECT NAME'`)
- [ ] All events in the timeline (prompts, images, pacing)
- [ ] Gallery entry in `page.tsx`

## Color Palette Examples

| Project | accent | gold | Vibe |
|---------|--------|------|------|
| Garden of Eden | `#c4956a` | `#C4A35A` | Warm desert |
| Design Therapy | `#7c9885` | `#c4956a` | Sage green |
| Alchemy Deck | `#C4A35A` | `#C4A35A` | Alchemical gold |
| Futures Deck | `#3b82f6` | `#C4A35A` | Electric blue |
| Therapy Cards | `#c67b5c` | `#C4A35A` | Warm terracotta |
| dereklomas.me | `#8B7355` | `#D4A76A` | Scholarly brown |

## Deployment

All session files go in `/Users/dereklomas/codevibing2/`:
- HTML files: `public/sessions/<slug>.html`
- Images: `public/<slug>/`
- Gallery: `src/app/sessions/page.tsx`

Deploy: `vercel --prod` from the codevibing2 directory.
