import { describe, it, expect } from 'vitest';
import {
  themes,
  DEFAULT_THEME,
  getThemes,
  isValidTheme,
} from '../../src/lib/themes';

describe('themes', () => {
  describe('themes object', () => {
    it('should contain all expected themes', () => {
      expect(themes).toHaveProperty('dusk');
      expect(themes).toHaveProperty('ember');
      expect(themes).toHaveProperty('ocean');
      expect(themes).toHaveProperty('forest');
    });

    it('should have correct structure for each theme', () => {
      Object.values(themes).forEach((theme) => {
        expect(theme).toHaveProperty('name');
        expect(theme).toHaveProperty('displayName');
        expect(typeof theme.name).toBe('string');
        expect(typeof theme.displayName).toBe('string');
      });
    });

    it('should have matching name properties', () => {
      Object.entries(themes).forEach(([key, theme]) => {
        expect(theme.name).toBe(key);
      });
    });
  });

  describe('DEFAULT_THEME', () => {
    it('should be a valid theme name', () => {
      expect(DEFAULT_THEME).toBe('dusk');
    });

    it('should exist in themes object', () => {
      expect(themes).toHaveProperty(DEFAULT_THEME);
    });
  });

  describe('getThemes', () => {
    it('should return an array', () => {
      const result = getThemes();
      expect(Array.isArray(result)).toBe(true);
    });

    it('should return all themes', () => {
      const result = getThemes();
      expect(result).toHaveLength(4);
    });

    it('should return theme objects with correct properties', () => {
      const result = getThemes();
      result.forEach((theme) => {
        expect(theme).toHaveProperty('name');
        expect(theme).toHaveProperty('displayName');
      });
    });

    it('should include all expected theme names', () => {
      const result = getThemes();
      const names = result.map((theme) => theme.name);
      expect(names).toContain('dusk');
      expect(names).toContain('ember');
      expect(names).toContain('ocean');
      expect(names).toContain('forest');
    });
  });

  describe('isValidTheme', () => {
    it('should return true for valid theme names', () => {
      expect(isValidTheme('dusk')).toBe(true);
      expect(isValidTheme('ember')).toBe(true);
      expect(isValidTheme('ocean')).toBe(true);
      expect(isValidTheme('forest')).toBe(true);
    });

    it('should return false for invalid theme names', () => {
      expect(isValidTheme('invalid')).toBe(false);
      expect(isValidTheme('light')).toBe(false);
      expect(isValidTheme('dark')).toBe(false);
      expect(isValidTheme('')).toBe(false);
    });

    it('should return false for non-string values', () => {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      expect(isValidTheme(null as any)).toBe(false);
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      expect(isValidTheme(undefined as any)).toBe(false);
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      expect(isValidTheme(123 as any)).toBe(false);
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      expect(isValidTheme({} as any)).toBe(false);
    });

    it('should be case-sensitive', () => {
      expect(isValidTheme('Dusk')).toBe(false);
      expect(isValidTheme('DUSK')).toBe(false);
    });
  });
});
