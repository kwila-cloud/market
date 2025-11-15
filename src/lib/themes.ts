/**
 * Theme definitions and types for the application
 */

export type ThemeName = 'dusk' | 'ember' | 'ocean' | 'forest';

export interface Theme {
  name: ThemeName;
  displayName: string;
}

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

export const DEFAULT_THEME: ThemeName = 'dusk';

export function getThemes(): Theme[] {
  return Object.values(themes);
}

/**
 * Check if a string is a valid theme name
 */
export function isValidTheme(name: string): name is ThemeName {
  return name in themes;
}
