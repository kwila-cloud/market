-- Invite system for user onboarding

create table invite (
    id uuid primary key default uuid_generate_v4(),
    inviter_id uuid not null references "user"(id) on delete cascade,
    name text not null default '',
    invite_code text not null unique,
    used_by uuid references "user"(id),
    used_at timestamptz,
    revoked_at timestamptz,
    created_at timestamptz not null default now()
);

-- Enable RLS
alter table invite enable row level security;

-- Invite policies
-- Users can view invites they created or claimed
create policy "Users can view invites"
    on invite for select
    to authenticated
    using (
        inviter_id = (select auth.uid())
        or used_by = (select auth.uid())
    );

-- Users can create invites
create policy "Users can create invites"
    on invite for insert
    to authenticated
    with check (inviter_id = (select auth.uid()));

-- Inviters can update (revoke) or users can claim unused invites
create policy "Users can update invites"
    on invite for update
    to authenticated
    using (
        inviter_id = (select auth.uid())
        or (used_by is null and revoked_at is null)
    )
    with check (
        inviter_id = (select auth.uid())
        or used_by = (select auth.uid())
    );

-- Function to check if user has created a non-revoked invite in the last 24 hours
-- Returns true if user CAN create a new invite, false if rate limited
create or replace function can_create_invite(user_id uuid)
returns boolean
language sql
security definer
stable
as $$
    select not exists (
        select 1
        from invite
        where inviter_id = user_id
            and revoked_at is null
            and created_at > now() - interval '24 hours'
    );
$$;
