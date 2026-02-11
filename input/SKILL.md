---
name: input
description: Human-in-the-loop feedback tools for reviewing AI output. Use when asked to review a site, get design feedback, check generated images, or review AI content. Commands include /input check (see feedback), /input apply (apply edits), /input clear (reset), and /input page setup (add widget to project).
---

# /input - Human-in-the-loop review tools

Get human input on AI-generated content. Detects modality from context.

## Default behavior: `/input` or `/input [url]`

The default action is to give the user a review URL they can open in their browser.

### If a URL argument is provided:
Append `?getinput` to the URL and present it to the user:
```
Open this to review: https://example.com?getinput
```
The `?getinput` parameter activates the feedback widget on any deployed site that has InputWidget installed — no `localhost` required.

### If no URL argument is provided:
1. Check if the current project has a Vercel deployment by running: `vercel inspect 2>&1 | head -5`
2. If a production URL exists, append `?getinput` and present it
3. If no deployment, check if dev server is running and suggest `http://localhost:3000?getinput`
4. If neither, tell the user to run `/input page setup` first

Always output the full clickable URL so the user can open it directly.

---

## Modalities

| Mode | Use case | Trigger phrases |
|------|----------|-----------------|
| **page** | Web design feedback | "review the site", "design feedback", "edit the copy" |
| **picks** | Asset selection | "review photos", "select images", "curate these" |
| **sift** | AI output review | "review generations", "check outputs", "refine prompts" |

---

## /input page setup

Add visual feedback widget to current Next.js project.

### Step 1: Copy files
```bash
mkdir -p app/api/input components
cp ~/getinput/packages/page/InputWidget.tsx components/
cp ~/getinput/packages/page/route.ts app/api/input/route.ts
echo '[]' > input.json
echo 'input.json' >> .gitignore
```

### Step 2: Add to layout.tsx
```tsx
import InputWidget from "@/components/InputWidget";

// Inside <body>, after {children}:
<InputWidget allowedHosts={["localhost", "vercel.app"]} />
```

**Important:** Always include `"vercel.app"` in `allowedHosts` so the widget is visible on deployed previews, not just localhost.

### Step 3: Deploy or visit localhost
- **Edit button** (rust/amber): Click text to edit inline
- **Comment button** (blue): Click any element, leave a note

---

## /input check

Read and display pending feedback from `input.json`.

```bash
cat input.json 2>/dev/null || echo "[]"
```

Parse and show:
- **Text edits**: `"Original text" → "Edited text"` (selector for context)
- **Comments**: `[selector]: "User's comment"`

If no input.json exists, tell user to run `/input page setup` first.

---

## /input apply

For each text-edit in `input.json`:
1. Search source files for exact `original` text using grep
2. Replace with `edited` text using the Edit tool
3. Report what was changed

After applying all edits, clear the feedback:
```bash
echo '[]' > input.json
```

---

## /input clear

Reset all pending feedback:
```bash
echo '[]' > input.json
```

---

## /input picks setup [glob]

Generate a photo/image review UI. User swipes through, picks or rejects with reasons.

### Step 1: Get file list
```bash
ls [glob pattern] # e.g., ls ./public/images/*.jpg
```

### Step 2: Create app/review/page.tsx

Generate a review page with:
- Image display (click to pick)
- Arrow key navigation
- Pick button (green, or tap image)
- Reject with reason input
- Export textarea showing picks and rejects with reasons
- Copy to clipboard button

Key features:
- `items` array with `{ id, src }` for each file
- Keyboard: ←→ navigate, ↑/space to pick
- Picks stored in Set, rejects in Map with reason
- Export format:
```
PICKS:
- /images/photo1.jpg
- /images/photo3.jpg

REJECTS:
- /images/photo2.jpg: too dark
- /images/photo4.jpg: wrong aspect ratio
```

---

## Source files

All source code is at `~/getinput/`:
- `packages/page/InputWidget.tsx` - feedback widget component
- `packages/page/route.ts` - API route for JSON storage
