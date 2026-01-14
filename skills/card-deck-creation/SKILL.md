---
name: card-deck-creation
description: Create themed card decks with AI-generated artwork, Puppeteer rendering, and web deployment. Use when asked to make a card deck, playing cards, tarot deck, or similar card-based content.
---

# Card Deck Creation Skill

Create complete card decks with custom content, AI-generated artwork, and web deployment.

## Overview

This skill creates card decks by:
1. Defining card content in JSON
2. Generating artwork via MuleRouter API (Wan2.6 text-to-image)
3. Rendering final cards with Puppeteer (HTML to PNG)
4. Deploying a web gallery with rules/instructions

## Project Structure

```
my-deck/
├── src/
│   ├── cards.json              # Card definitions
│   ├── render-cards.js         # Web card renderer (900x1500px)
│   ├── render-print-cards.js   # Print renderer (1050x1750px) [optional]
│   └── generate-images.js      # MuleRouter artwork generator
├── assets/
│   ├── artwork/                # AI-generated artwork (1440x1440)
│   └── cards-final/            # Rendered cards with text
├── web/                        # Optional standalone web deploy
├── package.json
└── README.md
```

## Step 1: Define Card Content (cards.json)

Structure cards by category with consistent fields:

```json
{
  "category_name": [
    {
      "id": "card-01",
      "name": "Card Title",
      "subtitle": "Optional subtitle",
      "description": "Main card text",
      "quote": "Optional quote",
      "quote_source": "Quote attribution"
    }
  ],
  "another_category": [...]
}
```

**Card ID Conventions:**
- Use lowercase with hyphens: `domain-01`, `pattern-05`
- Prefix with category abbreviation for easy filtering
- Sequential numbering within categories

## Step 2: Set Up Renderers

### package.json

```json
{
  "name": "my-deck",
  "type": "module",
  "scripts": {
    "generate": "node src/generate-images.js",
    "render": "node src/render-cards.js"
  },
  "dependencies": {
    "puppeteer": "^24.0.0"
  }
}
```

### render-cards.js Structure

Key components:
1. **Category styles** - Colors and names per category
2. **buildCardList()** - Parse JSON into renderable cards
3. **generateCardHTML()** - Create HTML template for each card
4. **renderCard()** - Puppeteer screenshot

```javascript
// Category color system
const categoryStyles = {
  category_name: {
    bg: 'linear-gradient(to bottom, #1a3d4a, #0f2830)',  // Dark gradient
    color: '#81D4FA',  // Accent color
    name: 'Display Name'
  }
};

// Card dimensions
const CARD_WIDTH = 900;
const CARD_HEIGHT = 1500;
```

### Card HTML Template Pattern

```html
<div class="card">
  <div class="artwork">
    <!-- 60% height, image or placeholder -->
  </div>
  <div class="text-panel">
    <div class="category">${categoryName}</div>
    <div class="title">${cardName}</div>
    <div class="subtitle">${subtitle}</div>
  </div>
  <div class="prompt-area">
    <!-- Category-specific content -->
  </div>
  <div class="quote">${quote}</div>
</div>
```

**Typography:**
- Title font: Cinzel (serif, elegant)
- Body font: Cormorant Garamond (readable serif)
- Import from Google Fonts in HTML template

## Step 3: Generate Artwork (MuleRouter)

### generate-images.js Structure

```javascript
const API_KEY = process.env.MULEROUTER_API_KEY;
const API_BASE = 'https://api.mulerouter.ai/vendors/alibaba/v1/wan2.6-t2i/generation';

// Base style applied to all prompts
const BASE_STYLE = `Soft watercolor illustration, warm earth tones...`;

// Category-specific style modifiers
const CATEGORY_STYLES = {
  category_name: 'Two figures in warm setting, specific mood...'
};

// Individual card prompts
const CARD_PROMPTS = {
  'card-01': 'Specific visual description for this card...'
};
```

### API Workflow

1. **Create task:**
```javascript
const response = await fetch(API_BASE, {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${API_KEY}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    prompt: fullPrompt,
    size: '1440*1440',
    n: 1,
    prompt_extend: false
  })
});
const taskId = data.task_info.id;
```

