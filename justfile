# Market development recipes

# Frontend

# Start frontend on localhost only (default port 4321)
start-frontend-local:
    npm run start:frontend

# Start frontend on all network interfaces (0.0.0.0:4321) for LAN access
start-frontend-lan:
    npm run start:frontend -- --host 0.0.0.0

# Backend

# Start local backend (Supabase)
start-backend:
    npm run start:backend

# Stop local backend
stop-backend:
    npm run stop:backend

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
