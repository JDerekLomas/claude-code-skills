#!/usr/bin/env node
/**
 * AI Artwork Generator Template using MuleRouter
 *
 * Uses Alibaba Wan2.6 text-to-image model via MuleRouter API
 *
 * Usage:
 *   MULEROUTER_API_KEY=sk-mr-xxx npm run generate
 *   MULEROUTER_API_KEY=sk-mr-xxx npm run generate -- --card=card-01
 *   MULEROUTER_API_KEY=sk-mr-xxx npm run generate -- --category=category_name
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const API_KEY = process.env.MULEROUTER_API_KEY;
const API_BASE = 'https://api.mulerouter.ai/vendors/alibaba/v1/wan2.6-t2i/generation';
const OUTPUT_DIR = path.join(__dirname, '..', 'assets', 'artwork');

// ============================================
// CUSTOMIZE: Base style for all cards
// ============================================
const BASE_STYLE = `Soft watercolor illustration, warm earth tones and muted pastels,
gentle brushstrokes, therapeutic and calming mood, abstract human figures or hands,
intimate domestic scenes, flowing organic shapes, no text, no words, no letters,
emotional and evocative, modern art therapy aesthetic, soft lighting, peaceful atmosphere.`;

// ============================================
// CUSTOMIZE: Category-specific style modifiers
// ============================================
const CATEGORY_STYLES = {
  example_category: 'Two abstract figures in a setting, specific colors, mood description,',
  // Add more categories...
};

// ============================================
// CUSTOMIZE: Card-specific prompts
// ============================================
const CARD_PROMPTS = {
  'card-01': 'Specific visual description for this card concept',
  'card-02': 'Another specific visual description',
  // Add all card prompts...
};

// ============================================
// API Functions
// ============================================
async function createTask(prompt) {
  const fullPrompt = `${BASE_STYLE} ${prompt}`;

  const response = await fetch(API_BASE, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${API_KEY}`,
      'Content-Type': 'application/json',
      'User-Agent': 'CardDeck/1.0.0',
    },
    body: JSON.stringify({
      prompt: fullPrompt,
      size: '1440*1440',
      n: 1,
      prompt_extend: false,
    }),
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Failed to create task: ${response.status} - ${error}`);
  }

  const data = await response.json();
  return data?.task_info?.id || data?.id;
}

async function checkTask(taskId) {
  const response = await fetch(`${API_BASE}/${taskId}`, {
    headers: {
      'Authorization': `Bearer ${API_KEY}`,
      'User-Agent': 'CardDeck/1.0.0',
    },
  });

  if (!response.ok) {
    throw new Error(`Failed to check task: ${response.status}`);
  }

  const data = await response.json();
  const status = data?.task_info?.status || data?.status;
  const images = data?.task_info?.result?.images ||
                 data?.task_info?.images ||
                 data?.images ||
                 [];

  return { status, images };
}

async function waitForCompletion(taskId, maxAttempts = 60) {
  console.log(`  Waiting for task ${taskId}...`);

  for (let i = 0; i < maxAttempts; i++) {
    await new Promise(r => setTimeout(r, 5000)); // Poll every 5 seconds

    const { status, images } = await checkTask(taskId);

    if (status === 'completed' || status === 'COMPLETED' || status === 'succeeded') {
      if (images && images.length > 0) {
        return images[0];
      }
      throw new Error('Task completed but no images returned');
    }

    if (status === 'failed' || status === 'FAILED') {
      throw new Error('Task failed');
    }

    process.stdout.write('.');
  }

  throw new Error('Timeout waiting for image generation');
}

async function downloadImage(url, outputPath) {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Failed to download image: ${response.status}`);
  }

  const buffer = await response.arrayBuffer();
  fs.writeFileSync(outputPath, Buffer.from(buffer));
}

async function generateCard(cardId, prompt, categoryStyle) {
  const fullPrompt = `${categoryStyle} ${prompt}`;
  console.log(`\nGenerating: ${cardId}`);
  console.log(`  Prompt: ${fullPrompt.substring(0, 100)}...`);

  try {
    const taskId = await createTask(fullPrompt);
    console.log(`  Task ID: ${taskId}`);

    const imageUrl = await waitForCompletion(taskId);
    console.log(`\n  Image URL: ${imageUrl.substring(0, 50)}...`);

    const outputPath = path.join(OUTPUT_DIR, `${cardId}.png`);
    await downloadImage(imageUrl, outputPath);
    console.log(`  Saved: ${outputPath}`);

    return { cardId, status: 'success', path: outputPath };
  } catch (error) {
    console.error(`  Error: ${error.message}`);
    return { cardId, status: 'error', error: error.message };
  }
}

// ============================================
// Main
// ============================================
async function main() {
  if (!API_KEY) {
    console.error('Error: MULEROUTER_API_KEY environment variable is required');
    console.error('Usage: MULEROUTER_API_KEY=sk-mr-xxx npm run generate');
    process.exit(1);
  }

  // Parse command line arguments
  const args = process.argv.slice(2);
  let filterCard = null;
  let filterCategory = null;

  for (const arg of args) {
    if (arg.startsWith('--card=')) {
      filterCard = arg.replace('--card=', '');
    }
    if (arg.startsWith('--category=')) {
      filterCategory = arg.replace('--category=', '');
    }
  }

  // Ensure output directory exists
  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  }

  console.log('Card Deck - Image Generator');
  console.log('=========================================');
  console.log(`Using MuleRouter API (Wan2.6)`);
  console.log(`Output: ${OUTPUT_DIR}\n`);

  // Build card list
  const cards = [];
  for (const [cardId, prompt] of Object.entries(CARD_PROMPTS)) {
    // Determine category from card ID prefix
    let category = 'unknown';
    // CUSTOMIZE: Add your category detection logic
    // if (cardId.startsWith('domain-')) category = 'life_domains';

    // Apply filters
    if (filterCard && cardId !== filterCard) continue;
    if (filterCategory && category !== filterCategory) continue;

    // Skip if already exists
    const outputPath = path.join(OUTPUT_DIR, `${cardId}.png`);
    if (fs.existsSync(outputPath)) {
      console.log(`Skipping ${cardId} (already exists)`);
      continue;
    }

    cards.push({
      id: cardId,
      prompt: prompt,
      categoryStyle: CATEGORY_STYLES[category] || ''
    });
  }

  if (cards.length === 0) {
    console.log('No cards to generate (all exist or filtered out)');
    return;
  }

  console.log(`Generating ${cards.length} cards...\n`);

  const results = [];
  for (const card of cards) {
    const result = await generateCard(card.id, card.prompt, card.categoryStyle);
    results.push(result);

    // Small delay between requests
    await new Promise(r => setTimeout(r, 2000));
  }

  // Summary
  console.log('\n=========================================');
  console.log('Generation Complete!\n');

  const successful = results.filter(r => r.status === 'success');
  const failed = results.filter(r => r.status === 'error');

  console.log(`Success: ${successful.length}`);
  console.log(`Failed: ${failed.length}`);

  if (failed.length > 0) {
    console.log('\nFailed cards:');
    for (const f of failed) {
      console.log(`  - ${f.cardId}: ${f.error}`);
    }
  }

  // Save results log
  const logPath = path.join(OUTPUT_DIR, 'generation-log.json');
  fs.writeFileSync(logPath, JSON.stringify({
    timestamp: new Date().toISOString(),
    results
  }, null, 2));
  console.log(`\nLog saved to: ${logPath}`);
}

main().catch(console.error);
