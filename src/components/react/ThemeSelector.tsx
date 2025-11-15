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
    getStoredTheme()
  );
  const [isOpen, setIsOpen] = useState(false);
  const themes = getThemes();

  const handleThemeChange = (themeName: ThemeName) => {
    setTheme(themeName);
    setCurrentTheme(themeName);
    setIsOpen(false);
  };

  return (
    <div className="relative">
      <button
        type="button"
        onClick={() => setIsOpen(!isOpen)}
        className="flex items-center justify-center w-10 h-10 rounded-lg transition-all bg-[rgb(var(--color-surface-elevated))] hover:bg-[rgb(var(--color-surface-border))] hover:ring-2 hover:ring-[oklch(var(--color-secondary))] text-[rgb(var(--color-text))] border border-[rgb(var(--color-surface-border))]"
        aria-label="Select theme"
        aria-expanded={isOpen}
      >
        <svg
          className="w-5 h-5"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
          xmlns="http://www.w3.org/2000/svg"
          aria-hidden="true"
          focusable="false"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M7 21a4 4 0 01-4-4V5a2 2 0 012-2h4a2 2 0 012 2v12a4 4 0 01-4 4zm0 0h12a2 2 0 002-2v-4a2 2 0 00-2-2h-2.343M11 7.343l1.657-1.657a2 2 0 012.828 0l2.829 2.829a2 2 0 010 2.828l-8.486 8.485M7 17h.01"
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
          <div
            className="absolute right-0 mt-2 w-48 rounded-lg border border-[rgb(var(--color-surface-border))] bg-[rgb(var(--color-surface-elevated))] z-20 overflow-hidden"
            role="menu"
          >
            <div className="p-2">
              {themes.map((theme) => (
                <button
                  key={theme.name}
                  type="button"
                  onClick={() => handleThemeChange(theme.name)}
                  className={`w-full flex items-center gap-3 px-3 py-2 rounded-lg transition-all text-[rgb(var(--color-text))] ${currentTheme === theme.name
                      ? 'ring-2 ring-[oklch(var(--color-primary))] bg-[rgb(var(--color-surface-border))]'
                      : 'hover:bg-[rgb(var(--color-surface-border))]'
                    }`}
                  role="menuitem"
                >
                  {/* Color preview - surface rectangle with primary and secondary dots */}
                  <div className={`theme-${theme.name}`}>
                    <div
                      className={`flex items-center justify-center gap-1 px-2 py-1.5 rounded border border-black/10  bg-[rgb(var(--color-surface))]`}
                      aria-hidden="true"
                    >
                      <div
                        className="w-2 h-2 rounded-full border border-black/10 bg-[oklch(var(--color-primary))]"
                      />
                      <div
                        className="w-2 h-2 rounded-full border border-black/10 bg-[oklch(var(--color-secondary))]"
                      />
                    </div>
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
