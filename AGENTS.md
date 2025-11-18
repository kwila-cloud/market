# Agent Guidelines

**Project**: Market - trust-based, invite-only marketplace for local artisans and small businesses
**License**: MIT
**Status**: Early development phase

## Project Context

This is a request-driven marketplace that prioritizes relationships over profit. Users post what they're looking for ("buy" items) or offer items/services ("sell" items), then connect through messaging threads. The platform is invite-only during beta to ensure trust and authenticity.

**Key Features**: Request-driven commerce, three item categories (new/resale/services), connection-based trust system, privacy-first design with visibility controls.

## Technical Stack (High Level)

- **Frontend**: Astro 5.x with React 19 islands
- **Backend**: Supabase (PostgreSQL, auth, storage)
- **Deployment**: Cloudflare Workers
- **Styling**: Tailwind CSS 4.x
- **Forms**: React Hook Form + Zod validation

## Essential Files & Structure

```
/src/
├── pages/              # Astro routes (.astro files)
├── components/react/   # Interactive components (.tsx)
├── components/astro/   # Static components (.astro)
├── layouts/            # Page layouts
└── lib/               # Utilities (supabase.ts, auth.ts)

/specs/                # Feature specifications (see CONTRIBUTING.md)
/supabase/migrations/  # Database schema
/tests/               # Unit & E2E tests
```

## What Agents Should Know

### Development Workflow

- **Local development**: `npm run dev` - Start Astro dev server (localhost:4321)
- **Build**: `npm run build` - Build for production
- **Preview**: `npm run preview` - Preview production build
- **Type checking**: `npm run type-check` - Run Astro type checker
- **Linting**: `npm run lint` or `npm run lint:fix` - ESLint checks
- **Formatting**: `npm run format` or `npm run format:check` - Prettier formatting
- **Testing**:
  - `npm test` - Run unit tests with Vitest
  - `npm run test:unit` - Run unit tests with Vitest
  - `npm run test:e2e` - Run E2E tests with Playwright
  - `npm run test:watch` - Run unit tests in watch mode
  - Note: CI runs unit and E2E tests separately

### Security & Best Practices

- **Never commit secrets** or environment variables
- **Validate user input** and enforce RLS policies
- **Use TypeScript strict mode**
- **Don't modify git config**
- **Always use pre-existing layouts** from `src/layouts/` for page structure consistency

### Contribution Process

- **Specs**: Feature requests → `specs/` directory (see CONTRIBUTING.md)
- **Issues**: Bug reports only in GitHub
- **Code style**: See CONTRIBUTING.md for full guidelines

### Files You Should NOT Touch Without Coordination

- `.github/workflows/` (CI/CD configuration - coordinate changes)
- `docker-compose.yml` (dev environment setup - when implemented)
- `wrangler.jsonc` (Cloudflare Workers config)
- `astro.config.mjs` (Astro configuration - coordinate with team)
- `package.json` (dependencies - coordinate changes)
- `vitest.config.ts` (test configuration - coordinate changes)
- `playwright.config.ts` (E2E test configuration - coordinate changes)
- Supabase configuration files (when implemented)

## Where to Find More Info

- **Architecture details**: [ARCHITECTURE.md](./ARCHITECTURE.md)
- **Contributing guidelines**: [CONTRIBUTING.md](./CONTRIBUTING.md)
- **Project overview**: [README.md](./README.md)
- **Current specs**: [`specs/`](./specs/) directory

## Common Agent Tasks

1. **Reading code**: Start with `src/lib/` for utilities, `src/pages/` for routes
2. **Adding features**: Check existing specs, create new spec if needed
3. **Bug fixes**: Check if related spec exists, verify with tests
4. **Tests**:
   - Run `npm test` before committing changes
   - Write unit tests for utilities in `tests/unit/`
   - Write E2E tests for user flows in `tests/e2e/`
   - See `tests/README.md` for testing guidelines
5. **Dependencies**: Check package.json before using new libraries
6. **Pull Requests**: Use short, descriptive PR titles (3-7 words). See CONTRIBUTING.md for examples

Be sure to refer to CONTRIBUTING.md for detailed guidelines on contributing to this project.
