-- Item-related tables: item, item_image, watch

-- Main item listing table
create table item (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid not null references "user"(id) on delete cascade,
    type item_type not null,
    category_id uuid not null references category(id),
    title text not null,
    description text,
    price_string text,
    visibility visibility not null default 'public',
    status item_status not null default 'active',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- Images attached to items
create table item_image (
    id uuid primary key default uuid_generate_v4(),
    item_id uuid not null references item(id) on delete cascade,
    url text not null,
    alt_text text,
    order_index integer not null default 0,
    created_at timestamptz not null default now()
);

-- Saved searches / watch lists
create table watch (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid not null references "user"(id) on delete cascade,
    name text not null,
    query_params text not null,
    notify uuid references contact_info(id),
    created_at timestamptz not null default now()
);

-- Enable RLS on all tables
alter table item enable row level security;
alter table item_image enable row level security;
alter table watch enable row level security;

-- Item policies
-- Users can always view their own items
create policy "Users can view own items"
    on item for select
    to authenticated
    using (user_id = auth.uid());

-- Users can view public items
create policy "Users can view public items"
    on item for select
    to authenticated
    using (visibility = 'public' and status != 'deleted');

-- Users can view connections-only items from connections
create policy "Users can view connections-only items from connections"
    on item for select
    to authenticated
    using (
        visibility = 'connections-only'
        and status != 'deleted'
        and exists (
            select 1 from connection
            where status = 'accepted'
            and (
                (user_a = auth.uid() and user_b = item.user_id)
                or (user_b = auth.uid() and user_a = item.user_id)
            )
        )
    );

-- Users can create items
create policy "Users can create items"
    on item for insert
    to authenticated
    with check (user_id = auth.uid());

-- Users can update their own items
create policy "Users can update own items"
    on item for update
    to authenticated
    using (user_id = auth.uid())
    with check (user_id = auth.uid());

-- Users can delete their own items
create policy "Users can delete own items"
    on item for delete
    to authenticated
    using (user_id = auth.uid());

-- Item image policies (inherit from parent item)
-- Users can view images for items they can see
create policy "Users can view own item images"
    on item_image for select
    to authenticated
    using (
        exists (
            select 1 from item
            where item.id = item_image.item_id
            and item.user_id = auth.uid()
        )
    );

create policy "Users can view public item images"
    on item_image for select
    to authenticated
    using (
        exists (
            select 1 from item
            where item.id = item_image.item_id
            and item.visibility = 'public'
            and item.status != 'deleted'
        )
    );

create policy "Users can view connections-only item images from connections"
    on item_image for select
    to authenticated
    using (
        exists (
            select 1 from item
            where item.id = item_image.item_id
            and item.visibility = 'connections-only'
            and item.status != 'deleted'
            and exists (
                select 1 from connection
                where status = 'accepted'
                and (
                    (user_a = auth.uid() and user_b = item.user_id)
                    or (user_b = auth.uid() and user_a = item.user_id)
                )
            )
        )
    );

-- Users can manage images for their own items
create policy "Users can insert own item images"
    on item_image for insert
    to authenticated
    with check (
        exists (
            select 1 from item
            where item.id = item_image.item_id
            and item.user_id = auth.uid()
        )
    );

create policy "Users can update own item images"
    on item_image for update
    to authenticated
    using (
        exists (
            select 1 from item
            where item.id = item_image.item_id
            and item.user_id = auth.uid()
        )
    )
    with check (
        exists (
            select 1 from item
            where item.id = item_image.item_id
            and item.user_id = auth.uid()
        )
    );

create policy "Users can delete own item images"
    on item_image for delete
    to authenticated
    using (
        exists (
            select 1 from item
            where item.id = item_image.item_id
            and item.user_id = auth.uid()
        )
    );

-- Watch policies (owner only)
create policy "Users can view own watches"
    on watch for select
    to authenticated
    using (user_id = auth.uid());

create policy "Users can create watches"
    on watch for insert
    to authenticated
    with check (user_id = auth.uid());

create policy "Users can update own watches"
    on watch for update
    to authenticated
    using (user_id = auth.uid())
    with check (user_id = auth.uid());

create policy "Users can delete own watches"
    on watch for delete
    to authenticated
    using (user_id = auth.uid());
