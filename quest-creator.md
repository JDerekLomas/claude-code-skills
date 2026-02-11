# Quest Creator Skill

Create new STEAMQuest educational games with scaffolding, AI-generated assets, and scene configuration.

## Usage

This skill helps create quests in the `/Users/dereklomas/quests-app` codebase.

## Commands

### `/quest scaffold <quest-id>`
Create the folder structure and boilerplate files for a new quest.

### `/quest character <description>`
Generate a character portrait using mulerouter with transparent background.

### `/quest background <description>`
Generate a panoramic background scene using mulerouter.

### `/quest scene <outline>`
Generate sceneData.ts entries from a markdown outline or description.

### `/quest create <topic>`
Interactive full quest creation workflow combining all commands.

---

## Implementation Details

### Scaffold Command

When running `/quest scaffold <quest-id>`, create the following structure in `/Users/dereklomas/quests-app/src/GAME_DATA/<quest-id>/`:

```
<quest-id>/
├── sceneData.ts          # Scene definitions
├── assets/
│   ├── characters/       # Character portraits
│   ├── backgrounds/      # Scene backgrounds
│   └── audio/           # Dialog audio (placeholder)
├── configs/             # Interactive configs
├── interactives/        # Custom React components
│   └── interface.ts     # TypeScript interfaces
├── locales/
│   ├── en.json          # English translations
│   └── es.json          # Spanish translations
└── imsmanifest.xml      # SCORM manifest
```

**Boilerplate sceneData.ts:**
```typescript
import { SceneData } from '../../types/interfaces';

export const sceneData: SceneData[] = [
  // Start screen
  {
    background: {
      url: '/assets/backgrounds/bg1.webp',
      waitDelay: 1000,
      initialZoom: 1.0,
    },
    type: 'one-at-a-time',
    dialogs: [
      {
        heading: 'start.title',
        body: 'start.description',
        headingColor: '#000',
        position: { left: '50%', top: '70%' },
        width: '82vw',
        avatar: {
          src: '/assets/characters/char1.webp',
          alt: 'Character 1',
          size: 'chat-bubble-square',
          background: '#6FE9FF',
        },
        controls: [
          {
            type: 'start',
            text: 'start.start_game',
          },
        ],
        background: {
          blur: 5,
          zoom: 1.1,
        },
      },
    ],
  },
  // Add more scenes here
];
```

**Boilerplate locales/en.json:**
```json
{
  "dialog": {
    "button": {
      "start_again": "Start again",
      "next": "Next",
      "back": "Back",
      "correct": "Correct",
      "try-again": "Try again",
      "submit": "Submit"
    }
  },
  "start": {
    "title": "<div style='font-size: 36px; line-height: 54px; font-weight: 700;'>Quest Title</div>",
    "description": "Quest description goes here.",
    "start_game": "Start STEAMQuest"
  },
  "scenes": {
    "common": {
      "character1": "Character 1",
      "character2": "Character 2"
    }
  }
}
```

**Update package.json** - Add these scripts:
```json
"start:<quest-id>": "npm run preprocess && VITE_GAME_ID=<quest-id> vite",
"deploy:<quest-id>": "npm run preprocess && VITE_GAME_ID=<quest-id> npm run deployS3"
```

**Update scripts/scorm.json** - Add entry:
```json
"<quest-id>": {
  "identifier": "<QuestId>Quest",
  "title": "<Quest Title>",
  "description": "<Quest description>"
}
```

---

### Character Generation

Use the mulerouter-skills skill to generate characters.

**Art Style Prompt Template:**
```
Semi-realistic digital illustration portrait of [DESCRIPTION], bust shot showing head and upper torso, transparent background, soft diffused lighting, educational game character style, facing slightly toward camera, friendly approachable expression, high quality digital art
```

**Character Sizes to Generate:**
- `char{N}.webp` - Regular size (512x768px)
- `char{N}long.webp` - Full body (512x1024px)
- `char{N}mini.webp` - Small avatar (256x256px)
- `char{N}_profile.webp` - Circle crop for chat bubbles (256x256px)
- `char{N}_half.webp` - Half body for enlarged view (512x896px)

