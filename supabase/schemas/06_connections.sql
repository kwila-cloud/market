-- Connection table for user relationships

create table connection (
    id uuid primary key default uuid_generate_v4(),
    user_a uuid not null references "user"(id) on delete cascade,
    user_b uuid not null references "user"(id) on delete cascade,
    status connection_status not null default 'pending',
    created_at timestamptz not null default now(),
    unique(user_a, user_b),
    check (user_a != user_b)
);

-- Enable RLS
alter table connection enable row level security;

-- Connection policies
-- Both parties can view the connection
create policy "Users can view own connections"
    on connection for select
    to authenticated
    using (user_a = (select auth.uid()) or user_b = (select auth.uid()));

-- Requester (user_a) can create connection requests
create policy "Users can create connection requests"
    on connection for insert
    to authenticated
    with check (
        user_a = (select auth.uid())
        and status = 'pending'
    );

-- Recipient (user_b) can update status (accept/decline)
create policy "Recipients can update connection status"
    on connection for update
    to authenticated
    using (user_b = (select auth.uid()))
    with check (user_b = (select auth.uid()));

-- Either party can delete the connection
create policy "Users can delete own connections"
    on connection for delete
    to authenticated
    using (user_a = (select auth.uid()) or user_b = (select auth.uid()));
