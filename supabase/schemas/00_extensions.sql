-- Extensions required for the application
-- This file runs first to ensure extensions are available for subsequent schema files

-- UUID generation for primary keys
create extension if not exists "uuid-ossp" with schema extensions;

-- Cryptographic functions (used by Supabase Auth)
create extension if not exists "pgcrypto" with schema extensions;
