# Market development recipes

# Frontend

# Start frontend on localhost only (default port 4321)
start-frontend-local:
    npx astro dev

# Start frontend on all network interfaces (0.0.0.0:4321) for LAN access
start-frontend-lan:
    npx astro dev --host 0.0.0.0

# Build frontend for production
build-frontend:
    npx astro build

# Backend

# Start local backend (Supabase)
start-backend:
    npx supabase start

# Stop local backend
stop-backend:
    npx supabase stop

# Database

# Generate migration from schema changes (requires migration name)
# Usage: just db-diff my_migration_name
db-diff name:
    npx supabase db diff --local --schema public {{name}}

# Reset local database with fresh schema and seed data
db-reset:
    npx supabase db reset --local

# Generate TypeScript types from database schema
db-types:
    npx supabase gen types typescript --local > src/lib/database.types.ts

# Code Quality

# Run ESLint
lint:
    npx eslint .

# Fix ESLint issues
lint-fix:
    npx eslint . --fix

# Format code with Prettier
format:
    npx prettier --write .

# Check formatting with Prettier
format-check:
    npx prettier --check .

# Run TypeScript type checking
type-check:
    npx astro check

# Testing

# Run unit tests with Vitest
test-unit:
    npx vitest run

# Run E2E tests with Playwright
test-e2e:
    npx playwright test
