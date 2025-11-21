-- Storage bucket and RLS policies
-- This schema defines the 'images' storage bucket and access control policies
-- for avatars, item images, and message images

-- Create the storage bucket if it doesn't exist
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'images',
  'images',
  false,
  5242880, -- 5MiB in bytes
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do nothing;

-- =============================================================================
-- AVATAR POLICIES
-- Path pattern: avatars/{user_id}/...
-- =============================================================================

-- Anyone can view avatars (needed for public vendor profiles and authenticated user browsing)
create policy "Anyone can view avatars"
on storage.objects for select
using (
  bucket_id = 'images' and
  (storage.foldername(name))[1] = 'avatars'
);

-- Users can upload their own avatar
create policy "Users can upload own avatar"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'images' and
  (storage.foldername(name))[1] = 'avatars' and
  (auth.uid())::text = (storage.foldername(name))[2]
);

-- Users can update their own avatar
create policy "Users can update own avatar"
on storage.objects for update
to authenticated
using (
  bucket_id = 'images' and
  (storage.foldername(name))[1] = 'avatars' and
  (auth.uid())::text = (storage.foldername(name))[2]
)
with check (
  bucket_id = 'images' and
  (storage.foldername(name))[1] = 'avatars' and
  (auth.uid())::text = (storage.foldername(name))[2]
);

-- Users can delete their own avatar
create policy "Users can delete own avatar"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'images' and
  (storage.foldername(name))[1] = 'avatars' and
  (auth.uid())::text = (storage.foldername(name))[2]
);

-- =============================================================================
-- ITEM IMAGE POLICIES
-- Path pattern: items/{item_id}/...
-- Visibility follows the item's visibility setting
-- =============================================================================

-- Users can view item images based on item visibility
create policy "Users can view item images"
on storage.objects for select
to authenticated
using (
  bucket_id = 'images' and
  (storage.foldername(name))[1] = 'items' and
  exists (
    select 1 from public.item
    where item.id::text = (storage.foldername(name))[2]
    and (
      -- Owner can always view
      item.user_id = auth.uid()
      -- Public items (not deleted)
      or (item.visibility = 'public' and item.status != 'deleted')
      -- Connections-only items (not deleted) for connected users
      or (
        item.visibility = 'connections-only'
        and item.status != 'deleted'
        and exists (
          select 1 from public.connection
          where connection.status = 'accepted'
          and (
            (connection.user_a = auth.uid() and connection.user_b = item.user_id)
            or (connection.user_b = auth.uid() and connection.user_a = item.user_id)
          )
        )
      )
    )
  )
);

-- Users can upload images for their own items
create policy "Users can upload item images"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'images' and
  (storage.foldername(name))[1] = 'items' and
  exists (
    select 1 from public.item
    where item.id::text = (storage.foldername(name))[2]
    and item.user_id = auth.uid()
  )
);

-- Users can update images for their own items
create policy "Users can update item images"
on storage.objects for update
to authenticated
using (
  bucket_id = 'images' and
  (storage.foldername(name))[1] = 'items' and
  exists (
    select 1 from public.item
    where item.id::text = (storage.foldername(name))[2]
    and item.user_id = auth.uid()
  )
)
with check (
  bucket_id = 'images' and
  (storage.foldername(name))[1] = 'items' and
  exists (
    select 1 from public.item
    where item.id::text = (storage.foldername(name))[2]
    and item.user_id = auth.uid()
  )
);

-- Users can delete images for their own items
create policy "Users can delete item images"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'images' and
  (storage.foldername(name))[1] = 'items' and
  exists (
    select 1 from public.item
    where item.id::text = (storage.foldername(name))[2]
    and item.user_id = auth.uid()
  )
);

-- =============================================================================
-- MESSAGE IMAGE POLICIES
-- Path pattern: messages/{message_id}/...
-- Only thread participants can view, only sender can upload/delete
-- =============================================================================

-- Thread participants can view message images
create policy "Thread participants can view message images"
on storage.objects for select
to authenticated
using (
  bucket_id = 'images' and
  (storage.foldername(name))[1] = 'messages' and
  exists (
    select 1 from public.message
    join public.thread on thread.id = message.thread_id
    where message.id::text = (storage.foldername(name))[2]
    and (
      thread.creator_id = auth.uid()
      or thread.responder_id = auth.uid()
    )
  )
);

-- Message senders can upload images (must be thread participant)
create policy "Message senders can upload images"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'images' and
  (storage.foldername(name))[1] = 'messages' and
  exists (
    select 1 from public.message
    join public.thread on thread.id = message.thread_id
    where message.id::text = (storage.foldername(name))[2]
    and message.sender_id = auth.uid()
    and (
      thread.creator_id = auth.uid()
      or thread.responder_id = auth.uid()
    )
  )
);

-- Message senders can delete their own images
create policy "Message senders can delete images"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'images' and
  (storage.foldername(name))[1] = 'messages' and
  exists (
    select 1 from public.message
    where message.id::text = (storage.foldername(name))[2]
    and message.sender_id = auth.uid()
  )
);
