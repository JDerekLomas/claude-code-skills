---
name: site-design-replication
description: Crawl, analyze, document, and remix website designs. Extract design systems (colors, typography, spacing), document components with LLM-ready markdown, and create new sites inspired by existing designs. Use when asked to clone a site, extract a design system, create a site like another site, or document UI components.
---

# Site Design Replication & Remix Skill

## Overview

This skill enables you to:
1. **Crawl & Analyze** - Fetch website content and extract design patterns
2. **Document** - Create LLM-ready markdown documentation of components and styles
3. **Remix** - Build new sites inspired by existing designs with your own concept

## When to Use This Skill

- "Clone this website" / "Copy this site's design"
- "Extract the design system from [URL]"
- "Create a site like [URL] but for [concept]"
- "Document this site's components"
- "What's the color palette of [URL]?"

## Step-by-Step Process

### Phase 1: Crawl & Extract

1. **Fetch the target site** using WebFetch tool
2. **Identify key elements**:
   - Navigation structure
   - Hero section patterns
   - Card/grid layouts
   - Color usage
   - Typography hierarchy
   - Spacing patterns
   - Interactive elements

3. **Extract design tokens**:
   ```
   Colors: primary, secondary, accent, neutral scale
   Typography: font families, size scale, weights
   Spacing: base unit, scale (4px, 8px, 16px, etc.)
   Borders: radius values, border widths
   Shadows: elevation levels
   ```

### Phase 2: Document for LLM Context

Create markdown files that can be fed back to LLMs:

1. **COMPONENTS.md** - Document each component:
   ```markdown
   ## ComponentName

   **Purpose**: What it does
   **Props/Variants**: Configuration options
   **Code**:
   ```tsx
   // Component code here
   ```
   ```

2. **STYLES.md** - Design token documentation:
   ```markdown
   ## Color Palette
   | Name | Value | Usage |
   |------|-------|-------|
   | primary | #8b5cf6 | CTAs, links |

   ## Typography Scale
   | Name | Size | Weight | Line Height |
   |------|------|--------|-------------|
   | h1 | 48px | 700 | 1.2 |
   ```

3. **LLM-CONTEXT.md** - High-level architecture summary

### Phase 3: Remix & Create

When building a new site inspired by another:

1. **Identify transferable patterns**:
   - Layout structures
   - Component architecture
   - Animation/interaction patterns
   - Responsive breakpoints

2. **Define the new concept**:
   - Purpose and audience
   - Unique value proposition
   - Content structure
   - Brand personality

3. **Adapt the design**:
   - New color palette aligned with concept
   - Adjusted typography for tone
   - Modified components for use case
   - Original content and imagery

## Project Structure

When creating a new site, use this structure:

```
project-name/
├── app/                    # Next.js App Router pages
│   ├── page.tsx           # Home page
│   ├── layout.tsx         # Root layout
│   └── [feature]/         # Feature pages
├── components/
│   ├── cards/             # Card components
│   ├── hero/              # Hero sections
│   ├── navigation/        # Nav, Footer
│   ├── sections/          # Page sections
│   └── ui/                # Base UI components
├── lib/
│   └── data.ts            # Data and types
├── public/
│   └── images/            # Static assets
├── styles/
│   └── globals.css        # Global styles + Tailwind
└── docs/                  # Documentation
    ├── COMPONENTS.md
    ├── STYLES.md
    └── LLM-CONTEXT.md
```

## Code Templates

See TEMPLATES.md for:
- Next.js 14 setup with Tailwind
- Common component patterns
- Animation utilities
- Dark mode implementation

## Best Practices

1. **Always document as you build** - Future LLMs need context
2. **Extract reusable patterns** - Don't copy blindly, understand why
3. **Respect originality** - Remix, don't plagiarize
4. **Test responsiveness** - Mobile-first approach
5. **Optimize for performance** - Use Next.js Image, lazy loading

## Image Generation Integration

When the design needs custom images:

1. **Plan image requirements** - List all needed images with descriptions
2. **Use AI image generation** - MuleRouter, Midjourney, DALL-E
3. **Optimize images** - Compress and format appropriately
4. **Integrate with Next.js Image** - Use fill, priority, sizes props

## Deployment Checklist

- [ ] Build passes without errors
- [ ] All images optimized
- [ ] Meta tags configured
- [ ] Dark mode works
- [ ] Mobile responsive
- [ ] Push to GitHub
- [ ] Deploy to Vercel
