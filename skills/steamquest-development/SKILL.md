---
name: steamquest-development
description: Develop educational STEAMQuest games with Three.js interactives, ElevenLabs voice acting, and Vercel deployment. Use when creating or modifying quests in the quests-app framework.
---

# STEAMQuest Development Skill

Create educational interactive quests with voice acting, 3D visualizations, and assessments.

## Project Location

```
/Users/dereklomas/quests-app/
```

## Quest Structure

Each quest lives in `src/GAME_DATA/{quest-id}/`:

```
src/GAME_DATA/{quest-id}/
├── sceneData.ts          # Scene definitions, flow, and audioUrl references
├── locales/
│   └── en.json           # All text content, dialogue, questions
├── configs/              # Question/interaction configurations
│   ├── q1-*.ts
│   └── ...
├── interactives/         # React/Three.js components
│   ├── interface.ts      # TypeScript interfaces
│   └── *.tsx             # Interactive components
└── assets/
    ├── images/           # Background images, illustrations
    └── audio/            # Voice lines, background music
```

## Key Files

### sceneData.ts

Defines scene flow with types:
- `one-at-a-time` - Sequential dialogue
- `split-screen-chat` - Dialogue + interactive side panel
- `turn-based-chat` - Conversation format
- `end-screen` - Quest completion

```typescript
{
  type: 'split-screen-chat',
  background: { url: './assets/images/bg1.png', alt: 'Description' },
  leftConfig: {
    interactive: () => import('./interactives/my-interactive'),
    interactionState: { type: 'da-vinci-tree' }
  },
  dialogs: [
    {
      character: 'char1',
      bodyAsHtml: 'scenes.act1.d1',
      audioUrl: '/assets/audio/quest_act1_d1_C1_en.mp3',
    }
  ]
}
```

### locales/en.json

All translatable text:

```json
{
  "scenes": {
    "common": {
      "char1": "Character Name",
      "char2": "Mentor Name",
      "char1_description": "Student, curious",
      "char2_description": "Expert, knowledgeable"
    },
    "act1": {
      "d1": "First dialogue line with <strong>HTML</strong> support.",
      "d2": "Second line..."
    },
    "q1": {
      "heading": "Question 1",
      "stem": "Question text with <strong>formatting</strong>"
    }
  },
  "scenesList": {
    "scene_1": "Title Screen",
    "scene_2": "Introduction"
  }
}
```

### configs/*.ts (Questions)

Radio button questions:
```typescript
import { RadioButtonInteraction } from '../interactives/interface';

const interaction: RadioButtonInteraction = {
  type: 'radio-button',
  title: 'scenes.q1.heading',
  prefixText: 'scenes.q1.stem',
  options: [
    { label: 'Option A', value: '0' },
    { label: 'Option B', value: '1' },
  ],
  correctnessFunction: (selectedValue: string) => selectedValue === '0',
};

export default interaction;
```

Free response questions:
```typescript
import { InputBoxInteraction } from '../interactives/interface';

const interaction: InputBoxInteraction = {
  type: 'input-box',
  title: 'scenes.q2.heading',
  prefixText: 'scenes.q2.stem',
  placeholder: 'Enter your answer...',
  correctAnswer: '42',
  tolerance: 0.1,
};

export default interaction;
```

## Three.js Interactives

### interface.ts

```typescript
export interface DaVinciTreeInteraction {
  type: 'da-vinci-tree';
  ariaLabel?: string;
}

export interface RadioButtonInteraction {
  type: 'radio-button';
  title: string;
  prefixText?: string;
  options: { label: string; value: string }[];
  correctnessFunction?: (selectedValue: string) => boolean;
}

export type InteractiveProps =
  | DaVinciTreeInteraction
  | RadioButtonInteraction;
```

### Component Template

