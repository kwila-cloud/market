-- Setup Supabase database users, roles, and schemas
-- This must run before other migrations

-- Create roles
CREATE ROLE IF NOT EXISTS anon NOLOGIN;
CREATE ROLE IF NOT EXISTS authenticated NOLOGIN;
CREATE ROLE IF NOT EXISTS service_role NOLOGIN;

-- Create users with password from environment
-- Note: We use a placeholder password here, in production this would be from secrets
CREATE USER IF NOT EXISTS supabase_auth_admin WITH PASSWORD 'your-super-secret-and-long-postgres-password' CREATEDB CREATEROLE;
CREATE USER IF NOT EXISTS supabase_storage_admin WITH PASSWORD 'your-super-secret-and-long-postgres-password' CREATEDB CREATEROLE;
CREATE USER IF NOT EXISTS supabase_admin WITH PASSWORD 'your-super-secret-and-long-postgres-password' SUPERUSER CREATEDB CREATEROLE REPLICATION;
CREATE USER IF NOT EXISTS authenticator WITH PASSWORD 'your-super-secret-and-long-postgres-password' NOINHERIT;
CREATE USER IF NOT EXISTS supabase WITH PASSWORD 'your-super-secret-and-long-postgres-password';

-- Grant roles to authenticator
GRANT anon, authenticated, service_role TO authenticator;

-- Create schemas
CREATE SCHEMA IF NOT EXISTS auth AUTHORIZATION supabase_admin;
CREATE SCHEMA IF NOT EXISTS storage AUTHORIZATION supabase_admin;
CREATE SCHEMA IF NOT EXISTS extensions AUTHORIZATION supabase_admin;
CREATE SCHEMA IF NOT EXISTS _analytics AUTHORIZATION supabase_admin;
CREATE SCHEMA IF NOT EXISTS _realtime AUTHORIZATION supabase_admin;

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE postgres TO supabase_admin;
GRANT ALL PRIVILEGES ON SCHEMA public TO supabase_admin;
GRANT ALL PRIVILEGES ON SCHEMA auth TO supabase_auth_admin;
GRANT ALL PRIVILEGES ON SCHEMA storage TO supabase_storage_admin;

-- Grant usage on schemas
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT USAGE ON SCHEMA auth TO anon, authenticated, service_role;
GRANT USAGE ON SCHEMA storage TO anon, authenticated, service_role;

-- Allow public schema modifications
GRANT CREATE ON SCHEMA public TO postgres, supabase_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO postgres, supabase_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres, supabase_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON ROUTINES TO postgres, supabase_admin;

-- Set search path for auth user
ALTER ROLE supabase_auth_admin SET search_path TO auth;
