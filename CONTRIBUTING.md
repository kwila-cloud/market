# Contributing Guidelines

## Architecture

Refer to the [architecture document](/ARCHITECTURE.md)

## Infrastructure

Refer to the [infrastructure document](/INFRASTRUCTURE.md)

## Getting Started

### Prerequisites

- Node.js 20+
- Docker (for local Supabase)
- Supabase CLI (`npm install -g supabase` or use `npx supabase`)

### Setup

```bash
# Clone the repository
git clone https://github.com/kwila-cloud/market.git
cd market

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env

# Start the backend (Supabase local)
npm run start:backend

# In a new terminal, start the frontend
npm run start:frontend
```

The frontend will be available at http://localhost:4321

### Environment Variables

Copy `.env.example` to `.env` and update the values:

```bash
cp .env.example .env
```

**Required variables:**

- `PUBLIC_SUPABASE_URL` - Supabase API URL (default: `http://localhost:54321`)
- `PUBLIC_SUPABASE_ANON_KEY` - Supabase publishable key

To get the publishable key for local development:

1. Run `npm run start:backend`
2. Copy the `Publishable key` from the output
3. Paste it as the value for `PUBLIC_SUPABASE_ANON_KEY` in your `.env` file

For production, these will be set in your deployment environment (e.g., Cloudflare Workers).

### Common Commands

```bash
# Development
npm run start:frontend    # Start Astro dev server
npm run start:backend     # Start local Supabase
npm run stop:backend      # Stop local Supabase

# Code quality
npm run lint              # Run ESLint
npm run lint:fix          # Fix ESLint issues
npm run format            # Format with Prettier
npm run format:check      # Check formatting
npm run type-check        # TypeScript type checking

# Testing
npm run test:unit         # Run unit tests with Vitest
npm run test:e2e          # Run E2E tests with Playwright

# Database
npm run db:types          # Generate TypeScript types from schema
npm run db:reset          # Reset DB - fresh schema and seed data
```

### Direct CLI Access

For advanced operations, use `npx` to access the CLIs directly:

```bash
npx astro --help          # Astro CLI
npx supabase --help       # Supabase CLI
```

## GitHub Issues

GitHub issues should be used for bug reports only. Feature requests and refactor requests should be contributed by adding a new file to the `specs/` directory.

## Specs

Specs are stored in the `specs/` directory.

Each spec should be a markdown file with a numeric prefix - for example, `000-mvp.md`.

Each spec file should contain the following:

- Title
- Description
  - A few sentences describing why this change will be useful.
- Design decisions
  - An optional list of design decisions that were made, with pros and cons for the different options considered.
- Task List
  - A checklist of tasks for the implementing the change.

## Code Style

- **TypeScript**: Strict mode, use proper typing, avoid `any`
- **Naming**: camelCase (variables/functions), PascalCase (components/types), UPPER_SNAKE_CASE (constants)
- **Imports**: Group order: React → libraries → local modules → relative paths
- **Components**: React functional components with TypeScript interfaces
- **Error Handling**: Use try-catch with proper error types, display user-friendly messages
- **Database**: Use singular table names, proper foreign keys, RLS policies
- **Formatting**: Prettier/ESLint, 2-space tabs, trailing commas
- **Files**: Astro (.astro), React (.tsx), TypeScript (.ts), CSS (.css)
- **State**: React Context + Zustand for complex state, useState for simple
- **Security**: Never log secrets, validate user input, enforce RLS in all queries

## Commit Messages and PR Titles

### Commit Messages

Use conventional commit format:

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

**Examples:**

```
feat(0): add astro project with react islands
fix: resolve build error in home page
docs: update api documentation
```

### Pull Request Titles

Keep PR titles **short and descriptive**, typically 3-7 words:

**Good examples:**

- `feat: basic infrastructure for home page`
- `fix: tailwind css styling issues`
- `docs: update contributing guidelines`

**Bad examples (avoid):**

- `feat(0): infrastructure setup for basic home page with astro 5.x and react 19 islands including typescript strict mode and tailwind css 4.x integration and environment variable configuration`
- `update the home page` (too vague)

### What Went Wrong

Remember: PR titles should quickly communicate the core change, not list every technical detail. Use the body of the PR for detailed explanations.

## Database

### Schema Migrations

Database changes should be made to the schema files in `supabase/schemas`, then run `npx run supbase db -f <migration-name>` to generate migrations.

Some schema changes are not compatible with automatic migration generation. See [here](https://supabase.com/docs/guides/local-development/declarative-database-schemas#known-caveats) for things that will require manual migration scripts.
