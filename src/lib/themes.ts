/**
 * Theme definitions and types for the application
 */

export type ThemeName = 'seaweed' | 'sky' | 'twilight' | 'autumn';

export interface Theme {
  name: ThemeName;
  displayName: string;
}

/**
 * Available themes in the application
 */
export const themes: Record<ThemeName, Theme> = {
  seaweed: {
    name: 'seaweed',
    displayName: 'Seaweed',
  },
  sky: {
    name: 'sky',
    displayName: 'Sky',
  },
  twilight: {
    name: 'twilight',
    displayName: 'Twilight',
  },
  autumn: {
    name: 'autumn',
    displayName: 'Autumn',
  },
};

/**
 * Default theme
 */
export const DEFAULT_THEME: ThemeName = 'twilight';

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
