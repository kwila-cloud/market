# Contributing Guidelines

## Architecture

Refer to the [architecture document](/ARCHITECTURE.md)

## Infrastructure

Refer to the [infrastructure document](/INFRASTRUCTURE.md)

## Getting Started

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and Docker Compose
- [Node.js](https://nodejs.org/) 18+ and npm (for local development scripts)
- Git

### Local Development Setup

This project uses Docker Compose to run the full stack locally, including Supabase (PostgreSQL, Auth, Storage, API) and supporting services.

#### First Time Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd market
   ```

2. **Create environment file**
   ```bash
   cp .env.example .env
   ```

   The default values in `.env.example` work for local development. You only need to customize:
   - SMTP settings if you want to test email notifications
   - Twilio settings if you want to test phone authentication
   - JWT_SECRET and POSTGRES_PASSWORD for better security (optional for local dev)

3. **Install npm dependencies**
   ```bash
   npm install
   ```

4. **Start Docker services**
   ```bash
   docker compose up -d
   ```

   This starts all services in the background:
   - PostgreSQL database (port 5432)
   - Supabase Studio admin UI (port 3000)
   - Kong API gateway (port 8000)
   - Auth, Storage, Realtime, and other Supabase services

5. **Wait for services to be ready** (~15-30 seconds)
   ```bash
   # Watch logs to see when services are ready
   docker compose logs -f
   # Press Ctrl+C to exit logs
   ```

6. **Run database migrations**
   ```bash
   npm run docker:db:migrate
   ```

   This creates all database tables, indexes, and RLS policies.

7. **Seed test data** (optional but recommended)
   ```bash
   npm run docker:db:seed
   ```

   This creates 5 test users, sample items, connections, and messages for local testing.

8. **Start the Astro dev server**
   ```bash
   npm run dev
   ```

9. **Access the application**
   - Application: http://localhost:4321
   - Supabase Studio: http://localhost:3000
   - Supabase API: http://localhost:8000

#### Daily Development

```bash
# Start all Docker services
docker compose up -d

# Start Astro dev server
npm run dev

# View logs from all services
docker compose logs -f

# Stop all services (keeps data)
docker compose down

# Restart all services
docker compose restart
```

#### Database Management

```bash
# Run migrations
npm run docker:db:migrate

# Seed test data
npm run docker:db:seed

# Full reset (WARNING: deletes all data and recreates everything)
npm run docker:db:reset

# Access PostgreSQL directly
docker compose exec db psql -U postgres -d postgres
```

#### Useful Docker Commands

```bash
# View running containers
docker compose ps

# View logs for specific service
docker compose logs -f db          # Database logs
docker compose logs -f kong        # API gateway logs
docker compose logs -f auth        # Auth service logs
docker compose logs -f storage     # Storage service logs

# Stop and remove all containers + volumes (full reset)
docker compose down -v

# Rebuild containers (after docker-compose.yml changes)
docker compose up -d --build
```

#### Supabase Studio

Access the Supabase Studio admin UI at http://localhost:3000 to:
- Browse database tables and data
- Test SQL queries
- View and test RLS policies
- Manage authentication users
- Browse storage buckets
- View API documentation

#### Testing

```bash
# Run unit tests
npm run test:unit

# Run unit tests in watch mode
npm run test:watch

# Run E2E tests
npm run test:e2e

# Run all tests
npm test
```

#### Code Quality

```bash
# Lint code
npm run lint

# Fix linting issues
npm run lint:fix

# Format code
npm run format

# Check formatting
npm run format:check

# Type check
npm run type-check
```

#### Troubleshooting

**Services won't start:**
- Ensure Docker is running: `docker info`
- Check for port conflicts: `lsof -i :5432,3000,8000` (macOS/Linux)
- Remove old containers: `docker compose down -v`

**Database connection errors:**
- Wait longer for services to initialize (30-60 seconds)
- Check database logs: `docker compose logs db`
- Verify migrations ran: `docker compose exec db psql -U postgres -d postgres -c "\dt"`

**Migrations fail:**
- Reset database: `npm run docker:db:reset`
- Ensure `.env` file exists with correct values
- Check migration files in `supabase/migrations/`

**Can't access Supabase Studio:**
- Verify Studio is running: `docker compose ps studio`
- Check Studio logs: `docker compose logs studio`
- Try restarting: `docker compose restart studio`

**Environment variables not loading:**
- Ensure `.env` file exists in project root
- Restart Docker services: `npm run docker:restart`
- Verify variables are exported: `docker compose config`

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