```tsx
import React, { useState, useEffect, useRef, useCallback } from 'react';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';

interface MyInteractiveProps {
  interaction: { type: 'my-interactive'; ariaLabel?: string };
}

const MyInteractive: React.FC<MyInteractiveProps> = ({ interaction }) => {
  const containerRef = useRef<HTMLDivElement>(null);
  const sceneRef = useRef<THREE.Scene | null>(null);

  // Initialize Three.js
  const initThree = useCallback(() => {
    if (!containerRef.current) return;
    const scene = new THREE.Scene();
    // ... setup camera, renderer, lights, controls
  }, []);

  useEffect(() => {
    initThree();
    return () => { /* cleanup */ };
  }, [initThree]);

  return (
    <div className="w-full h-full flex flex-col">
      <div ref={containerRef} className="flex-1" style={{ minHeight: '280px' }} />
      <div className="bg-white/95 rounded-b-lg p-3">
        {/* Controls */}
      </div>
    </div>
  );
};

export default MyInteractive;
```

## ElevenLabs Voice Generation

### Voice Selection

Available voices (check with API):
- **Jessica** (cgSgspJ2msm6clMCkdW9) - Young, playful female
- **Matilda** (XrExE9yKIg1WjnnlVkGX) - Professional female
- **Brian** (nPczCjzI2devNBz1zQrb) - Deep, comforting male
- **Eric** (cjVigY5qzO86Huf0OWal) - Smooth, trustworthy male

List all voices:
```bash
curl -s "https://api.elevenlabs.io/v1/voices" \
  -H "xi-api-key: $ELEVENLABS_API_KEY" | \
  python3 -c "import json,sys; [print(f\"{v['voice_id']}: {v['name']}\") for v in json.load(sys.stdin)['voices']]"
```

### generate-audio.py Script

```python
#!/usr/bin/env python3
import json, os, re, requests, time
from pathlib import Path

ELEVENLABS_API_KEY = os.environ.get('ELEVENLABS_API_KEY')
VOICE_CHAR1 = 'cgSgspJ2msm6clMCkdW9'  # Character 1 voice
VOICE_CHAR2 = 'nPczCjzI2devNBz1zQrb'  # Character 2 voice

OUTPUT_DIR = Path('src/GAME_DATA/{quest-id}/assets/audio')
LOCALE_FILE = Path('src/GAME_DATA/{quest-id}/locales/en.json')

# Map dialogue keys to speakers: 'char1' or 'char2'
DIALOGUE_SPEAKERS = {
    'd1': 'char1', 'd2': 'char2', 'd3': 'char1', ...
}

def strip_html(text):
    text = re.sub(r"<div[^>]*>.*?</div>", "", text, flags=re.DOTALL)
    text = re.sub(r'<[^>]+>', '', text)
    # Convert em-dashes to ellipsis for natural pauses
    text = text.replace('\u2014', '...').replace('\u2013', '...')
    return text.strip()

def generate_audio(text, voice_id, output_path):
    url = f"https://api.elevenlabs.io/v1/text-to-speech/{voice_id}"
    headers = {
        "Accept": "audio/mpeg",
        "Content-Type": "application/json",
        "xi-api-key": ELEVENLABS_API_KEY
    }
    data = {
        "text": text,
        "model_id": "eleven_turbo_v2_5",
        "voice_settings": {
            "stability": 0.5,
            "similarity_boost": 0.75,
            "style": 0.3,
            "use_speaker_boost": True
        }
    }
    response = requests.post(url, json=data, headers=headers)
    if response.status_code == 200:
        with open(output_path, 'wb') as f:
            f.write(response.content)
        return True
    return False
```

### Audio File Naming

```
{quest-id}_{act}_{dialogue-key}_{character-code}_en.mp3
```

Example: `da-vinci-trees_act1_d1_C1_en.mp3`

### Adding audioUrl to sceneData

Use a script to add audioUrl references:
```python
pattern = r"(bodyAsHtml: 'scenes\.(act\d+)\.(d\d+)',)"
replacement = f"{match}\\n        audioUrl: '/assets/audio/{quest}_{act}_{key}_{char}_en.mp3',"
```

### Pause/Emphasis in Text

