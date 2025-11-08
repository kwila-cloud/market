# Agent Guidelines for A Market

## Commands
- **Development**: `docker-compose up -d` (full stack via Docker)
- **Tests**: `docker-compose exec app npm run test` (unit), `docker-compose exec app npm run test:e2e` (integration)
- **Single test**: `docker-compose exec app npm run test path/to/file.test.ts`
- **Database**: `docker-compose exec supabase supabase migration up`
- **Build**: `docker-compose exec app npm run build`

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

## Architecture
- **Framework**: Astro 5.x (SSR) + React 19 (islands)
- **Backend**: Supabase (PostgreSQL + Auth + Storage)
- **Styling**: Tailwind CSS 4.x utility classes
- **Testing**: Vitest (unit) + Playwright (E2E)
- **Auth**: Supabase Auth with email/phone OTP