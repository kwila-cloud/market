# Docker Development Environment

This document describes how to set up and use the Docker-based local development environment for the Market application.

## Overview

The development environment runs the complete stack in Docker containers:

- **Astro dev server** - Frontend application with hot reload
- **Supabase services** - Complete backend stack including:
  - PostgreSQL database
  - GoTrue (authentication)
  - PostgREST (API)
  - Realtime server
  - Storage API
  - Kong API gateway
  - Supabase Studio (database UI)
  - Analytics (Logflare)

## Prerequisites

- **Docker** - Install from [docker.com](https://www.docker.com/get-started)
- **Docker Compose** - Included with Docker Desktop
- **Git** - For cloning the repository

### System Requirements

- At least 4GB of available RAM
- 10GB of free disk space
- Docker Engine 20.10+ or Docker Desktop 4.0+

## First-Time Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd market
```

### 2. Configure Environment Variables

The repository includes a `.env` file with default development settings. For a new setup, you should:

```bash
# Copy the example file (optional, .env already exists)
cp .env.example .env
```

**Important**: The default `.env` file contains insecure passwords and keys suitable only for local development. Never use these in production.

### 3. Start All Services

```bash
docker compose up -d
```

This will:
- Pull all required Docker images (first time only, ~5-10 minutes)
- Start all Supabase services
- Build and start the Astro dev server
- Run database initialization scripts

### 4. Wait for Services to Be Ready

Check that all services are healthy:

```bash
docker compose ps
```

All services should show status as `running (healthy)`. This may take 1-2 minutes after startup.

## Accessing Services

Once running, you can access:

| Service | URL | Credentials |
|---------|-----|-------------|
| **Astro App** | http://localhost:4321 | N/A |
| **Supabase Studio** | http://localhost:54323 | Username: `supabase`<br>Password: `this_password_is_insecure_and_should_be_updated` |
| **Supabase API** | http://localhost:54321 | API keys in `.env` |
| **PostgreSQL** | localhost:5432 | User: `postgres`<br>Password: `your-super-secret-and-long-postgres-password` |

## Common Commands

### Starting and Stopping

```bash
# Start all services in background
docker compose up -d

# Stop all services (preserves data)
docker compose down

# Stop and remove all data (fresh start)
docker compose down -v

# Restart a specific service
docker compose restart app
docker compose restart db
```

### Viewing Logs

```bash
# View all logs
docker compose logs -f

# View logs for specific service
docker compose logs -f app
docker compose logs -f db
docker compose logs -f auth

# View last 100 lines
docker compose logs --tail=100 app
```

### Database Operations

```bash
# Connect to PostgreSQL with psql
npm run db:psql

# View database logs
npm run db:logs

# Run migrations (when migration files exist)
npm run db:migrate
```

### Rebuilding Services

```bash
# Rebuild Astro app container (after package.json changes)
docker compose build app
docker compose up -d app

# Rebuild all containers
docker compose build
docker compose up -d
```

## Development Workflow

### Making Code Changes

The Astro dev server has hot reload enabled via volume mounts. Simply edit files in your editor and changes will be reflected immediately:

1. Edit files in `src/`
2. Save
3. Browser automatically refreshes (or refresh manually)

**Note**: Changes to `package.json`, `astro.config.mjs`, or other build configuration files require rebuilding the container:

```bash
docker compose build app
docker compose up -d app
```

### Working with the Database

#### Using Supabase Studio

1. Navigate to http://localhost:54323
2. Login with credentials (see table above)
3. Use the Table Editor, SQL Editor, and other tools

#### Using psql

```bash
# Connect to database
npm run db:psql

# Inside psql, you can run queries:
\dt                # List tables
\d+ users          # Describe table
SELECT * FROM users;
```

#### Database Migrations

Place SQL migration files in `supabase/migrations/`. They will be automatically loaded when the database starts.

**Migration file naming convention**: `001_description.sql`, `002_description.sql`, etc.

Example migration file (`supabase/migrations/001_initial_schema.sql`):

```sql
-- Create users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  display_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

To apply migrations to an already-running database, restart it:

```bash
docker compose restart db
```

### Working with Environment Variables

Environment variables are loaded from `.env` in the project root. After changing `.env`:

1. Restart the affected services:
   ```bash
   docker compose up -d
   ```

2. For Astro app changes, you may need to rebuild:
   ```bash
   docker compose build app
   docker compose up -d app
   ```

## Troubleshooting

### Services Won't Start

**Check Docker is running**:
```bash
docker info
```

**Check for port conflicts**:
```bash
# On Linux/macOS
lsof -i :4321
lsof -i :54321
lsof -i :54323
lsof -i :5432

# On Windows (PowerShell)
netstat -ano | findstr "4321"
```

**View service logs**:
```bash
docker compose logs <service-name>
```

### Database Connection Errors

**Verify database is healthy**:
```bash
docker compose ps db
```

**Check database logs**:
```bash
docker compose logs db
```

**Reset database** (warning: destroys all data):
```bash
docker compose down -v
docker compose up -d
```

### Astro App Not Loading

**Check app logs**:
```bash
docker compose logs -f app
```

**Rebuild container**:
```bash
docker compose build app
docker compose up -d app
```

**Verify Kong gateway is running**:
```bash
docker compose ps kong
```

### Out of Disk Space

Docker can accumulate images and volumes over time:

```bash
# Remove unused images and volumes
docker system prune -a --volumes

# Check disk usage
docker system df
```

### Permission Errors (Linux)

If you encounter permission errors with volumes:

```bash
# Fix ownership of volumes directory
sudo chown -R $USER:$USER volumes/
```

### Slow Performance

**Increase Docker resources** (Docker Desktop):
- Settings → Resources
- Increase CPUs to 4+
- Increase Memory to 6GB+

**Use volume mounts instead of bind mounts** (already configured in docker-compose.yml)

### Can't Connect to Supabase from App

**Verify environment variables** in the Astro container:
```bash
docker compose exec app env | grep SUPABASE
```

Should show:
```
PUBLIC_SUPABASE_URL=http://localhost:54321
PUBLIC_SUPABASE_ANON_KEY=...
```

**Check Kong gateway**:
```bash
curl http://localhost:54321/rest/v1/
```

Should return API information (not an error).

## Architecture Notes

### Service Ports

The following ports are exposed on your host machine:

- `4321` - Astro dev server
- `54321` - Kong API gateway (Supabase API endpoint)
- `54323` - Supabase Studio
- `5432` - PostgreSQL database
- `6543` - Supavisor (database pooler)

### Inter-Service Communication

Inside Docker, services communicate using service names:
- App connects to Supabase via `http://kong:8000` (internal)
- Exposed externally as `http://localhost:54321`

### Data Persistence

The following volumes persist data between restarts:

- `volumes/db/data` - PostgreSQL data
- `volumes/storage` - Uploaded files
- `db-config` - PostgreSQL configuration (named volume)

To completely reset (delete all data):
```bash
docker compose down -v
rm -rf volumes/db/data volumes/storage
docker compose up -d
```

## Production Deployment

This Docker setup is for **local development only**. Production deployment uses:

- **Frontend**: Cloudflare Workers (configured in `wrangler.toml`)
- **Backend**: Supabase Cloud (or self-hosted production instance)

See [INFRASTRUCTURE.md](./INFRASTRUCTURE.md) for production deployment details.

## Getting Help

- **Docker issues**: Check [Docker documentation](https://docs.docker.com/)
- **Supabase issues**: Check [Supabase self-hosting docs](https://supabase.com/docs/guides/self-hosting/docker)
- **Project issues**: Create an issue in the project repository

## Additional Resources

- [Supabase Self-Hosting Guide](https://supabase.com/docs/guides/self-hosting/docker)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Astro Documentation](https://docs.astro.build/)
