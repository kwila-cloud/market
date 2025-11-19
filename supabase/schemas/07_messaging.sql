-- Messaging tables: thread, message, message_image

-- Conversation threads tied to items
create table thread (
    id uuid primary key default uuid_generate_v4(),
    item_id uuid not null references item(id) on delete cascade,
    creator_id uuid not null references "user"(id) on delete cascade,
    responder_id uuid not null references "user"(id) on delete cascade,
    created_at timestamptz not null default now(),
    unique(item_id, creator_id, responder_id),
    check (creator_id != responder_id)
);

-- Individual messages within threads
create table message (
    id uuid primary key default uuid_generate_v4(),
    thread_id uuid not null references thread(id) on delete cascade,
    sender_id uuid not null references "user"(id) on delete cascade,
    content text not null,
    read boolean not null default false,
    created_at timestamptz not null default now()
);

-- Images attached to messages
create table message_image (
    id uuid primary key default uuid_generate_v4(),
    message_id uuid not null references message(id) on delete cascade,
    url text not null,
    order_index integer not null default 0,
    created_at timestamptz not null default now()
);

-- Enable RLS on all tables
alter table thread enable row level security;
alter table message enable row level security;
alter table message_image enable row level security;

-- Thread policies (participants only)
create policy "Participants can view threads"
    on thread for select
    to authenticated
    using (creator_id = (select auth.uid()) or responder_id = (select auth.uid()));

create policy "Users can create threads"
    on thread for insert
    to authenticated
    with check (creator_id = (select auth.uid()));

create policy "Participants can delete threads"
    on thread for delete
    to authenticated
    using (creator_id = (select auth.uid()) or responder_id = (select auth.uid()));

-- Message policies (thread participants only)
create policy "Participants can view messages"
    on message for select
    to authenticated
    using (
        exists (
            select 1 from thread
            where thread.id = message.thread_id
            and (thread.creator_id = (select auth.uid()) or thread.responder_id = (select auth.uid()))
        )
    );

create policy "Participants can send messages"
    on message for insert
    to authenticated
    with check (
        sender_id = (select auth.uid())
        and exists (
            select 1 from thread
            where thread.id = message.thread_id
            and (thread.creator_id = (select auth.uid()) or thread.responder_id = (select auth.uid()))
        )
    );

-- Recipients can mark messages as read
create policy "Recipients can update message read status"
    on message for update
    to authenticated
    using (
        sender_id != (select auth.uid())
        and exists (
            select 1 from thread
            where thread.id = message.thread_id
            and (thread.creator_id = (select auth.uid()) or thread.responder_id = (select auth.uid()))
        )
    )
    with check (
        sender_id != (select auth.uid())
        and exists (
            select 1 from thread
            where thread.id = message.thread_id
            and (thread.creator_id = (select auth.uid()) or thread.responder_id = (select auth.uid()))
        )
    );

-- Message image policies (inherit from parent message)
create policy "Participants can view message images"
    on message_image for select
    to authenticated
    using (
        exists (
            select 1 from message
            join thread on thread.id = message.thread_id
            where message.id = message_image.message_id
            and (thread.creator_id = (select auth.uid()) or thread.responder_id = (select auth.uid()))
        )
    );

create policy "Participants can insert message images"
    on message_image for insert
    to authenticated
    with check (
        exists (
            select 1 from message
            join thread on thread.id = message.thread_id
            where message.id = message_image.message_id
            and message.sender_id = (select auth.uid())
            and (thread.creator_id = (select auth.uid()) or thread.responder_id = (select auth.uid()))
        )
    );

create policy "Senders can delete own message images"
    on message_image for delete
    to authenticated
    using (
        exists (
            select 1 from message
            where message.id = message_image.message_id
            and message.sender_id = (select auth.uid())
        )
    );
