#!/usr/bin/env node
/**
 * Card Deck Renderer Template
 *
 * Customize: categoryStyles, generateCardHTML(), card dimensions
 * Output: assets/cards-final/ (900x1500px, rounded corners)
 */

import puppeteer from 'puppeteer';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';
import { createRequire } from 'module';

const require = createRequire(import.meta.url);
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const PROJECT_DIR = path.join(__dirname, '..');
const CARDS_DATA = require('./cards.json');
const ARTWORK_DIR = path.join(PROJECT_DIR, 'assets', 'artwork');
const OUTPUT_DIR = path.join(PROJECT_DIR, 'assets', 'cards-final');

// Card dimensions
const CARD_WIDTH = 900;
const CARD_HEIGHT = 1500;

// ============================================
// CUSTOMIZE: Category styles
// ============================================
const categoryStyles = {
  example_category: {
    bg: 'linear-gradient(to bottom, #1a3d4a, #0f2830)',
    color: '#81D4FA',
    name: 'Display Name'
  },
  // Add more categories...
};

// ============================================
// Build card list from JSON
// ============================================
function buildCardList() {
  const cards = [];

  for (const [category, cardList] of Object.entries(CARDS_DATA)) {
    if (category === 'meta') continue; // Skip metadata

    for (const card of cardList) {
      cards.push({
        id: card.id,
        category: category,
        name: card.name,
        subtitle: card.subtitle,
        description: card.description,
        quote: card.quote,
        quote_source: card.quote_source,
        // Add category-specific fields as needed
      });
    }
  }

  return cards;
}

// ============================================
// CUSTOMIZE: Generate HTML for each card
// ============================================
function generateCardHTML(card, imageDataUrl) {
  const style = categoryStyles[card.category] || {
    bg: 'linear-gradient(to bottom, #2a2a2a, #151515)',
    color: '#888888',
    name: card.category
  };
  const hasImage = !!imageDataUrl;

  // Build content based on card type
  let promptHTML = `<p class="desc">${card.description || ''}</p>`;
  let quoteText = card.quote ? `"${card.quote}" —${card.quote_source || ''}` : '';

  return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@400;500;600;700&family=Cormorant+Garamond:ital,wght@0,400;0,500;0,600;1,400;1,500&display=swap" rel="stylesheet">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      width: ${CARD_WIDTH}px;
      height: ${CARD_HEIGHT}px;
      overflow: hidden;
      font-family: 'Cormorant Garamond', serif;
    }
    .card {
      width: 100%;
      height: 100%;
      background: #0d0a08;
      display: flex;
      flex-direction: column;
      border-radius: 40px;
      overflow: hidden;
    }
    .artwork {
      height: 60%;
      overflow: hidden;
      background: linear-gradient(135deg, #2a2420 0%, #1a1612 100%);
    }
    .artwork img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      object-position: center;
    }
    .artwork-placeholder {
      width: 100%;
      height: 100%;
      display: flex;
      align-items: center;
      justify-content: center;
      background: ${style.bg};
    }
    .placeholder-icon {
      font-size: 180px;
      color: ${style.color};
      opacity: 0.15;
    }
    .text-panel {
      padding: 28px 80px 16px;
      background: ${style.bg};
      border-top: 6px solid ${style.color}40;
    }
    .category {
      font-family: 'Cinzel', serif;
      font-size: 22px;
      font-weight: 600;
      letter-spacing: 0.2em;
      text-transform: uppercase;
      margin-bottom: 8px;
      color: ${style.color};
    }
    .title {
      font-family: 'Cinzel', serif;
      font-size: 52px;
      font-weight: 600;
      color: #fff;
      line-height: 1.1;
      letter-spacing: 0.02em;
    }
    .subtitle {
      font-family: 'Cormorant Garamond', serif;
      font-size: 34px;
      font-style: italic;
      color: rgba(255,255,255,0.65);
      margin-top: 6px;
    }
    .prompt-area {
      padding: 20px 60px;
      font-size: 26px;
      line-height: 1.4;
      color: rgba(255,255,255,0.92);
      flex: 1;
      background: ${style.bg};
      font-family: 'Cormorant Garamond', serif;
      font-weight: 500;
    }
    .prompt-area .desc {
      margin-bottom: 14px;
    }
    .prompt-area .label {
      color: ${style.color};
      font-weight: 600;
    }
    .quote {
      font-family: 'Cormorant Garamond', serif;
      font-style: italic;
      color: ${style.color};
      font-size: 20px;
      padding: 12px 60px 40px;
      background: ${style.bg};
      border-top: 2px solid ${style.color}30;
      line-height: 1.3;
      opacity: 0.85;
    }
  </style>
</head>
<body>
  <div class="card">
    <div class="artwork">
      ${hasImage
        ? `<img src="${imageDataUrl}" alt="${card.name}">`
        : `<div class="artwork-placeholder">
             <div class="placeholder-icon">◆</div>
           </div>`
      }
    </div>
    <div class="text-panel">
      <div class="category">${style.name}</div>
      <div class="title">${card.name}</div>
      ${card.subtitle ? `<div class="subtitle">${card.subtitle}</div>` : ''}
    </div>
    <div class="prompt-area">${promptHTML}</div>
    ${quoteText ? `<div class="quote">${quoteText}</div>` : ''}
  </div>
</body>
</html>`;
}

// ============================================
// Render card to PNG
// ============================================
async function renderCard(browser, html, outputPath) {
  const page = await browser.newPage();
  await page.setViewport({ width: CARD_WIDTH, height: CARD_HEIGHT });
  await page.setContent(html, { waitUntil: 'load', timeout: 60000 });
  await new Promise(r => setTimeout(r, 500)); // Wait for fonts
  await page.screenshot({ path: outputPath, type: 'png' });
  await page.close();
}

// ============================================
// Main
// ============================================
async function main() {
  console.log('Card Deck Renderer');
  console.log('='.repeat(50));
  console.log(`Output size: ${CARD_WIDTH}x${CARD_HEIGHT} pixels\n`);

  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  }

  const cards = buildCardList();
  console.log(`Rendering ${cards.length} cards...\n`);

  const browser = await puppeteer.launch({ headless: true });

  for (let i = 0; i < cards.length; i++) {
    const card = cards[i];
    const artPath = path.join(ARTWORK_DIR, `${card.id}.png`);
    const outputPath = path.join(OUTPUT_DIR, `${card.id}.png`);

    let imageDataUrl = null;
    if (fs.existsSync(artPath)) {
      const imageBuffer = fs.readFileSync(artPath);
      const base64 = imageBuffer.toString('base64');
      imageDataUrl = `data:image/png;base64,${base64}`;
    }

    const html = generateCardHTML(card, imageDataUrl);
    await renderCard(browser, html, outputPath);

    const status = imageDataUrl ? '' : '(no artwork)';
    console.log(`[${i + 1}/${cards.length}] ${card.category}/${card.name} ${status}`);
  }

  await browser.close();

  console.log('\n' + '='.repeat(50));
  console.log(`Done! Rendered ${cards.length} cards to:`);
  console.log(OUTPUT_DIR);
}

main().catch(console.error);