After generating the base image, create the size variants by cropping/resizing.

---

### Background Generation

Use the mulerouter-skills skill to generate backgrounds.

**Art Style Prompt Template:**
```
Wide panoramic digital painting of [DESCRIPTION], 3:1 aspect ratio (2048x683px), stylized illustration style, atmospheric lighting, cinematic composition, educational game background, no text or UI elements, high quality digital art
```

**Naming Convention:** `bg{N}.webp` where N is sequential (bg1.webp, bg2.webp, etc.)

---

### Scene Types Reference

**one-at-a-time** - Single dialog box with character avatar, most common type
- Good for: narration, single character speaking, explanations

**split-screen-chat** - Two-column layout with content on left, dialog on right
- Good for: interactive elements, showing formulas/diagrams alongside dialog

**turn-based-chat** - Chat-style stacked messages with alternating speakers
- Good for: conversations between multiple characters

**end-screen** - Final completion screen
- Good for: summary, learning points, restart button

---

### Dialog Positioning Reference

**Avatar Positions:**
- `position: 'left'` - Character on left side
- `position: 'right'` - Character on right side

**Dialog Box Positions (use percentage from edge):**
- Left speaker: `position: { top: '35%', right: '41%' }`
- Right speaker: `position: { top: '35%', left: '41%' }`
- Centered: `position: { left: '50%', top: '50%' }`

**Avatar Sizes:**
- `'small'` - Small icon
- `'medium'` - Medium portrait
- `'large'` - Large portrait with animation
- `'enlarged'` - Half-body view
- `'chat-bubble'` - Circular for chat layouts
- `'chat-bubble-square'` - Square for start screens

---

### Interactive Components Reference

**Built-in interaction types:**
- `input-box` - Single text/number input with validation
- `two-input-box` - Dual input fields
- `radio-button` - Multiple choice selection

**Config file pattern** (`configs/<name>.ts`):
```typescript
import { InputBoxInteraction } from '../interactives/interface';

const interaction: InputBoxInteraction = {
  type: 'input-box',
  title: 'scenes.scene-name.interaction.title',
  ariaLabel: 'scenes.scene-name.interaction.aria_label',
  correctnessFunction: (input: string | number) => {
    return Number(input) === 42; // Example validation
  },
  prefixText: '$',
};

export default interaction;
```

---

### Translation Key Patterns

Use dot-notation keys that map to the locale JSON structure:

- `start.title` - Start screen title
- `start.description` - Start screen description
- `scenes.common.character1` - Character 1 name
- `scenes.scene-name.dialog-key` - Scene-specific dialog
- `scenes.glossary.term.word` - Glossary term
- `scenes.glossary.term.definition` - Glossary definition
- `dialog.button.next` - Navigation buttons

---

## Example Workflow

### Creating a Matrix Multiplication Quest

1. **Scaffold:**
   ```
   /quest scaffold matrix-multiplication
   ```

2. **Generate Characters:**
   ```
   /quest character Alex, a young game development intern in their early 20s, casual tech company attire (hoodie and t-shirt), short dark hair, wearing glasses, holding a laptop, enthusiastic expression
   ```
   ```
   /quest character Dr. Maya Chen, a senior graphics engineer in her 40s, professional but approachable, wearing a blazer over a tech company t-shirt, confident expression, holding a stylus
   ```

3. **Generate Backgrounds:**
   ```
   /quest background Modern game development studio interior, multiple monitors showing 3D graphics, warm lighting, plants and tech equipment, collaborative workspace atmosphere
   ```
   ```
   /quest background Close-up of computer workstation with code on screen, 3D modeling software visible, blue accent lighting, futuristic tech aesthetic
   ```

4. **Build Scenes:**
   Create sceneData.ts with the scene structure, referencing generated assets and translation keys.

5. **Test:**
   ```bash
   npm run start:matrix-multiplication
   ```
