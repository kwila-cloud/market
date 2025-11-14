# Adding New Themes

The theming system is designed to make adding new themes straightforward. Here's how to add a new theme:

## Step 1: Define the Theme

In `src/lib/themes.ts`:

1. Add your theme name to the `ThemeName` type:

```typescript
export type ThemeName =
  | 'seaweed'
  | 'sky'
  | 'twilight'
  | 'autumn'
  | 'your-theme-name';
```

2. Add your theme to the `themes` object:

```typescript
export const themes: Record<ThemeName, Theme> = {
  // ... existing themes
  'your-theme-name': {
    name: 'your-theme-name',
    displayName: 'Your Theme Name',
  },
};
```

## Step 2: Add CSS Variables

In `src/styles/global.css`, add a new theme class with all required CSS variables:

```css
/* Your Theme Name - Description */
.theme-your-theme-name {
  /* Primary palette (full range: 100-800) */
  --color-primary-100: 255 230 220; /* lightest */
  --color-primary-200: 255 200 180;
  --color-primary-300: 255 170 140;
  --color-primary: 255 100 50; /* main color (500) */
  --color-primary-light: 255 140 90; /* 400 */
  --color-primary-dark: 200 50 25; /* 600 */
  --color-primary-700: 150 30 15;
  --color-primary-800: 100 20 10; /* darkest */

  /* Secondary palette (full range: 100-800) */
  --color-secondary-100: 220 240 255;
  --color-secondary-200: 180 220 255;
  --color-secondary-300: 140 200 255;
  --color-secondary: 50 150 255; /* main color (500) */
  --color-secondary-light: 90 180 255; /* 400 */
  --color-secondary-dark: 25 120 200; /* 600 */
  --color-secondary-700: 15 90 150;
  --color-secondary-800: 10 60 100;

  /* Surface palette */
  --color-surface: 20 20 20; /* Main background */
  --color-surface-elevated: 30 30 30; /* Elevated surfaces (cards, etc) */
  --color-surface-border: 50 50 50; /* Border color */

  /* Text palette */
  --color-text: 255 255 255; /* Primary text */
  --color-text-secondary: 200 200 200; /* Secondary text */
  --color-text-muted: 150 150 150; /* Muted text */

  /* Accent */
  --color-accent: 255 150 100; /* Accent color for highlights */
}
```

**Important Notes:**

- Colors must be in RGB format without `rgb()` wrapper (e.g., `255 100 50` not `rgb(255, 100, 50)`)
- Include full primary and secondary palettes (100-800 range) for maximum flexibility
- Secondary colors should complement the primary colors for visual harmony

## Step 3: Update ThemeInitializer

In `src/components/astro/ThemeInitializer.astro`, add your theme to the `VALID_THEMES` array:

```javascript
const VALID_THEMES = [
  'seaweed',
  'sky',
  'twilight',
  'autumn',
  'your-theme-name',
];
```

## That's It!

The theme will automatically appear in the theme selector with the correct color previews showing:

- Surface color as background
- Primary color as first dot
- Secondary color as second dot

No other files need to be modified.

## Optional: Set as Default

To make your new theme the default, update `DEFAULT_THEME` in `src/lib/themes.ts`:

```typescript
export const DEFAULT_THEME: ThemeName = 'your-theme-name';
```

## Color Palette Guidelines

### Primary Color

The main brand color of the theme. Used for:

- Links and interactive elements
- Call-to-action buttons
- Important highlights

### Secondary Color

A complementary color that works well with the primary. Used for:

- Secondary actions
- Visual variety
- Accent elements

Choose secondary colors that complement the primary:

- **Seaweed** (green) → Teal secondary
- **Sky** (sky blue) → Indigo secondary
- **Twilight** (blue) → Purple secondary
- **Autumn** (orange) → Red secondary

### Surface Colors

Background colors for the theme:

- **Light themes**: Use very subtle tints (50-100 range)
- **Dark themes**: Use dark grays/slates (800-900 range)

### Text Colors

Ensure proper contrast ratios for accessibility:

- Primary text: Highest contrast
- Secondary text: Medium contrast
- Muted text: Lower contrast (still readable)
