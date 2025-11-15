import { describe, it, expect, beforeEach, vi } from 'vitest';
import {
  getStoredTheme,
  saveTheme,
  applyTheme,
  setTheme,
  initializeTheme,
} from '../../src/lib/themeManager';
import { DEFAULT_THEME } from '../../src/lib/themes';

// Mock localStorage
const localStorageMock = (() => {
  let store: Record<string, string> = {};

  return {
    getItem: (key: string) => store[key] || null,
    setItem: (key: string, value: string) => {
      store[key] = value;
    },
    removeItem: (key: string) => {
      delete store[key];
    },
    clear: () => {
      store = {};
    },
  };
})();

// Replace global localStorage
Object.defineProperty(window, 'localStorage', {
  value: localStorageMock,
});

describe('themeManager', () => {
  beforeEach(() => {
    // Clear localStorage before each test
    localStorageMock.clear();
    // Clear all theme classes from document
    document.documentElement.className = '';
    // Clear console warnings
    vi.clearAllMocks();
  });

  describe('getStoredTheme', () => {
    it('should return default theme when localStorage is empty', () => {
      expect(getStoredTheme()).toBe(DEFAULT_THEME);
    });

    it('should return stored theme when valid theme is in localStorage', () => {
      localStorageMock.setItem('app-theme', 'ocean');
      expect(getStoredTheme()).toBe('ocean');
    });

    it('should return default theme when invalid theme is in localStorage', () => {
      localStorageMock.setItem('app-theme', 'invalid-theme');
      expect(getStoredTheme()).toBe(DEFAULT_THEME);
    });

    it('should handle localStorage errors gracefully', () => {
      const consoleWarnSpy = vi.spyOn(console, 'warn').mockImplementation(() => {});

      // Mock getItem to throw an error
      const originalGetItem = localStorageMock.getItem;
      localStorageMock.getItem = () => {
        throw new Error('localStorage error');
      };

      expect(getStoredTheme()).toBe(DEFAULT_THEME);
      expect(consoleWarnSpy).toHaveBeenCalled();

      // Restore original getItem
      localStorageMock.getItem = originalGetItem;
      consoleWarnSpy.mockRestore();
    });
  });

  describe('saveTheme', () => {
    it('should save theme to localStorage', () => {
      saveTheme('ember');
      expect(localStorageMock.getItem('app-theme')).toBe('ember');
    });

    it('should overwrite existing theme', () => {
      saveTheme('ocean');
      expect(localStorageMock.getItem('app-theme')).toBe('ocean');

      saveTheme('forest');
      expect(localStorageMock.getItem('app-theme')).toBe('forest');
    });

    it('should handle localStorage errors gracefully', () => {
      const consoleWarnSpy = vi.spyOn(console, 'warn').mockImplementation(() => {});

      // Mock setItem to throw an error
      const originalSetItem = localStorageMock.setItem;
      localStorageMock.setItem = () => {
        throw new Error('localStorage error');
      };

      // Should not throw
      expect(() => saveTheme('ocean')).not.toThrow();
      expect(consoleWarnSpy).toHaveBeenCalled();

      // Restore original setItem
      localStorageMock.setItem = originalSetItem;
      consoleWarnSpy.mockRestore();
    });
  });

  describe('applyTheme', () => {
    it('should add theme class to document element', () => {
      applyTheme('ocean');
      expect(document.documentElement.classList.contains('theme-ocean')).toBe(true);
    });

    it('should remove previous theme class when applying new theme', () => {
      applyTheme('ocean');
      expect(document.documentElement.classList.contains('theme-ocean')).toBe(true);

      applyTheme('ember');
      expect(document.documentElement.classList.contains('theme-ocean')).toBe(false);
      expect(document.documentElement.classList.contains('theme-ember')).toBe(true);
    });

    it('should remove multiple theme classes', () => {
      // Manually add multiple theme classes
      document.documentElement.classList.add('theme-ocean', 'theme-ember');

      applyTheme('forest');
      expect(document.documentElement.classList.contains('theme-ocean')).toBe(false);
      expect(document.documentElement.classList.contains('theme-ember')).toBe(false);
      expect(document.documentElement.classList.contains('theme-forest')).toBe(true);
    });

    it('should preserve non-theme classes', () => {
      document.documentElement.classList.add('some-other-class');

      applyTheme('ocean');
      expect(document.documentElement.classList.contains('some-other-class')).toBe(true);
      expect(document.documentElement.classList.contains('theme-ocean')).toBe(true);
    });
  });

  describe('setTheme', () => {
    it('should save and apply valid theme', () => {
      setTheme('ocean');

      expect(localStorageMock.getItem('app-theme')).toBe('ocean');
      expect(document.documentElement.classList.contains('theme-ocean')).toBe(true);
    });

    it('should handle invalid theme by falling back to default', () => {
      const consoleWarnSpy = vi.spyOn(console, 'warn').mockImplementation(() => {});

      setTheme('invalid-theme' as any);

      expect(localStorageMock.getItem('app-theme')).toBe(DEFAULT_THEME);
      expect(document.documentElement.classList.contains(`theme-${DEFAULT_THEME}`)).toBe(true);
      expect(consoleWarnSpy).toHaveBeenCalled();

      consoleWarnSpy.mockRestore();
    });

    it('should switch between themes correctly', () => {
      setTheme('ocean');
      expect(document.documentElement.classList.contains('theme-ocean')).toBe(true);

      setTheme('ember');
      expect(document.documentElement.classList.contains('theme-ocean')).toBe(false);
      expect(document.documentElement.classList.contains('theme-ember')).toBe(true);
    });
  });

  describe('initializeTheme', () => {
    it('should get stored theme and apply it', () => {
      localStorageMock.setItem('app-theme', 'forest');

      const theme = initializeTheme();

      expect(theme).toBe('forest');
      expect(document.documentElement.classList.contains('theme-forest')).toBe(true);
    });

    it('should apply default theme when no theme is stored', () => {
      const theme = initializeTheme();

      expect(theme).toBe(DEFAULT_THEME);
      expect(document.documentElement.classList.contains(`theme-${DEFAULT_THEME}`)).toBe(true);
    });

    it('should return the applied theme', () => {
      localStorageMock.setItem('app-theme', 'ember');

      const theme = initializeTheme();

      expect(theme).toBe('ember');
    });
  });
});