2. **Poll for completion:**
```javascript
const { status, images } = await checkTask(taskId);
// status: 'completed', 'failed', 'pending'
```

3. **Download image:**
```javascript
const imageUrl = images[0];
await downloadImage(imageUrl, outputPath);
```

### Prompt Writing Tips

- Describe mood, colors, composition
- Use "no text, no words, no letters" to avoid text in images
- Reference art styles: "watercolor", "oil painting", "digital art"
- Describe abstract concepts metaphorically
- Include lighting: "soft golden light", "dramatic shadows"

## Step 4: Render Final Cards

```bash
# Generate artwork first (requires API key)
MULEROUTER_API_KEY=sk-mr-xxx npm run generate

# Render cards with artwork
npm run render
```

The renderer:
1. Reads cards.json
2. Loads artwork from assets/artwork/{card-id}.png
3. Converts to base64 data URL
4. Generates HTML with embedded image
5. Screenshots with Puppeteer
6. Saves to assets/cards-final/

## Step 5: Web Deployment

### Option A: Standalone Site

Create `web/index.html` with:
- Card gallery with category filters
- Rules/instructions section
- Modal for full-size card view
- Copy cards to `web/cards/`

Deploy:
```bash
cd web && npx vercel --prod
```

### Option B: Integrate into Existing Site (Next.js)

1. Copy cards to `public/cards/`
2. Create page component with:
   - Card data array
   - Category filter state
   - Image grid with Next/Image
   - Modal for card zoom
3. Match existing site styling

```tsx
// Example page structure
export function CardDeckContent() {
  const [activeCategory, setActiveCategory] = useState(null);
  const [selectedCard, setSelectedCard] = useState(null);

  return (
    <>
      <CategoryFilter />
      <CardGrid cards={filteredCards} onSelect={setSelectedCard} />
      <Modal card={selectedCard} onClose={() => setSelectedCard(null)} />
    </>
  );
}
```

## Color Palette Examples

**Therapy/Relationship deck:**
- Territory (blue): `#81D4FA` on `#1a3d4a`
- Danger (pink): `#F48FB1` on `#4a1a2c`
- Warning (orange): `#FFCC80` on `#4a3d1a`
- Positive (green): `#A5D6A7` on `#1a4a2e`
- Needs (purple): `#CE93D8` on `#3d1a4a`
- Mode (yellow): `#FFEB3B` on `#4a4a1a`

**Alchemy deck style:**
- Dark backgrounds with light accent text
- 60% artwork / 40% text split
- Cinzel headers, Cormorant Garamond body
- 40px border radius

## Commands Reference

```bash
# Install dependencies
npm install

# Generate artwork for all cards
MULEROUTER_API_KEY=sk-mr-xxx npm run generate

# Generate specific card
MULEROUTER_API_KEY=sk-mr-xxx npm run generate -- --card=card-01

# Generate specific category
MULEROUTER_API_KEY=sk-mr-xxx npm run generate -- --category=category_name

# Render all cards
npm run render

# Deploy web version
npx vercel --prod
```

## Example Decks

- **Alchemy Deck**: `/Users/dereklomas/CardDecks/alchemy-deck/`
- **MFT/Counterfactual Deck**: `/Users/dereklomas/CardDecks/mft-deck/`
- **Template**: `/Users/dereklomas/CardDecks/_template/`

## Troubleshooting

**Artwork generation fails:**
- Check API key is set
- Verify network access (disable sandbox if needed)
- Check MuleRouter API status

**Cards render without images:**
- Ensure artwork exists in assets/artwork/
- Check file naming matches card IDs
- Verify PNG format

**Fonts not loading:**
- Add `waitUntil: 'networkidle0'` to Puppeteer
- Increase delay before screenshot
- Use web-safe fallback fonts

**Vercel deployment missing images:**
- Add images to git or ensure they're in the upload
- Check .vercelignore isn't excluding public/
- Use `--force` flag for fresh deploy
