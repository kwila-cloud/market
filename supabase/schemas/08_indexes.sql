-- Performance indexes for common query patterns

-- User indexes
create index idx_user_vendor_id on "user"(vendor_id) where vendor_id is not null;
create index idx_user_invited_by on "user"(invited_by);

-- Contact info indexes
create index idx_contact_info_user_id on contact_info(user_id);
create index idx_contact_info_visibility on contact_info(visibility);

-- User settings indexes
create index idx_user_settings_user_id on user_settings(user_id);

-- Item indexes (critical for feed performance)
create index idx_item_user_id on item(user_id);
create index idx_item_category_id on item(category_id);
create index idx_item_status on item(status);
create index idx_item_visibility on item(visibility);
create index idx_item_type on item(type);
create index idx_item_created_at on item(created_at desc);
-- Composite index for common feed queries
create index idx_item_feed on item(visibility, status, type, created_at desc);

-- Item image indexes
create index idx_item_image_item_id on item_image(item_id);
create index idx_item_image_order on item_image(item_id, order_index);

-- Watch indexes
create index idx_watch_user_id on watch(user_id);

-- Connection indexes (for checking connection status)
create index idx_connection_user_a on connection(user_a);
create index idx_connection_user_b on connection(user_b);
create index idx_connection_status on connection(status);
-- Composite for finding accepted connections
create index idx_connection_accepted on connection(user_a, user_b) where status = 'accepted';

-- Thread indexes
create index idx_thread_item_id on thread(item_id);
create index idx_thread_creator_id on thread(creator_id);
create index idx_thread_responder_id on thread(responder_id);

-- Message indexes
create index idx_message_thread_id on message(thread_id);
create index idx_message_sender_id on message(sender_id);
create index idx_message_created_at on message(created_at desc);
create index idx_message_unread on message(thread_id, read) where read = false;

-- Message image indexes
create index idx_message_image_message_id on message_image(message_id);

-- Invite indexes
create index idx_invite_inviter_id on invite(inviter_id);
create index idx_invite_code on invite(invite_code);
create index idx_invite_available on invite(invite_code) where used_by is null and revoked_at is null;
