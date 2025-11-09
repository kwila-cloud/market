# Contributing Guidelines

## Architecture

Refer to the [architecture document](/ARCHITECTURE.md)

## Getting Started

TODO: add basic list of commands useful in a local dev environment (using docker compose).

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
