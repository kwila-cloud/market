#!/bin/bash
# Migration runner for Supabase local development
# Automatically runs all migration files in order

set -e

MIGRATIONS_DIR="/docker-entrypoint-initdb.d/migrations"
POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_DB="${POSTGRES_DB:-postgres}"

echo "🔄 Running database migrations..."

# Check if migrations directory exists
if [ ! -d "$MIGRATIONS_DIR" ]; then
    echo "❌ Migrations directory not found: $MIGRATIONS_DIR"
    exit 1
fi

# Count migration files
MIGRATION_COUNT=$(find "$MIGRATIONS_DIR" -name "*.sql" -not -name "seed.sql" | wc -l)
echo "📁 Found $MIGRATION_COUNT migration file(s)"

# Run each migration file in alphabetical order
for migration_file in $(find "$MIGRATIONS_DIR" -name "*.sql" -not -name "seed.sql" | sort); do
    filename=$(basename "$migration_file")
    echo "  ▶ Running migration: $filename"

    if psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v ON_ERROR_STOP=1 -f "$migration_file"; then
        echo "  ✓ $filename completed successfully"
    else
        echo "  ❌ $filename failed"
        exit 1
    fi
done

echo "✅ All migrations completed successfully!"
