# Claude Code Skills

A collection of custom skills for [Claude Code](https://github.com/anthropics/claude-code) that extend its capabilities with specialized knowledge and workflows.

## What are Skills?

Skills are markdown files that provide Claude Code with domain-specific knowledge, API references, code templates, and best practices. When you invoke a skill, Claude gains context to help with specialized tasks.

## Available Skills

| Skill | Description |
|-------|-------------|
| [mulerouter](skills/mulerouter/) | AI image/video generation via MuleRouter API (Wan2.6, Midjourney) |
| [card-deck-creation](skills/card-deck-creation/) | Create themed card decks with AI artwork and Puppeteer rendering |
| [d3-visualization](skills/d3-visualization/) | Comprehensive D3.js data visualization patterns and examples |
| [site-design-replication](skills/site-design-replication/) | Clone, analyze, and remix website designs |

## Installation

Copy skills to your Claude Code skills directory:

```bash
# Clone this repo
git clone https://github.com/JDerekLomas/claude-code-skills.git

# Copy a single skill
cp -r claude-code-skills/skills/mulerouter ~/.claude/skills/

# Or copy all skills
cp -r claude-code-skills/skills/* ~/.claude/skills/
```

## Usage

Once installed, the skills are automatically available. Claude will use them when relevant to your task, or you can explicitly invoke them:

```
"Use the mulerouter skill to generate an image of a mountain sunset"
"Help me create a d3 visualization of this data"
"Clone the design of example.com"
```

## Skill Details

### MuleRouter

Generate AI images and videos using MuleRouter's unified API gateway.

**Capabilities:**
- Text-to-image (Wan2.6)
- Image-to-image transformation
- Text-to-video generation
- Image-to-video animation

**Requirements:**
- MuleRouter API key (`MULEROUTER_API_KEY`)

---

### Card Deck Creation

Create complete card decks with custom content, AI-generated artwork, and web deployment.

**Workflow:**
1. Define card content in JSON
2. Generate artwork via MuleRouter API
3. Render final cards with Puppeteer (HTML to PNG)
4. Deploy a web gallery

**Requirements:**
- Node.js with Puppeteer
- MuleRouter API key for artwork generation

---

### D3 Visualization

Comprehensive D3.js visualization guidance including:

- Core patterns (bar, line, scatter, pie charts)
- Hierarchical visualizations (trees, treemaps, sunbursts)
- Network/force diagrams
- Geographic maps
- Interactions (tooltips, zoom, brush)
- Complete scale and color scheme references

**Includes:**
- `SKILL.md` - Main skill documentation
- `references/d3-patterns.md` - Detailed code patterns
- `references/scale-reference.md` - Complete scale guide
- `references/colour-schemes.md` - Color palette recommendations

---

### Site Design Replication

Extract design systems from existing websites and create new sites inspired by them.

**Workflow:**
1. Crawl & analyze target site
2. Extract design tokens (colors, typography, spacing)
3. Document components in LLM-ready markdown
4. Remix with your own concept

**Includes:**
- `SKILL.md` - Overview and process
- `APPROACH.md` - Detailed methodology
- `TEMPLATES.md` - Next.js/Tailwind code templates

## Contributing

Feel free to submit PRs with improvements or new skills.

## License

MIT
