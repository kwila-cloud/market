-- Category table for item classification

create table category (
    id uuid primary key default uuid_generate_v4(),
    name text not null unique,
    description text,
    created_at timestamptz not null default now()
);

-- Enable RLS
alter table category enable row level security;

-- Category policies (read-only for authenticated users)
create policy "Authenticated users can view categories"
    on category for select
    to authenticated
    using (true);
