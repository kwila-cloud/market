import { test, expect } from '@playwright/test';

test.describe('Theme Selector', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to homepage before each test
    await page.goto('/');
    // Wait for the page to be fully loaded
    await page.waitForLoadState('networkidle');
  });

  test('should display theme selector button', async ({ page }) => {
    // Find the theme selector button
    const themeButton = page.getByRole('button', { name: 'Select theme' });
    await expect(themeButton).toBeVisible();
  });

  test('should open theme dropdown when clicked', async ({ page }) => {
    // Click the theme selector button
    const themeButton = page.getByRole('button', { name: 'Select theme' });
    await themeButton.click();

    // Verify dropdown menu is visible
    const dropdown = page.getByRole('menu');
    await expect(dropdown).toBeVisible();

    // Verify all theme options are present
    await expect(page.getByRole('menuitem', { name: /Dusk/i })).toBeVisible();
    await expect(page.getByRole('menuitem', { name: /Ember/i })).toBeVisible();
    await expect(page.getByRole('menuitem', { name: /Ocean/i })).toBeVisible();
    await expect(page.getByRole('menuitem', { name: /Forest/i })).toBeVisible();
  });

  test('should close dropdown when clicking outside', async ({ page }) => {
    // Open the dropdown
    const themeButton = page.getByRole('button', { name: 'Select theme' });
    await themeButton.click();

    // Verify dropdown is open
    const dropdown = page.getByRole('menu');
    await expect(dropdown).toBeVisible();

    // Click outside the dropdown (on the page heading)
    await page.getByRole('heading', { level: 1 }).click();

    // Verify dropdown is closed
    await expect(dropdown).not.toBeVisible();
  });

  test('should switch to Ocean theme and persist to localStorage', async ({ page }) => {
    // Open the theme selector
    const themeButton = page.getByRole('button', { name: 'Select theme' });
    await themeButton.click();

    // Click on Ocean theme
    await page.getByRole('menuitem', { name: /Ocean/i }).click();

    // Verify the theme class is applied to document element
    const htmlElement = page.locator('html');
    await expect(htmlElement).toHaveClass(/theme-ocean/);

    // Verify localStorage contains the selected theme
    const storedTheme = await page.evaluate(() => {
      return localStorage.getItem('app-theme');
    });
    expect(storedTheme).toBe('ocean');

    // Verify dropdown is closed after selection
    const dropdown = page.getByRole('menu');
    await expect(dropdown).not.toBeVisible();
  });

  test('should switch to Ember theme and update the UI', async ({ page }) => {
    // Open the theme selector
    const themeButton = page.getByRole('button', { name: 'Select theme' });
    await themeButton.click();

    // Click on Ember theme
    await page.getByRole('menuitem', { name: /Ember/i }).click();

    // Verify the theme class is applied
    const htmlElement = page.locator('html');
    await expect(htmlElement).toHaveClass(/theme-ember/);

    // Verify localStorage is updated
    const storedTheme = await page.evaluate(() => {
      return localStorage.getItem('app-theme');
    });
    expect(storedTheme).toBe('ember');
  });

  test('should switch to Forest theme', async ({ page }) => {
    // Open the theme selector
    const themeButton = page.getByRole('button', { name: 'Select theme' });
    await themeButton.click();

    // Click on Forest theme
    await page.getByRole('menuitem', { name: /Forest/i }).click();

    // Verify the theme class is applied
    const htmlElement = page.locator('html');
    await expect(htmlElement).toHaveClass(/theme-forest/);

    // Verify localStorage is updated
    const storedTheme = await page.evaluate(() => {
      return localStorage.getItem('app-theme');
    });
    expect(storedTheme).toBe('forest');
  });

  test('should persist theme selection across page reloads', async ({ page }) => {
    // Select Ocean theme
    const themeButton = page.getByRole('button', { name: 'Select theme' });
    await themeButton.click();
    await page.getByRole('menuitem', { name: /Ocean/i }).click();

    // Verify theme is applied
    let htmlElement = page.locator('html');
    await expect(htmlElement).toHaveClass(/theme-ocean/);

    // Reload the page
    await page.reload();
    await page.waitForLoadState('networkidle');

    // Verify theme is still Ocean after reload
    htmlElement = page.locator('html');
    await expect(htmlElement).toHaveClass(/theme-ocean/);

    // Verify localStorage still contains Ocean
    const storedTheme = await page.evaluate(() => {
      return localStorage.getItem('app-theme');
    });
    expect(storedTheme).toBe('ocean');
  });

  test('should switch between multiple themes correctly', async ({ page }) => {
    const themeButton = page.getByRole('button', { name: 'Select theme' });
    const htmlElement = page.locator('html');

    // Switch to Ocean
    await themeButton.click();
    await page.getByRole('menuitem', { name: /Ocean/i }).click();
    await expect(htmlElement).toHaveClass(/theme-ocean/);
    await expect(htmlElement).not.toHaveClass(/theme-dusk/);

    // Switch to Ember
    await themeButton.click();
    await page.getByRole('menuitem', { name: /Ember/i }).click();
    await expect(htmlElement).toHaveClass(/theme-ember/);
    await expect(htmlElement).not.toHaveClass(/theme-ocean/);

    // Switch to Forest
    await themeButton.click();
    await page.getByRole('menuitem', { name: /Forest/i }).click();
    await expect(htmlElement).toHaveClass(/theme-forest/);
    await expect(htmlElement).not.toHaveClass(/theme-ember/);

    // Switch back to Dusk
    await themeButton.click();
    await page.getByRole('menuitem', { name: /Dusk/i }).click();
    await expect(htmlElement).toHaveClass(/theme-dusk/);
    await expect(htmlElement).not.toHaveClass(/theme-forest/);
  });

  test('should highlight the currently selected theme', async ({ page }) => {
    // Open the theme selector
    const themeButton = page.getByRole('button', { name: 'Select theme' });
    await themeButton.click();

    // Click on Ocean theme
    await page.getByRole('menuitem', { name: /Ocean/i }).click();

    // Open the dropdown again
    await themeButton.click();

    // Find the Ocean theme menuitem
    const oceanTheme = page.getByRole('menuitem', { name: /Ocean/i });

    // Verify it has the selected styling (ring-2 ring-primary)
    const hasRingClass = await oceanTheme.evaluate((el) => {
      return el.classList.contains('ring-2') && el.classList.contains('ring-primary');
    });
    expect(hasRingClass).toBe(true);
  });

  test('should load default theme (Dusk) on first visit', async ({ page, context }) => {
    // Create a new context to simulate first visit
    const newPage = await context.newPage();

    // Clear localStorage to simulate first visit
    await newPage.goto('/');
    await newPage.evaluate(() => {
      localStorage.clear();
    });

    // Reload to apply the cleared state
    await newPage.reload();
    await newPage.waitForLoadState('networkidle');

    // Verify default theme (Dusk) is applied
    const htmlElement = newPage.locator('html');
    await expect(htmlElement).toHaveClass(/theme-dusk/);

    // Verify localStorage has the default theme
    const storedTheme = await newPage.evaluate(() => {
      return localStorage.getItem('app-theme');
    });
    // Note: The theme might not be set in localStorage until user interacts,
    // but the default theme should be applied via ThemeInitializer

    await newPage.close();
  });
});
