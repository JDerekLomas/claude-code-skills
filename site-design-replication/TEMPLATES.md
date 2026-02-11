# Code Templates for Site Replication

## Project Setup

### Next.js 14 + Tailwind + TypeScript

```bash
npx create-next-app@latest project-name --typescript --tailwind --app --src-dir=false
cd project-name
npm install lucide-react  # or @mui/icons-material for Material icons
```

### Tailwind Config with Custom Design Tokens

```typescript
// tailwind.config.ts
import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        // Primary brand color with shades
        primary: {
          50: '#f5f3ff',
          100: '#ede9fe',
          200: '#ddd6fe',
          300: '#c4b5fd',
          400: '#a78bfa',
          500: '#8b5cf6',  // Main
          600: '#7c3aed',
          700: '#6d28d9',
          800: '#5b21b6',
          900: '#4c1d95',
          950: '#2e1065',
        },
        // Secondary color
        secondary: {
          50: '#ecfeff',
          100: '#cffafe',
          500: '#06b6d4',
          600: '#0891b2',
        },
        // Accent color
        accent: {
          50: '#fff7ed',
          100: '#ffedd5',
          500: '#f97316',
          600: '#ea580c',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
      animation: {
        'fade-in': 'fadeIn 0.5s ease-out',
        'fade-in-up': 'fadeInUp 0.5s ease-out',
        'slide-in-right': 'slideInRight 0.3s ease-out',
        'breathe': 'breathe 3s ease-in-out infinite',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        fadeInUp: {
          '0%': { opacity: '0', transform: 'translateY(20px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        slideInRight: {
          '0%': { opacity: '0', transform: 'translateX(-20px)' },
          '100%': { opacity: '1', transform: 'translateX(0)' },
        },
        breathe: {
          '0%, 100%': { transform: 'scale(1)' },
          '50%': { transform: 'scale(1.1)' },
        },
      },
    },
  },
  plugins: [],
};

export default config;
```

### Global CSS with Custom Properties

```css
/* app/globals.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 255 255 255;
    --foreground: 23 23 23;
    --muted: 245 245 245;
    --muted-foreground: 115 115 115;
    --border: 229 229 229;
    --ring: 139 92 246;
  }

  .dark {
    --background: 23 23 23;
    --foreground: 250 250 250;
    --muted: 38 38 38;
    --muted-foreground: 163 163 163;
    --border: 64 64 64;
  }

  * {
    @apply border-neutral-200 dark:border-neutral-800;
  }

  body {
    @apply bg-white dark:bg-neutral-950 text-neutral-900 dark:text-neutral-50;
    font-feature-settings: 'rlig' 1, 'calt' 1;
  }
}

@layer utilities {
  .text-balance {
    text-wrap: balance;
  }
}

/* Custom scrollbar */
::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

::-webkit-scrollbar-track {
  @apply bg-neutral-100 dark:bg-neutral-900;
}

::-webkit-scrollbar-thumb {
  @apply bg-neutral-300 dark:bg-neutral-700 rounded-full;
}

::-webkit-scrollbar-thumb:hover {
  @apply bg-neutral-400 dark:bg-neutral-600;
}
```

---

## Component Templates

### Root Layout with Dark Mode

