# Adding New Themes

The theming system is designed to make adding new themes straightforward. Here's how to add a new theme:

## Step 1: Define the Theme

In `src/lib/themes.ts`:

1. Add your theme name to the `ThemeName` type:

```typescript
export type ThemeName = 'seaweed' | 'twilight' | 'your-theme-name';
```

2. Add your theme to the `themes` object:

```typescript
export const themes: Record<ThemeName, Theme> = {
  // ... existing themes
  'your-theme-name': {
    name: 'your-theme-name',
    displayName: 'Your Theme Name',
    colors: {
      primary: 'rgb(255, 100, 50)', // Your primary color
      surface: 'rgb(20, 20, 20)', // Your surface color
    },
  },
};
```

## Step 2: Add CSS Variables

In `src/styles/global.css`, add a new theme class with all required CSS variables:

```css
/* Your Theme Name - Description */
.theme-your-theme-name {
  --color-primary: 255 100 50; /* Your primary color */
  --color-primary-light: 255 150 100; /* Lighter variant */
  --color-primary-dark: 200 50 25; /* Darker variant */

  --color-surface: 20 20 20; /* Main background */
  --color-surface-elevated: 30 30 30; /* Elevated surfaces (cards, etc) */
  --color-surface-border: 50 50 50; /* Border color */

  --color-text: 255 255 255; /* Primary text */
  --color-text-secondary: 200 200 200; /* Secondary text */
  --color-text-muted: 150 150 150; /* Muted text */

  --color-accent: 255 150 100; /* Accent color for highlights */
}
```

**Note:** Colors must be in RGB format without `rgb()` wrapper (e.g., `255 100 50` not `rgb(255, 100, 50)`).

## That's It!

The theme will automatically appear in the theme selector with the correct color previews. No other files need to be modified.

## Optional: Set as Default

To make your new theme the default, update `DEFAULT_THEME` in `src/lib/themes.ts`:

```typescript
export const DEFAULT_THEME: ThemeName = 'your-theme-name';
```
