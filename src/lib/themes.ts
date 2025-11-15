/**
 * Theme definitions and types for the application
 */

export type ThemeName =
  | 'dusk'
  | 'ember1'
  | 'ember2'
  | 'ember3'
  | 'ember4'
  | 'ember5'
  | 'ocean'
  | 'forest';

export interface Theme {
  name: ThemeName;
  displayName: string;
  preview: {
    surface: string;
    primary: string;
    secondary: string;
  };
}

/**
 * Available themes in the application
 * Ordered with dark themes first
 */
export const themes: Record<ThemeName, Theme> = {
  dusk: {
    name: 'dusk',
    displayName: 'Dusk',
    preview: {
      surface: '26 32 44',
      primary: '59 130 246',
      secondary: '251 146 60',
    },
  },
  ember1: {
    name: 'ember1',
    displayName: 'Ember 1: Copper',
    preview: {
      surface: '34 34 34',
      primary: '230 126 34',
      secondary: '184 115 51',
    },
  },
  ember2: {
    name: 'ember2',
    displayName: 'Ember 2: Amber Gold',
    preview: {
      surface: '34 34 34',
      primary: '230 126 34',
      secondary: '217 119 6',
    },
  },
  ember3: {
    name: 'ember3',
    displayName: 'Ember 3: Coral',
    preview: {
      surface: '34 34 34',
      primary: '230 126 34',
      secondary: '255 127 80',
    },
  },
  ember4: {
    name: 'ember4',
    displayName: 'Ember 4: Burgundy',
    preview: {
      surface: '34 34 34',
      primary: '230 126 34',
      secondary: '165 42 42',
    },
  },
  ember5: {
    name: 'ember5',
    displayName: 'Ember 5: Burnt Orange',
    preview: {
      surface: '34 34 34',
      primary: '230 126 34',
      secondary: '204 85 0',
    },
  },
  ocean: {
    name: 'ocean',
    displayName: 'Ocean',
    preview: {
      surface: '255 255 255',
      primary: '41 128 185',
      secondary: '26 188 156',
    },
  },
  forest: {
    name: 'forest',
    displayName: 'Forest',
    preview: {
      surface: '255 255 255',
      primary: '39 174 96',
      secondary: '160 120 80',
    },
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
