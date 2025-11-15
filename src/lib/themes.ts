/**
 * Theme definitions and types for the application
 */

export type ThemeName = 'dusk' | 'ember' | 'ocean' | 'forest';

export interface Theme {
  name: ThemeName;
  displayName: string;
}

/**
 * Available themes in the application
 * Ordered with dark themes first
 */
export const themes: Record<ThemeName, Theme> = {
  dusk: {
    name: 'dusk',
    displayName: 'Dusk',
  },
  ember: {
    name: 'ember',
    displayName: 'Ember',
  },
  ocean: {
    name: 'ocean',
    displayName: 'Ocean',
  },
  forest: {
    name: 'forest',
    displayName: 'Forest',
  },
};

/**
 * Default theme
 */
export const DEFAULT_THEME: ThemeName = 'dusk';

/**
 * Get all available themes as an array
 */
export function getThemes(): Theme[] {
  return Object.values(themes);
}

/**
 * Get theme by name
 */
export function getTheme(name: ThemeName): Theme {
  return themes[name];
}

/**
 * Check if a string is a valid theme name
 */
export function isValidTheme(name: string): name is ThemeName {
  return name in themes;
}
