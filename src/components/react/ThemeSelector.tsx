/**
 * Theme selector component
 * Allows users to switch between available themes
 */

import { useState } from 'react';
import { getThemes, type ThemeName } from '../../lib/themes';
import { getStoredTheme, setTheme } from '../../lib/themeManager';

export default function ThemeSelector() {
  // Initialize theme with lazy initialization to avoid effect
  const [currentTheme, setCurrentTheme] = useState<ThemeName>(() =>
    getStoredTheme(),
  );
  const [isOpen, setIsOpen] = useState(false);
  const themes = getThemes();

  const handleThemeChange = (themeName: ThemeName) => {
    setTheme(themeName);
    setCurrentTheme(themeName);
    setIsOpen(false);
  };

  const currentThemeData = themes.find((t) => t.name === currentTheme);

  // Theme color mappings for previews
  const themeColors: Record<ThemeName, { primary: string; surface: string }> = {
    seaweed: {
      primary: 'rgb(34, 197, 94)', // green-500
      surface: 'rgb(255, 255, 255)', // white
    },
    twilight: {
      primary: 'rgb(59, 130, 246)', // blue-500
      surface: 'rgb(17, 24, 39)', // gray-900
    },
  };

  return (
    <div className="relative">
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="flex items-center gap-2 px-4 py-2 rounded-lg transition-colors bg-[rgb(var(--color-surface-elevated))] hover:bg-[rgb(var(--color-surface-border))] text-[rgb(var(--color-text))] border border-[rgb(var(--color-surface-border))]"
        aria-label="Select theme"
        aria-expanded={isOpen}
      >
        <svg
          className="w-5 h-5"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M7 21a4 4 0 01-4-4V5a2 2 0 012-2h4a2 2 0 012 2v12a4 4 0 01-4 4zm0 0h12a2 2 0 002-2v-4a2 2 0 00-2-2h-2.343M11 7.343l1.657-1.657a2 2 0 012.828 0l2.829 2.829a2 2 0 010 2.828l-8.486 8.485M7 17h.01"
          />
        </svg>
        <span className="font-medium">{currentThemeData?.displayName}</span>
        <svg
          className={`w-4 h-4 transition-transform ${isOpen ? 'rotate-180' : ''}`}
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M19 9l-7 7-7-7"
          />
        </svg>
      </button>

      {isOpen && (
        <>
          {/* Backdrop */}
          <div
            className="fixed inset-0 z-10"
            onClick={() => setIsOpen(false)}
            aria-hidden="true"
          />

          {/* Dropdown menu */}
          <div className="absolute right-0 mt-2 w-48 rounded-lg shadow-xl border border-[rgb(var(--color-surface-border))] bg-[rgb(var(--color-surface-elevated))] z-20 overflow-hidden">
            <div className="p-2">
              {themes.map((theme) => (
                <button
                  key={theme.name}
                  onClick={() => handleThemeChange(theme.name)}
                  className={`w-full flex items-center gap-3 px-3 py-2 rounded-lg transition-all ${
                    currentTheme === theme.name
                      ? 'bg-[rgb(var(--color-primary))] text-white outline outline-2 outline-[rgb(var(--color-primary-dark))]'
                      : 'hover:bg-[rgb(var(--color-surface-border))] text-[rgb(var(--color-text))]'
                  }`}
                >
                  {/* Color preview circles */}
                  <div className="flex gap-1">
                    <div
                      className="w-4 h-4 rounded-full border border-black/10"
                      style={{ backgroundColor: themeColors[theme.name].primary }}
                      aria-hidden="true"
                    />
                    <div
                      className="w-4 h-4 rounded-full border border-black/10"
                      style={{ backgroundColor: themeColors[theme.name].surface }}
                      aria-hidden="true"
                    />
                  </div>
                  <span className="font-medium">{theme.displayName}</span>
                </button>
              ))}
            </div>
          </div>
        </>
      )}
    </div>
  );
}
