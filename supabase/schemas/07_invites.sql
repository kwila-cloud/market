-- Invite system for user onboarding

create table invite (
    id uuid primary key default uuid_generate_v4(),
    inviter_id uuid not null references "user"(id) on delete cascade,
    invite_code text not null unique,
    used_by uuid references "user"(id),
    used_at timestamptz,
    revoked_at timestamptz,
    created_at timestamptz not null default now()
);

-- Enable RLS
alter table invite enable row level security;

-- Invite policies
-- Inviters can view their own invites
create policy "Inviters can view own invites"
    on invite for select
    to authenticated
    using (inviter_id = auth.uid());

-- Users can view invites they claimed (to see who invited them)
create policy "Users can view invites they claimed"
    on invite for select
    to authenticated
    using (used_by = auth.uid());

-- Users can create invites
create policy "Users can create invites"
    on invite for insert
    to authenticated
    with check (inviter_id = auth.uid());

-- Inviters can update their invites (revoke)
create policy "Inviters can update own invites"
    on invite for update
    to authenticated
    using (inviter_id = auth.uid())
    with check (inviter_id = auth.uid());

-- Allows authenticated users to claim an unused invite during signup
-- They can only set used_by to their own user ID
create policy "Users can claim unused invites"
    on invite for update
    to authenticated
    using (
        used_by is null
        and revoked_at is null
    )
    with check (used_by = auth.uid());
