-- User-related tables: user, contact_info, user_settings

-- Main user profile table
create table "user" (
    id uuid primary key default uuid_generate_v4(),
    display_name text not null,
    about text,
    avatar_url text,
    vendor_id text unique,
    created_at timestamptz not null default now(),
    invited_by uuid references "user"(id)
);

-- Contact information for users (email/phone)
create table contact_info (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid not null references "user"(id) on delete cascade,
    contact_type contact_type not null,
    value text not null,
    visibility visibility not null default 'hidden',
    created_at timestamptz not null default now()
);

-- User settings (key-value store)
create table user_settings (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid not null references "user"(id) on delete cascade,
    setting_key text not null,
    setting_value jsonb not null default '{}',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique(user_id, setting_key)
);

-- Enable RLS on all tables
alter table "user" enable row level security;
alter table contact_info enable row level security;
alter table user_settings enable row level security;

-- User table policies
-- All authenticated users can view user profiles
create policy "Users can view all profiles"
    on "user" for select
    to authenticated
    using (true);

-- Vendor profiles are publicly accessible (no auth required)
create policy "Public can view vendor profiles"
    on "user" for select
    to anon
    using (vendor_id is not null);

-- Users can update their own profile
create policy "Users can update own profile"
    on "user" for update
    to authenticated
    using (id = (select auth.uid()))
    with check (id = (select auth.uid()));

-- Users can insert their own profile (during signup)
create policy "Users can insert own profile"
    on "user" for insert
    to authenticated
    with check (id = (select auth.uid()));

-- Contact info policies
-- Anonymous users can view public contact info
create policy "Anyone can view public contact info"
    on contact_info for select
    to anon
    using (visibility = 'public');

-- Authenticated user SELECT policy is in 08_cross_table_policies.sql

-- Users can manage their own contact info
create policy "Users can insert own contact info"
    on contact_info for insert
    to authenticated
    with check (user_id = (select auth.uid()));

create policy "Users can update own contact info"
    on contact_info for update
    to authenticated
    using (user_id = (select auth.uid()))
    with check (user_id = (select auth.uid()));

create policy "Users can delete own contact info"
    on contact_info for delete
    to authenticated
    using (user_id = (select auth.uid()));

-- User settings policies (owner only)
create policy "Users can view own settings"
    on user_settings for select
    to authenticated
    using (user_id = (select auth.uid()));

create policy "Users can insert own settings"
    on user_settings for insert
    to authenticated
    with check (user_id = (select auth.uid()));

create policy "Users can update own settings"
    on user_settings for update
    to authenticated
    using (user_id = (select auth.uid()))
    with check (user_id = (select auth.uid()));

create policy "Users can delete own settings"
    on user_settings for delete
    to authenticated
    using (user_id = (select auth.uid()));
