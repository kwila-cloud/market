/**
 * Theme management utilities for persisting and applying themes
 */

import {
  DEFAULT_THEME,
  isValidTheme,
  getThemes,
  type ThemeName,
} from './themes';

const THEME_STORAGE_KEY = 'app-theme';

/**
 * Get the current theme from localStorage or use default
 */
export function getStoredTheme(): ThemeName {
  if (typeof window === 'undefined') {
    return DEFAULT_THEME;
  }

  try {
    const stored = localStorage.getItem(THEME_STORAGE_KEY);
    if (stored && isValidTheme(stored)) {
      return stored;
    }
  } catch (error) {
    console.warn('Failed to read theme from localStorage:', error);
  }

  return DEFAULT_THEME;
}

/**
 * Save theme to localStorage
 */
export function saveTheme(theme: ThemeName): void {
  if (typeof window === 'undefined') {
    return;
  }

  try {
    localStorage.setItem(THEME_STORAGE_KEY, theme);
  } catch (error) {
    console.warn('Failed to save theme to localStorage:', error);
  }
}

/**
 * Apply theme to the document element
 */
export function applyTheme(theme: ThemeName): void {
  if (typeof window === 'undefined' || !document.documentElement) {
    return;
  }

  // Remove all theme classes dynamically
  const allThemes = getThemes();
  allThemes.forEach((t) => {
    document.documentElement.classList.remove(`theme-${t.name}`);
  });

  // Add the new theme class
  document.documentElement.classList.add(`theme-${theme}`);
}

/**
 * Set the current theme (save and apply)
 */
export function setTheme(theme: ThemeName): void {
  saveTheme(theme);
  applyTheme(theme);
}

/**
 * Initialize theme on page load
 */
export function initializeTheme(): ThemeName {
  const theme = getStoredTheme();
  applyTheme(theme);
  return theme;
}
