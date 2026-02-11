# Site Design Replication Methodology

## The 5-Phase Approach

### Phase 1: Discovery & Analysis

**Goal**: Understand the source site's design DNA

1. **Visual Audit**
   - Screenshot key pages (home, listing, detail, about)
   - Note visual hierarchy and information architecture
   - Identify unique design elements vs common patterns

2. **Technical Analysis**
   - Fetch HTML/CSS structure via WebFetch
   - Identify framework (React, Vue, vanilla, etc.)
   - Note responsive breakpoints
   - Check for animations/transitions

3. **Design Token Extraction**
   ```
   Colors:
   - Primary brand color
   - Secondary/accent colors
   - Neutral scale (background, text, borders)
   - Semantic colors (success, warning, error)

   Typography:
   - Font families (headings, body, mono)
   - Size scale (xs, sm, base, lg, xl, 2xl, etc.)
   - Weight scale (light, normal, medium, semibold, bold)
   - Line heights and letter spacing

   Spacing:
   - Base unit (typically 4px or 8px)
   - Scale multipliers
   - Component padding patterns
   - Section margins

   Effects:
   - Border radius scale
   - Shadow definitions
   - Gradient patterns
   - Blur/backdrop effects
   ```

### Phase 2: Component Inventory

**Goal**: Catalog all UI components

1. **Navigation Components**
   - Navbar (desktop/mobile variants)
   - Footer
   - Breadcrumbs
   - Sidebar (if applicable)

2. **Content Components**
   - Hero sections
   - Cards (product, feature, testimonial)
   - Lists and grids
   - Tables
   - Forms

3. **Interactive Components**
   - Buttons (variants, states)
   - Inputs (text, select, checkbox, etc.)
   - Modals/dialogs
   - Dropdowns/menus
   - Tabs/accordions

4. **Feedback Components**
   - Loading states
   - Empty states
   - Error states
   - Toast/notifications
   - Progress indicators

### Phase 3: Documentation Creation

**Goal**: Create LLM-consumable documentation

**COMPONENTS.md Structure**:
```markdown
# Component Library

## Navigation

### Navbar
**Purpose**: Main site navigation with logo, links, and actions
**Variants**: Transparent (hero), Solid (scrolled), Mobile
**Key Features**:
- Sticky positioning
- Scroll-triggered background change
- Mobile hamburger menu
- Dark mode toggle

**Implementation**:
- Uses useState for scroll detection
- useEffect for scroll listener
- Conditional styling based on state

**Code**: [Full component code]

---

### Footer
[Similar documentation pattern]
```

**STYLES.md Structure**:
```markdown
# Design System

## Colors

### Brand Colors
| Token | Hex | RGB | HSL | Usage |
|-------|-----|-----|-----|-------|
| primary-500 | #8b5cf6 | 139,92,246 | 258,89%,66% | Primary actions, links |
| primary-600 | #7c3aed | 124,58,237 | 262,83%,58% | Hover states |

### Neutral Scale
| Token | Value | Usage |
|-------|-------|-------|
| neutral-50 | #fafafa | Subtle backgrounds |
| neutral-100 | #f5f5f5 | Card backgrounds |
| neutral-900 | #171717 | Primary text |

## Typography

### Font Stack
```css
--font-sans: 'Inter', system-ui, sans-serif;
--font-mono: 'JetBrains Mono', monospace;
```

### Size Scale
| Name | Size | Line Height | Usage |
|------|------|-------------|-------|
| text-xs | 12px | 16px | Captions, labels |
| text-sm | 14px | 20px | Secondary text |
| text-base | 16px | 24px | Body text |
| text-lg | 18px | 28px | Lead paragraphs |
| text-xl | 20px | 28px | Section headers |
| text-2xl | 24px | 32px | Card titles |
| text-3xl | 30px | 36px | Page headers |
| text-4xl | 36px | 40px | Hero subheadings |
| text-5xl | 48px | 48px | Hero headlines |

## Spacing

### Base Unit: 4px

| Token | Value | Common Usage |
|-------|-------|--------------|
| space-1 | 4px | Icon gaps |
| space-2 | 8px | Tight padding |
| space-3 | 12px | Button padding-y |
| space-4 | 16px | Card padding |
| space-6 | 24px | Section gaps |
| space-8 | 32px | Component margins |
| space-12 | 48px | Section padding |
| space-16 | 64px | Page sections |
| space-20 | 80px | Major sections |

## Effects

### Border Radius
| Token | Value | Usage |
|-------|-------|-------|
| rounded-sm | 4px | Inputs, small elements |
| rounded | 8px | Buttons, tags |
| rounded-lg | 12px | Cards |
| rounded-xl | 16px | Modals, large cards |
| rounded-2xl | 24px | Hero sections |
| rounded-full | 9999px | Avatars, pills |

### Shadows
```css
--shadow-sm: 0 1px 2px rgba(0,0,0,0.05);
--shadow: 0 4px 6px rgba(0,0,0,0.1);
--shadow-lg: 0 10px 25px rgba(0,0,0,0.1);
--shadow-xl: 0 25px 50px rgba(0,0,0,0.15);
```
```

### Phase 4: Remix Strategy

**Goal**: Transform the design for a new purpose

1. **Concept Definition**
   - What problem does the new site solve?
   - Who is the target audience?
   - What's the brand personality? (Professional, playful, minimal, bold)
   - What content will it feature?

2. **Design Adaptation**
   - Map original components to new use cases
   - Define new color palette that fits concept
   - Adjust typography for tone
   - Plan content structure

3. **Feature Planning**
   - Core pages needed
   - Data models required
   - Interactive features
   - Third-party integrations

### Phase 5: Implementation

**Goal**: Build the remixed site

1. **Project Setup**
   ```bash
   npx create-next-app@latest project-name --typescript --tailwind --app
   cd project-name
   ```

2. **Configure Design Tokens**
   - Extend Tailwind config with custom colors
   - Add custom fonts
   - Define animation utilities

3. **Build Component Library**
   - Start with layout components (Navbar, Footer)
   - Build reusable UI components
   - Create page-specific sections

4. **Implement Pages**
   - Home page with hero
   - Listing/explore pages
   - Detail pages
   - About/info pages

5. **Add Polish**
   - Animations and transitions
   - Loading states
   - Error handling
   - SEO meta tags

6. **Deploy**
   - Test build locally
   - Push to GitHub
   - Deploy to Vercel

## Quality Checklist

### Design Quality
- [ ] Visual hierarchy is clear
- [ ] Consistent spacing throughout
- [ ] Color contrast meets accessibility standards
- [ ] Typography is readable at all sizes
- [ ] Interactive states are obvious

### Technical Quality
- [ ] Build compiles without errors
- [ ] No TypeScript errors
- [ ] Images are optimized
- [ ] Responsive at all breakpoints
- [ ] Dark mode fully functional
- [ ] No console errors

### Documentation Quality
- [ ] All components documented
- [ ] Design tokens cataloged
- [ ] Code is commented where complex
- [ ] README explains project structure
