/**
 * Theme definitions and types for the application
 */

export type ThemeName = 'seaweed' | 'sky' | 'twilight' | 'autumn';

export interface Theme {
  name: ThemeName;
  displayName: string;
  colors: {
    primary: string;
    surface: string;
  };
}

/**
 * Available themes in the application
 */
export const themes: Record<ThemeName, Theme> = {
  seaweed: {
    name: 'seaweed',
    displayName: 'Seaweed',
    colors: {
      primary: 'rgb(34, 197, 94)', // green-500
      surface: 'rgb(255, 255, 255)', // white
    },
  },
  sky: {
    name: 'sky',
    displayName: 'Sky',
    colors: {
      primary: 'rgb(14, 165, 233)', // sky-500
      surface: 'rgb(255, 255, 255)', // white
    },
  },
  twilight: {
    name: 'twilight',
    displayName: 'Twilight',
    colors: {
      primary: 'rgb(59, 130, 246)', // blue-500
      surface: 'rgb(17, 24, 39)', // gray-900
    },
  },
  autumn: {
    name: 'autumn',
    displayName: 'Autumn',
    colors: {
      primary: 'rgb(249, 115, 22)', // orange-500
      surface: 'rgb(30, 27, 23)', // warm dark
    },
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
