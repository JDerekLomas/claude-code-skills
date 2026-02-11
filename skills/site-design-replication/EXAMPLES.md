# Real-World Examples

## Example 1: MuleRouter → MindfulAI

### Source Site Analysis: MuleRouter.ai

**What it is**: AI model router/directory site

**Design Tokens Extracted**:

```
Colors:
- Primary: Purple (#8b5cf6)
- Accent: Blue (#0ea5e9), Orange (#f97316)
- Background: White, Neutral grays
- Dark mode: Neutral 900/950

Typography:
- Font: Inter (system fallback)
- Headings: 700 weight, tight leading
- Body: 400 weight, relaxed leading

Spacing:
- Base: 4px
- Sections: 80px vertical padding
- Cards: 24px padding
- Gaps: 24px between cards
```

**Components Identified**:
1. Navbar with scroll effect
2. Hero with animated badge
3. Model cards with hover effects
4. Category filters
5. Search functionality
6. Footer with link columns

### Remix: MindfulAI

**New Concept**: Curated directory of AI tools rated by wellbeing impact

**Adaptation Strategy**:
- Keep: Card-based layout, category system, scroll animations
- Change: Color palette to calming lavender/teal, add wellbeing scores
- Add: Wellbeing scoring system, collections feature

**Color Palette Adaptation**:
```
Original (MuleRouter):     → Remix (MindfulAI):
Primary: #8b5cf6 (purple)  → #8b5cf6 (lavender - kept, fits wellness)
Accent: #0ea5e9 (blue)     → #14b8a6 (teal/calm)
Secondary: #f97316 (orange) → #f19340 (warmth - softer orange)
New addition:              → #22c55e (sage - growth/wellness)
```

**Data Model Transformation**:
```typescript
// Original (AI Models)
interface Model {
  id: string;
  name: string;
  provider: string;
  capabilities: string[];
}

// Remixed (Wellbeing AI Tools)
interface AITool {
  id: string;
  name: string;
  tagline: string;
  description: string;
  category: Category;
  tags: string[];
  wellbeing: WellbeingScore;  // NEW: Added scoring
  url: string;
  icon: string;
}

interface WellbeingScore {
  attention: number;  // 1-5
  calm: number;       // 1-5
  agency: number;     // 1-5
  growth: number;     // 1-5
}
```

**New Features Added**:
1. Wellbeing score visualization
2. Curated collections
3. Category-specific icons
4. Tool detail pages with full scores

---

## Example 2: Generic E-commerce → Portfolio Site

### Source Analysis: Shopify Store Template

**Design Tokens**:
```
Colors:
- Primary: Black (#000000)
- Accent: Gold (#D4AF37)
- Background: White, Light gray
- Text: Dark gray

Typography:
- Headings: Playfair Display (serif)
- Body: Open Sans (sans-serif)
```

**Components**:
1. Full-width hero with video background
2. Product grid with quick-view
3. Testimonial carousel
4. Newsletter signup
5. Instagram feed integration

### Remix: Creative Portfolio

**Adaptation**:
- Hero → Project showcase with case study links
- Product grid → Project cards with tags
- Testimonials → Client quotes
- Newsletter → Contact form
- Instagram → Dribbble/Behance integration

**New Color Palette**:
```
E-commerce Gold → Creative Coral (#FF6B6B)
Black → Dark navy (#1A1A2E)
White → Off-white (#FAFAFA)
```

---

## Example 3: SaaS Dashboard → Analytics Dashboard

### Source: Stripe Dashboard

**Design Patterns Identified**:
1. Sidebar navigation with icons
2. Metric cards with sparklines
3. Data tables with sorting
4. Date range picker
5. Notification bell
6. User dropdown

**Transferable Components**:
```tsx
// Metric Card Pattern
interface MetricCardProps {
  title: string;
  value: string | number;
  change?: {
    value: number;
    direction: 'up' | 'down';
  };
  sparkline?: number[];
}

// Can be reused for any dashboard
```

### Remix: Marketing Analytics

**Adaptations**:
- Financial metrics → Marketing KPIs
- Payment tables → Campaign performance
- Customer list → Lead management

---

## Design Token Extraction Template

When analyzing a site, fill out this template:

```markdown
# [Site Name] Design System

## Brand
- **Primary Color**: [hex] - Used for [usage]
- **Secondary Color**: [hex] - Used for [usage]
- **Accent Color**: [hex] - Used for [usage]

## Neutrals
| Shade | Hex | Usage |
|-------|-----|-------|
| 50 | | Subtle backgrounds |
| 100 | | Card backgrounds |
| 200 | | Borders |
| 300 | | Disabled states |
| 400 | | Placeholder text |
| 500 | | Secondary text |
| 600 | | Primary text |
| 700 | | Headings |
| 800 | | Dark mode text |
| 900 | | Dark mode backgrounds |

## Typography

### Fonts
- **Headings**: [font-family]
- **Body**: [font-family]
- **Mono**: [font-family]

### Scale
| Name | Size | Weight | Line Height | Usage |
|------|------|--------|-------------|-------|
| xs | 12px | | | |
| sm | 14px | | | |
| base | 16px | | | |
| lg | 18px | | | |
| xl | 20px | | | |
| 2xl | 24px | | | |
| 3xl | 30px | | | |
| 4xl | 36px | | | |
| 5xl | 48px | | | |

## Spacing
- **Base unit**: [4px/8px]
- **Scale**: [multipliers used]

## Components Inventory
- [ ] Navbar
- [ ] Footer
- [ ] Hero
- [ ] Cards
- [ ] Buttons
- [ ] Forms
- [ ] Tables
- [ ] Modals
- [ ] [Other...]

## Animations
- **Fade in**: [duration, easing]
- **Hover effects**: [description]
- **Page transitions**: [description]

## Responsive Breakpoints
- **sm**: [value]
- **md**: [value]
- **lg**: [value]
- **xl**: [value]
```

---

## Checklist for Successful Replication

### Before Starting
- [ ] Captured screenshots of all key pages
- [ ] Identified the tech stack
- [ ] Documented the design system
- [ ] Listed all components needed
- [ ] Defined your remix concept

### During Development
- [ ] Set up project with correct dependencies
- [ ] Configured Tailwind with design tokens
- [ ] Built layout components first (Navbar, Footer)
- [ ] Created reusable UI components
- [ ] Implemented page-by-page
- [ ] Added animations and polish
- [ ] Tested responsive behavior
- [ ] Verified dark mode

### Before Deployment
- [ ] Build passes without errors
- [ ] All images optimized
- [ ] Meta tags configured
- [ ] Performance tested
- [ ] Cross-browser tested
- [ ] Documentation updated

### After Deployment
- [ ] Verified live site works
- [ ] Checked all links
- [ ] Tested on real devices
- [ ] Shared with stakeholders
