---
name: html-to-svg
description: Convert rendered HTML/CSS to outlined SVG vectors. Renders with Puppeteer at high resolution, traces with potrace to produce clean vector paths. Use when asked to create an SVG logo, convert text to outlines, vectorize a component, or export HTML as a vector graphic.
---

# HTML to Outlined SVG

Convert any HTML/CSS rendering to a true outlined SVG with vector paths. No font dependencies — all text is converted to paths.

## Pipeline

```
HTML/CSS → Puppeteer (8x render) → sharp (invert) → ImageMagick (PBM) → potrace (trace) → SVG
```

## Requirements

All available via brew/npm:
- `puppeteer` (npm) — headless Chrome rendering
- `sharp` (npm) — image processing
- `imagemagick` (brew) — format conversion
- `potrace` (brew) — bitmap-to-vector tracing

Check/install:
```bash
which potrace magick || brew install potrace imagemagick
npm list puppeteer sharp || npm install --no-save puppeteer sharp
```

## Step 1: Render HTML at High Resolution

Use Puppeteer with `deviceScaleFactor: 8` for clean traces. Load web fonts, match exact CSS from the source. Screenshot the target element with `omitBackground: false`.

```javascript
import puppeteer from 'puppeteer';

const browser = await puppeteer.launch();
const page = await browser.newPage();
await page.setViewport({ width: 800, height: 200, deviceScaleFactor: 8 });

await page.setContent(`
  <html>
  <head>
    <link href="https://fonts.googleapis.com/css2?family=YOUR+FONT&display=swap" rel="stylesheet">
    <style>
      * { margin: 0; padding: 0; }
      body { background: black; display: flex; align-items: center; height: 100vh; }
      /* Match exact CSS from source */
    </style>
  </head>
  <body>
    <!-- Exact HTML from source -->
  </body>
  </html>
`, { waitUntil: 'networkidle0' });

await new Promise(r => setTimeout(r, 500)); // wait for fonts
const element = await page.$('.target-element');
await element.screenshot({ path: '/tmp/hires.png', omitBackground: false });
await browser.close();
```

Key points:
- `deviceScaleFactor: 8` gives enough resolution for clean vector traces
- `waitUntil: 'networkidle0'` ensures web fonts are loaded
- Add a 500ms delay after content load for font rendering
- Use `omitBackground: false` to capture the background color
- Screenshot the specific element, not the full page

## Step 2: Invert for Tracing

Potrace traces dark regions. For white-on-dark designs, invert first:

```javascript
const sharp = require('sharp');
await sharp('/tmp/hires.png')
  .negate({ alpha: false })
  .toFile('/tmp/inverted.png');
```

## Step 3: Convert to PBM and Trace

```bash
magick /tmp/inverted.png -threshold 50% /tmp/trace.pbm
potrace /tmp/trace.pbm -s -o /path/to/output.svg --tight
```

Flags:
- `-s` — SVG output
- `--tight` — crop to content bounds
- `-t N` — despeckle threshold (default 2, increase for noisy images)
- `-a N` — corner smoothing (default 1.0, decrease for sharper corners)

## Step 4: Fix Colors

Potrace outputs black paths on transparent. For white-on-dark:

1. Remove the XML doctype and metadata
2. Add a background `<rect>` with your dark color
3. Change `fill="#000000"` to `fill="#ffffff"` on the path group

The SVG structure from potrace:
```xml
<svg viewBox="...">
  <rect width="..." height="..." fill="#1a1a1a"/>  <!-- add this -->
  <g transform="..." fill="#ffffff" stroke="none">  <!-- change fill -->
    <path d="..."/>
    <!-- vector paths -->
  </g>
</svg>
```

## Tips

- **Match the source exactly**: Copy HTML and CSS verbatim from the source component. Don't approximate — use the same font family, weight, size, letter-spacing, gap, etc.
- **Verify with a PNG first**: Before tracing, render at 1x and compare side-by-side with the original to confirm it matches.
- **Variable fonts**: Google Fonts often serves variable fonts. A single woff2 file covers multiple weights — no need to download separate files.
- **High contrast only**: Potrace works best on high-contrast images (white on black or vice versa). For complex multi-color designs, trace each color layer separately.
- **Circle quality**: Geometric shapes like circles trace well at 8x. If circles look faceted, increase to `deviceScaleFactor: 10` or `12`.
- **Clean up**: The script files (`make-logo-svg.mjs`, etc.) are throwaway. Delete after generating the SVG.
