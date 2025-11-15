# Testing Guide

This directory contains the test suite for the Astro/React marketplace application.

## Test Structure

```
tests/
├── unit/          # Unit tests (Vitest)
│   ├── themes.test.ts
│   └── themeManager.test.ts
├── e2e/           # End-to-end tests (Playwright)
│   └── theme-selector.spec.ts
├── setup.ts       # Vitest test setup
└── README.md      # This file
```

## Running Tests

### Quick Test (Unit Tests)

```bash
npm test
```

Runs unit tests with Vitest. This is the fastest way to get feedback during development.

**Note**: To run all tests (unit + E2E), run both `npm run test:unit` and `npm run test:e2e` separately. CI runs these independently to ensure both test suites execute even if one fails.

### Unit Tests

```bash
npm run test:unit
```

Run unit tests with Vitest. These tests validate:

- Utility functions
- Business logic
- Data transformations
- State management

### E2E Tests Only

```bash
npm run test:e2e
```

Run end-to-end tests with Playwright. These tests validate:

- User flows
- Component interactions
- Browser behavior
- LocalStorage persistence

### Watch Mode (Unit Tests)

```bash
npm run test:watch
```

Run unit tests in watch mode for development. Tests will re-run automatically when files change.

## Writing Tests

### Unit Tests

Unit tests are written using Vitest and located in `tests/unit/`. They use a Jest-like API:

```typescript
import { describe, it, expect } from 'vitest';
import { myFunction } from '../../src/lib/utils';

describe('myFunction', () => {
  it('should return expected value', () => {
    expect(myFunction('input')).toBe('expected output');
  });
});
```

### E2E Tests

E2E tests are written using Playwright and located in `tests/e2e/`:

```typescript
import { test, expect } from '@playwright/test';

test('should display homepage', async ({ page }) => {
  await page.goto('/');
  await expect(page.getByRole('heading', { level: 1 })).toBeVisible();
});
```

## CI/CD Integration

Tests run automatically in GitHub Actions on every pull request.

The CI pipeline runs unit tests and E2E tests in **separate jobs** to ensure both test suites execute even if one fails:

1. **Unit Tests**: Run on ubuntu-latest with Node 20
2. **E2E Tests**: Run on ubuntu-latest with Chromium browser

Failed tests will block the merge.

## Test Coverage

Priority test flows (as per ARCHITECTURE.md):

- [x] Theme selection and persistence
- [ ] Authentication (signup flow)
- [ ] Item CRUD operations with RLS
- [ ] Messaging threads
- [ ] Connection requests

## Docker Compose Support

E2E tests can run in the Docker Compose environment. To test against the full stack:

```bash
# Start services
docker-compose up -d

# Run E2E tests against local environment
npm run test:e2e
```

## Troubleshooting

### Playwright Browsers Not Installed

If you get errors about missing browsers:

```bash
npx playwright install chromium
```

### Port Already in Use

If the dev server fails to start during E2E tests:

```bash
# Kill any processes using port 4321
lsof -ti:4321 | xargs kill -9
```

### Test Timeout

If E2E tests timeout, increase the timeout in `playwright.config.ts`:

```typescript
webServer: {
  timeout: 120000, // Increase this value
}
```

## Best Practices

1. **Unit Tests**
   - Test pure functions and utilities
   - Mock external dependencies
   - Keep tests fast and isolated
   - Aim for high coverage on business logic

2. **E2E Tests**
   - Test critical user paths
   - Use page objects for complex flows
   - Keep tests independent and idempotent
   - Clean up test data after each test

3. **General**
   - Write descriptive test names
   - Follow the AAA pattern (Arrange, Act, Assert)
   - Keep tests maintainable and readable
   - Update tests when features change
