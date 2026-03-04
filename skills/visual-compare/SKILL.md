---
name: visual-compare
description: Visual comparison of a reference app against a replica build. Screenshots both via Chrome DevTools, uses Claude vision to identify differences, generates gap reports. Use when asked to compare, audit visuals, check replication fidelity, or run a visual diff.
---

# Visual Compare Skill

Compare a reference application against a replica build using Chrome DevTools screenshots and Claude's vision capabilities.

## When to Use

- `/compare` — run a full comparison cycle
- "Compare our app against the reference"
- "What visual differences remain?"
- "Audit the UI against the original"
- "Take reference screenshots"
- "How close is our replica?"

## Prerequisites

- **Chrome DevTools MCP** must be connected (provides screenshot and navigation tools)
- A deployed replica to compare against (Vercel production URL or localhost)
- Reference screenshots in `docs/screenshots/` OR access to the reference app

## The Comparison Loop

```
1. Screenshot Reference  →  Chrome DevTools on reference app
2. Extract Source         →  Download HTML/CSS/JS via network requests
3. Screenshot Replica    →  Chrome DevTools on deployed replica
4. Vision Compare        →  Read both images, identify differences
5. Gap Report            →  Structured list of visual gaps
6. File Issues           →  GitHub issues with screenshots + source file references
7. Fix & Repeat          →  Address gaps, re-compare
```

## Step 1: Screenshot the Reference App

Use Chrome DevTools MCP to navigate and screenshot the reference application.

```
For each screen/state:
1. navigate_page to the reference URL
2. Wait for content to load (wait_for or take_snapshot to verify)
3. take_screenshot with filePath to docs/screenshots/{screen-name}.png
4. For interactive states: click/fill elements, then screenshot again
```

**Important**: Save reference screenshots with descriptive names. These are ground truth and shouldn't change often.

### Handling Login/Auth

If the reference app requires login:
1. Navigate to login page
2. Use take_snapshot to find form fields
3. Use fill_form to enter credentials
4. Click login button
5. Wait for redirect, then proceed with screenshots

### Capturing Multiple States

For screens with tabs, modals, or expandable sections:
1. Screenshot the default state first
2. Click to reveal each state
3. Screenshot each with a descriptive suffix: `{screen}-{state}.png`

Example: `notebook-journal.png`, `notebook-wordbank.png`, `notebook-mywork.png`

## Step 1.5: Extract Source Files

After screenshotting, use Chrome DevTools network panel to download the actual implementation:

```
1. list_network_requests with resourceTypes ["document", "stylesheet", "script"]
2. For each relevant CSS/JS/HTML file:
   get_network_request with responseFilePath to save locally
3. Save to docs/reference-source/{css,js}/ directory
```

This gives you the actual source code of the reference app — CSS for animations, JS for interactions, HTML templates for structure. Far more useful than screenshots alone for understanding *how* something works, not just how it looks.

**Key files to prioritize:**
- Page-specific CSS (e.g., `notebook.css`, `library.css`) — contains all visual styling
- Page HTML templates — shows DOM structure and class names
- Interaction JS (carousel logic, drag-drop, animations)
- Skip vendor libraries (jquery, underscore, etc.)

**Reference these in GitHub issues** so other developers/agents can read the original implementation when working on replica features.

## Step 2: Screenshot the Replica

Two approaches:

### A) Chrome DevTools (preferred for accuracy)
Navigate to the deployed replica URL and screenshot each matching route.
Save to `docs/screenshots/current/{screen-name}.png`.

### B) Playwright Script (for automation)
```bash
node scripts/visual-compare.mjs --url https://your-deploy.vercel.app
```
This screenshots all configured routes automatically.

## Step 3: Vision Compare

This is the core value — use Claude's multimodal capabilities.

For each screen pair (reference + replica):

1. **Read both images** using the Read tool on the screenshot files
2. **Analyze differences** systematically:

```
For each screenshot pair, evaluate:

LAYOUT
- [ ] Same number of sections/regions
- [ ] Same spatial arrangement
- [ ] Same proportions and sizing

COLORS
- [ ] Background colors match
- [ ] Text colors match
- [ ] Accent/brand colors match
- [ ] Gradients match

TYPOGRAPHY
- [ ] Font sizes match
- [ ] Font weights match
- [ ] Text alignment matches
- [ ] Line spacing matches

CONTENT
- [ ] Same elements present (buttons, icons, labels)
- [ ] Same number of items in lists/grids
- [ ] Images/icons present and similar

INTERACTIVITY
- [ ] Same interactive affordances visible
- [ ] Hover/active states similar
- [ ] Navigation elements match

POLISH
- [ ] Border radius matches
- [ ] Shadows match
- [ ] Spacing/padding consistent
- [ ] Overall "feel" is similar
```

3. **Rate fidelity** on a 1-10 scale per screen
4. **List specific gaps** ordered by visual impact

## Step 4: Gap Report

Output a structured report:

```markdown
## Visual Comparison Report — {date}

### Summary
- Screens compared: N
- Average fidelity: X/10
- Critical gaps: N
- Minor gaps: N

### Per-Screen Results

#### {Screen Name} — {score}/10
**Reference**: docs/screenshots/{ref}.png
**Replica**: docs/screenshots/current/{cur}.png

Gaps (by impact):
1. [HIGH] Description of major visual difference
2. [MED] Description of moderate difference
3. [LOW] Description of minor difference

...repeat for each screen...

### Priority Fix List
1. {Most impactful fix across all screens}
2. {Next most impactful}
...
```

### Filing GitHub Issues

For significant gaps, create GitHub issues:
```bash
gh issue create --title "Visual gap: {description}" --body "..."
```

Label with priority and link to the relevant screenshots.

## Configuration

### Route Mapping

Each project should define a route mapping between reference and replica:

```javascript
const ROUTES = [
  {
    path: "/dashboard/library",     // replica route
    ref: "library-main.png",        // reference screenshot filename
    label: "Library Carousel",      // human-readable label
    refUrl: "https://...",          // optional: reference app URL for this screen
  },
  // ...
];
```

This mapping lives in `scripts/visual-compare.mjs` for the automated script, but the skill can also work ad-hoc by reading whatever screenshots exist.

### Screenshot Directories

```
docs/screenshots/           — reference screenshots (ground truth)
docs/screenshots/current/   — latest replica screenshots
docs/screenshots/compare.html — generated HTML comparison
```

## Tips

- **Screenshot at consistent viewport sizes** — 1280x800 is the default
- **Wait for animations to settle** — use wait_for or add delays after navigation
- **Screenshot the same state** — if the reference shows an expanded section, expand it in the replica too
- **Count elements** — a quick way to catch missing content is to count items in lists, cards in grids, tabs in navigation
- **Check dark backgrounds** — differences in dark colors are hard to spot; zoom in mentally on header bars, footers, sidebars
- **Don't over-report** — focus on gaps a user would notice, not pixel-perfect differences. Content differences (different book titles, dummy text) are expected and not gaps.
