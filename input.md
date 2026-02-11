# /input - Get human feedback on AI-generated work

A Claude Code skill for collecting feedback on websites, designs, and AI output.

## Commands

### /input setup
Add the feedback widget to your Next.js project.

**Steps:**
1. Copy the widget component:
```bash
curl -o components/InputWidget.tsx https://raw.githubusercontent.com/JDerekLomas/getinput/main/packages/page/InputWidget.tsx
```

2. Create the API route:
```bash
mkdir -p app/api/input
curl -o app/api/input/route.ts https://raw.githubusercontent.com/JDerekLomas/getinput/main/packages/page/route.ts
```

3. Initialize feedback file:
```bash
echo '[]' > input.json
echo 'input.json' >> .gitignore
```

4. Add to your layout.tsx:
```tsx
import InputWidget from "@/components/InputWidget";

// Inside <body>, after {children}:
<InputWidget />
```

5. Visit localhost - you'll see Edit and Comment buttons in the bottom-right corner.

---

### /input check
View pending feedback from input.json.

```bash
cat input.json
```

Parse and display:
- **Text edits**: Show `"original" → "edited"` with selector context
- **Comments**: Show comment text with element reference

---

### /input apply
Apply text edits from feedback to source files.

For each text-edit in input.json:
1. Search source files (app/, components/, pages/) for the exact `original` text
2. Replace with `edited` text
3. Report what was changed and in which file

---

### /input clear
Reset feedback to start fresh.

```bash
echo '[]' > input.json
```

---

### /input share
Generate a share link for others to give feedback.

Add `?getinput` to any page URL:
```
https://your-site.com?getinput
https://your-site.com/about?getinput
http://localhost:3000?getinput
```

When visitors open this link:
1. The feedback widget appears automatically
2. They can Edit text or leave Comments
3. They click "Copy feedback" and paste it back to you
4. You paste their JSON and run `/input apply`

No server needed for reviewers - it's all copy/paste.

---

## How it works

**For you (the developer):**
- Widget shows on localhost by default
- Feedback auto-saves to input.json
- Run `/input check` to see feedback, `/input apply` to make changes

**For reviewers (via share link):**
- Widget appears when they visit your-site.com?getinput
- They leave feedback, copy it, and send it back
- No account needed, works on any site with the widget installed

---

## Source

- GitHub: https://github.com/JDerekLomas/getinput
- Website: https://getinput.io