```tsx
// app/layout.tsx
import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import './globals.css';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'Site Title',
  description: 'Site description',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        <script
          dangerouslySetInnerHTML={{
            __html: `
              (function() {
                const theme = localStorage.getItem('theme') ||
                  (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
                document.documentElement.classList.toggle('dark', theme === 'dark');
              })();
            `,
          }}
        />
      </head>
      <body className={inter.className}>{children}</body>
    </html>
  );
}
```

### Navbar with Scroll Effect & Dark Mode Toggle

```tsx
// components/navigation/Navbar.tsx
'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';

const navLinks = [
  { label: 'Home', href: '/' },
  { label: 'Explore', href: '/explore' },
  { label: 'About', href: '/about' },
];

export function Navbar() {
  const [isScrolled, setIsScrolled] = useState(false);
  const [isDark, setIsDark] = useState(false);
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  useEffect(() => {
    const handleScroll = () => setIsScrolled(window.scrollY > 10);
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  useEffect(() => {
    setIsDark(document.documentElement.classList.contains('dark'));
  }, []);

  const toggleTheme = () => {
    const newIsDark = !isDark;
    setIsDark(newIsDark);
    document.documentElement.classList.toggle('dark', newIsDark);
    localStorage.setItem('theme', newIsDark ? 'dark' : 'light');
  };

  return (
    <nav
      className={`
        fixed top-0 left-0 right-0 z-50
        transition-all duration-300
        ${isScrolled
          ? 'bg-white/80 dark:bg-neutral-900/80 backdrop-blur-lg shadow-sm'
          : 'bg-transparent'
        }
      `}
    >
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <Link href="/" className="flex items-center gap-2 font-semibold text-lg">
            Logo
          </Link>

          {/* Desktop Navigation */}
          <div className="hidden md:flex items-center gap-8">
            {navLinks.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                className="text-sm font-medium text-neutral-600 dark:text-neutral-300 hover:text-primary-600 dark:hover:text-primary-400 transition-colors"
              >
                {link.label}
              </Link>
            ))}
          </div>

          {/* Right side */}
          <div className="flex items-center gap-4">
            {/* Theme toggle */}
            <button
              onClick={toggleTheme}
              className="p-2 rounded-full hover:bg-neutral-100 dark:hover:bg-neutral-800 transition-colors"
              aria-label="Toggle theme"
            >
              {isDark ? '☀️' : '🌙'}
            </button>

            {/* CTA Button */}
            <Link
              href="/action"
              className="hidden sm:inline-flex px-4 py-2 bg-primary-500 hover:bg-primary-600 text-white text-sm font-medium rounded-full transition-colors"
            >
              Get Started
            </Link>

            {/* Mobile menu button */}
            <button
              onClick={() => setIsMenuOpen(!isMenuOpen)}
              className="md:hidden p-2 rounded-lg hover:bg-neutral-100 dark:hover:bg-neutral-800"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                {isMenuOpen ? (
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                ) : (
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
                )}
              </svg>
            </button>
          </div>
        </div>
      </div>

      {/* Mobile menu */}
      {isMenuOpen && (
        <div className="md:hidden bg-white dark:bg-neutral-900 border-t dark:border-neutral-800">
          <div className="px-4 py-4 space-y-2">
            {navLinks.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                onClick={() => setIsMenuOpen(false)}
                className="block py-2 px-4 text-neutral-600 dark:text-neutral-300 hover:bg-neutral-100 dark:hover:bg-neutral-800 rounded-lg"
              >
                {link.label}
              </Link>
            ))}
          </div>
        </div>
      )}
    </nav>
  );
}
```

### Hero Section

```tsx
// components/hero/Hero.tsx
import Link from 'next/link';
import Image from 'next/image';

export function Hero() {
  return (
    <section className="relative min-h-[90vh] flex items-center overflow-hidden">
      {/* Background */}
      <div className="absolute inset-0">
        <Image
          src="/images/hero-bg.png"
          alt=""
          fill
          className="object-cover opacity-30 dark:opacity-20"
          priority
        />
        <div className="absolute inset-0 bg-gradient-to-b from-white/50 via-transparent to-white dark:from-neutral-950/50 dark:to-neutral-950" />
      </div>

      {/* Content */}
      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20">
        <div className="max-w-3xl">
          {/* Badge */}
          <div className="inline-flex items-center gap-2 px-4 py-2 bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-300 rounded-full text-sm font-medium mb-6 animate-fade-in">
            New Feature Available
          </div>

          {/* Headline */}
          <h1 className="text-4xl sm:text-5xl lg:text-6xl font-bold leading-tight mb-6 animate-fade-in-up">
            Your compelling{' '}
            <span className="bg-gradient-to-r from-primary-500 to-secondary-500 bg-clip-text text-transparent">
              headline here
            </span>
          </h1>

          {/* Subtitle */}
          <p className="text-lg sm:text-xl text-neutral-600 dark:text-neutral-300 mb-8 animate-fade-in-up" style={{ animationDelay: '100ms' }}>
            A clear value proposition that explains what your product does
            and why visitors should care about it.
          </p>

          {/* CTAs */}
          <div className="flex flex-col sm:flex-row gap-4 mb-12 animate-fade-in-up" style={{ animationDelay: '200ms' }}>
            <Link
              href="/action"
              className="inline-flex items-center justify-center gap-2 px-6 py-3 bg-primary-500 hover:bg-primary-600 text-white font-medium rounded-full transition-all duration-300 hover:shadow-lg hover:shadow-primary-500/30"
            >
              Primary Action
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" />
              </svg>
            </Link>
            <Link
              href="/learn"
              className="inline-flex items-center justify-center gap-2 px-6 py-3 bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 font-medium rounded-full transition-all duration-300 hover:bg-neutral-50 dark:hover:bg-neutral-700"
            >
              Secondary Action
            </Link>
          </div>

          {/* Stats */}
          <div className="flex flex-wrap gap-8 animate-fade-in-up" style={{ animationDelay: '300ms' }}>
            <div>
              <div className="text-2xl font-bold text-neutral-900 dark:text-white">10K+</div>
              <div className="text-sm text-neutral-500">Users</div>
            </div>
            <div>
              <div className="text-2xl font-bold text-neutral-900 dark:text-white">99%</div>
              <div className="text-sm text-neutral-500">Satisfaction</div>
            </div>
            <div>
              <div className="text-2xl font-bold text-neutral-900 dark:text-white">24/7</div>
              <div className="text-sm text-neutral-500">Support</div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
```

### Card Component

```tsx
// components/cards/Card.tsx
import Link from 'next/link';
import Image from 'next/image';

interface CardProps {
  title: string;
  description: string;
  image?: string;
  href: string;
  badge?: string;
  index?: number;
}

export function Card({ title, description, image, href, badge, index = 0 }: CardProps) {
  return (
    <Link
      href={href}
      className="
        group
        relative
        block
        p-5
        bg-white dark:bg-neutral-900
        border border-neutral-200 dark:border-neutral-800
        rounded-2xl
        transition-all duration-300
        hover:border-primary-300 dark:hover:border-primary-700
        hover:shadow-lg hover:shadow-primary-500/10
        hover:-translate-y-1
        animate-fade-in-up
      "
      style={{
        animationDelay: `${index * 50}ms`,
        animationFillMode: 'both',
      }}
    >
      {badge && (
        <span className="absolute -top-2 -right-2 px-2 py-0.5 bg-secondary-500 text-white text-xs font-medium rounded-full">
          {badge}
        </span>
      )}

      {image && (
        <div className="relative h-40 mb-4 rounded-xl overflow-hidden">
          <Image
            src={image}
            alt={title}
            fill
            className="object-cover group-hover:scale-105 transition-transform duration-500"
          />
        </div>
      )}

      <h3 className="font-semibold text-neutral-900 dark:text-white mb-2">
        {title}
      </h3>

      <p className="text-sm text-neutral-600 dark:text-neutral-400 line-clamp-2">
        {description}
      </p>

      <div className="mt-4 flex items-center justify-between">
        <span className="text-primary-600 dark:text-primary-400 text-sm font-medium group-hover:underline">
          Learn more
        </span>
        <svg className="w-5 h-5 text-neutral-400 group-hover:text-primary-500 group-hover:translate-x-1 transition-all duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
        </svg>
      </div>
    </Link>
  );
}

// Grid wrapper
export function CardGrid({ children }: { children: React.ReactNode }) {
  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
      {children}
    </div>
  );
}
```

### Footer Component

```tsx
// components/navigation/Footer.tsx
import Link from 'next/link';

const footerLinks = {
  product: [
    { label: 'Features', href: '/features' },
    { label: 'Pricing', href: '/pricing' },
    { label: 'FAQ', href: '/faq' },
  ],
  company: [
    { label: 'About', href: '/about' },
    { label: 'Blog', href: '/blog' },
    { label: 'Careers', href: '/careers' },
  ],
  legal: [
    { label: 'Privacy', href: '/privacy' },
    { label: 'Terms', href: '/terms' },
  ],
};

export function Footer() {
  return (
    <footer className="bg-neutral-50 dark:bg-neutral-900 border-t border-neutral-200 dark:border-neutral-800">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
          {/* Brand */}
          <div className="col-span-2 md:col-span-1">
            <Link href="/" className="font-semibold text-lg mb-4 block">
              Logo
            </Link>
            <p className="text-sm text-neutral-600 dark:text-neutral-400 mb-4">
              A brief tagline about your product or company.
            </p>
          </div>

          {/* Product */}
          <div>
            <h3 className="font-semibold text-sm mb-4">Product</h3>
            <ul className="space-y-2">
              {footerLinks.product.map((link) => (
                <li key={link.href}>
                  <Link href={link.href} className="text-sm text-neutral-600 dark:text-neutral-400 hover:text-primary-500 transition-colors">
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Company */}
          <div>
            <h3 className="font-semibold text-sm mb-4">Company</h3>
            <ul className="space-y-2">
              {footerLinks.company.map((link) => (
                <li key={link.href}>
                  <Link href={link.href} className="text-sm text-neutral-600 dark:text-neutral-400 hover:text-primary-500 transition-colors">
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Legal */}
          <div>
            <h3 className="font-semibold text-sm mb-4">Legal</h3>
            <ul className="space-y-2">
              {footerLinks.legal.map((link) => (
                <li key={link.href}>
                  <Link href={link.href} className="text-sm text-neutral-600 dark:text-neutral-400 hover:text-primary-500 transition-colors">
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>
        </div>

        {/* Bottom */}
        <div className="mt-12 pt-8 border-t border-neutral-200 dark:border-neutral-800 flex flex-col sm:flex-row justify-between items-center gap-4">
          <p className="text-sm text-neutral-500">
            © {new Date().getFullYear()} Company Name. All rights reserved.
          </p>
        </div>
      </div>
    </footer>
  );
}
```

---

## Data Structure Template

```typescript
// lib/data.ts

// Define your data types
export type Category = 'category-1' | 'category-2' | 'category-3';

export interface Item {
  id: string;
  name: string;
  description: string;
  category: Category;
  tags: string[];
  icon: string;
  url?: string;
  featured?: boolean;
  isNew?: boolean;
}

export interface Collection {
  id: string;
  title: string;
  description: string;
  icon: string;
  items: string[]; // Item IDs
}

// Category definitions
export const categories: Record<Category, { label: string; color: string; description: string; icon: string }> = {
  'category-1': {
    label: 'Category One',
    color: '#8b5cf6',
    description: 'Description of category one',
    icon: 'icon-name',
  },
  'category-2': {
    label: 'Category Two',
    color: '#0ea5e9',
    description: 'Description of category two',
    icon: 'icon-name',
  },
  'category-3': {
    label: 'Category Three',
    color: '#22c55e',
    description: 'Description of category three',
    icon: 'icon-name',
  },
};

// Items data
export const items: Item[] = [
  {
    id: 'item-1',
    name: 'Item One',
    description: 'Description of item one',
    category: 'category-1',
    tags: ['tag1', 'tag2'],
    icon: 'icon-name',
    featured: true,
  },
  // ... more items
];

// Collections
export const collections: Collection[] = [
  {
    id: 'collection-1',
    title: 'Collection One',
    description: 'Description of collection',
    icon: 'icon-name',
    items: ['item-1', 'item-2'],
  },
  // ... more collections
];

// Helper functions
export function getItemById(id: string): Item | undefined {
  return items.find(i => i.id === id);
}

export function getItemsByCategory(category: Category): Item[] {
  return items.filter(i => i.category === category);
}

export function getFeaturedItems(): Item[] {
  return items.filter(i => i.featured);
}

export function getCollectionItems(collection: Collection): Item[] {
  return collection.items
    .map(id => getItemById(id))
    .filter((i): i is Item => i !== undefined);
}
```