- **Ellipsis** `...` - Natural pause (recommended)
- **Em-dash** `—` - Short pause (convert to `...` in script)
- **CAPS** - Emphasis
- **Period** - Full stop/breath

## Building & Deployment

### Build Command

```bash
cd /Users/dereklomas/quests-app
VITE_GAME_ID={quest-id} npx vite build --base='./'
```

### Deploy to Vercel

```bash
cd /Users/dereklomas/quests-app/dist/{quest-id}
npx vercel --prod --yes
```

### Combined Build + Deploy

```bash
cd /Users/dereklomas/quests-app && \
VITE_GAME_ID={quest-id} npx vite build --base='./' && \
cd dist/{quest-id} && npx vercel --prod --yes
```

## Review Mode

Enable with `?review=true` URL parameter:
- Floating panel in top-right
- Add comments per scene/dialog
- Export feedback as JSON
- Persists in localStorage

Example: `https://my-quest.vercel.app?review=true`

## Question Design Principles

**Questions should be attention checks, not calculations.**

### Do's
- Use **multiple-choice (radio-button)** for most questions
- Test **conceptual understanding**, not calculation ability
- Keep questions answerable **without paper and pencil**
- Use questions to reinforce key concepts just learned
- Label as "Check Your Understanding" instead of "Question X"

### Don'ts
- Avoid questions requiring calculations (V = πr²h with real numbers)
- Don't ask for precise numerical answers
- Don't make the quest feel like a test

### Good Question Examples

```typescript
// Conceptual understanding
"Which shape do we use to model a deciduous tree?"
// Options: Cylinder, Cone, Sphere, Cube

// Attention check
"About what percentage of wood is carbon?"
// Options: 50%, 25%, 75%, 10%

// Application without calculation
"If form factor is 0.5, the actual volume is about..."
// Options: Half the cylinder, Double, Unchanged
```

### Bad Question Examples (Avoid)

```typescript
// Requires calculation
"Calculate V = π × (0.225)² × 22"

// Too precise
"What is the cone volume to 2 decimal places?"

// Complex multi-step
"If 2310 kg × 24.7 plots × 500 hectares..."
```

## Common Patterns

### Adding Images to Dialogue

```json
"d20": "Description text<div style='display: flex; justify-content: center; margin: 20px 0;'><img src='./assets/images/photo.png' alt='Description' style='width: 100%; max-width: 400px; border-radius: 8px;' /></div>"
```

### Interactive Split Screen

In sceneData.ts:
```typescript
{
  type: 'split-screen-chat',
  leftConfig: {
    interactive: () => import('./interactives/my-component'),
    interactionState: { type: 'my-component', ariaLabel: 'Description' }
  },
  dialogs: [...]
}
```

### Question Scenes

```typescript
{
  type: 'split-screen-chat',
  leftConfig: {
    interactive: () => import('./interactives/interactive-radio'),
    interactionState: () => import('./configs/q1-config')
  },
  dialogs: [{ character: 'char2', bodyAsHtml: 'scenes.q1.stem' }]
}
```

## Troubleshooting

### TypeScript Build Errors

Bypass strict tsc for node_modules issues:
```bash
npx vite build  # instead of npm run build
```

### Unused Variables

Comment out unused functions with note:
```typescript
// Reset function kept for future use
// const handleReset = () => {...};
```

Or use underscore prefix:
```typescript
const [, setUnusedState] = useState(0);
```

### Audio Not Playing

1. Check audioUrl path matches file location
2. Ensure files are in assets/audio/
3. Verify file names match sceneData references

### Interactive Not Fitting

Use flex layout:
```tsx
<div className="w-full h-full flex flex-col">
  <div className="flex-1" style={{ minHeight: '280px' }} />
  <div className="bg-white/95 p-3">{/* controls */}</div>
</div>
```

## Reference Projects

- **Da Vinci Trees**: `/Users/dereklomas/quests-app/src/GAME_DATA/da-vinci-trees/`
- **Forest Architect**: `/Users/dereklomas/quests-app/src/GAME_DATA/forest-architect/`
