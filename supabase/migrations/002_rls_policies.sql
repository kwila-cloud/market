-- A Market - Row Level Security Policies
-- This migration enables RLS and creates all access control policies

-- ===========================================
-- ENABLE ROW LEVEL SECURITY
-- ===========================================

ALTER TABLE "user" ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_info ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE category ENABLE ROW LEVEL SECURITY;
ALTER TABLE item ENABLE ROW LEVEL SECURITY;
ALTER TABLE item_image ENABLE ROW LEVEL SECURITY;
ALTER TABLE watch ENABLE ROW LEVEL SECURITY;
ALTER TABLE connection ENABLE ROW LEVEL SECURITY;
ALTER TABLE thread ENABLE ROW LEVEL SECURITY;
ALTER TABLE message ENABLE ROW LEVEL SECURITY;
ALTER TABLE message_image ENABLE ROW LEVEL SECURITY;
ALTER TABLE invite ENABLE ROW LEVEL SECURITY;

-- ===========================================
-- HELPER FUNCTIONS FOR RLS
-- ===========================================

-- Check if two users are connected
CREATE OR REPLACE FUNCTION are_users_connected(user_a_id UUID, user_b_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM connection
        WHERE status = 'accepted'
        AND (
            (user_a = user_a_id AND user_b = user_b_id)
            OR (user_a = user_b_id AND user_b = user_a_id)
        )
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user is participant in a thread
CREATE OR REPLACE FUNCTION is_thread_participant(user_id UUID, thread_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM thread
        WHERE id = thread_id
        AND (creator_id = user_id OR responder_id = user_id)
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===========================================
-- USER POLICIES
-- ===========================================

-- Anyone (including unauthenticated) can view user profiles
CREATE POLICY "User profiles are viewable by everyone"
    ON "user" FOR SELECT
    USING (TRUE);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
    ON "user" FOR UPDATE
    USING (auth.uid() = id);

-- New users can insert their profile (during signup)
CREATE POLICY "Users can insert own profile"
    ON "user" FOR INSERT
    WITH CHECK (auth.uid() = id);

-- ===========================================
-- CONTACT_INFO POLICIES
-- ===========================================

-- Public contact info is viewable by everyone (including unauthenticated)
CREATE POLICY "Public contact info viewable by all"
    ON contact_info FOR SELECT
    USING (visibility = 'public');

-- Private contact info viewable by connections
CREATE POLICY "Private contact info viewable by connections"
    ON contact_info FOR SELECT
    USING (
        visibility = 'private'
        AND (
            auth.uid() = user_id
            OR are_users_connected(auth.uid(), user_id)
        )
    );

-- Hidden contact info only viewable by owner
CREATE POLICY "Hidden contact info viewable by owner"
    ON contact_info FOR SELECT
    USING (visibility = 'hidden' AND auth.uid() = user_id);

-- Users can manage their own contact info
CREATE POLICY "Users can manage own contact info"
    ON contact_info FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- ===========================================
-- USER_SETTINGS POLICIES
-- ===========================================

-- Users can only access their own settings
CREATE POLICY "Users can view own settings"
    ON user_settings FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own settings"
    ON user_settings FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own settings"
    ON user_settings FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own settings"
    ON user_settings FOR DELETE
    USING (auth.uid() = user_id);

-- ===========================================
-- CATEGORY POLICIES
-- ===========================================

-- Categories are read-only for all authenticated users
CREATE POLICY "Categories viewable by authenticated users"
    ON category FOR SELECT
    USING (auth.role() = 'authenticated');

-- ===========================================
-- ITEM POLICIES
-- ===========================================

-- Public items viewable by all authenticated users
CREATE POLICY "Public items viewable by authenticated"
    ON item FOR SELECT
    USING (
        status != 'deleted'
        AND visibility = 'public'
        AND auth.role() = 'authenticated'
    );

-- Private items viewable by creator and connections
CREATE POLICY "Private items viewable by connections"
    ON item FOR SELECT
    USING (
        status != 'deleted'
        AND visibility = 'private'
        AND (
            auth.uid() = user_id
            OR are_users_connected(auth.uid(), user_id)
        )
    );

-- Hidden items only viewable by creator
CREATE POLICY "Hidden items viewable by creator"
    ON item FOR SELECT
    USING (
        visibility = 'hidden'
        AND auth.uid() = user_id
    );

-- Users can create their own items
CREATE POLICY "Users can create own items"
    ON item FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can update their own items
CREATE POLICY "Users can update own items"
    ON item FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Users can delete their own items
CREATE POLICY "Users can delete own items"
    ON item FOR DELETE
    USING (auth.uid() = user_id);

-- ===========================================
-- ITEM_IMAGE POLICIES
-- ===========================================

-- Item images inherit visibility from parent item
CREATE POLICY "Item images viewable based on item visibility"
    ON item_image FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM item
            WHERE item.id = item_image.item_id
            AND (
                -- Public items
                (item.visibility = 'public' AND item.status != 'deleted' AND auth.role() = 'authenticated')
                -- Private items (creator or connection)
                OR (item.visibility = 'private' AND item.status != 'deleted' AND (auth.uid() = item.user_id OR are_users_connected(auth.uid(), item.user_id)))
                -- Hidden items (creator only)
                OR (item.visibility = 'hidden' AND auth.uid() = item.user_id)
            )
        )
    );

-- Users can manage images for their own items
CREATE POLICY "Users can manage own item images"
    ON item_image FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM item
            WHERE item.id = item_image.item_id
            AND auth.uid() = item.user_id
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM item
            WHERE item.id = item_image.item_id
            AND auth.uid() = item.user_id
        )
    );

-- ===========================================
-- WATCH POLICIES
-- ===========================================

-- Users can only access their own watches
CREATE POLICY "Users can view own watches"
    ON watch FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create own watches"
    ON watch FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own watches"
    ON watch FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own watches"
    ON watch FOR DELETE
    USING (auth.uid() = user_id);

-- ===========================================
-- CONNECTION POLICIES
-- ===========================================

-- Users can view connections they're part of
CREATE POLICY "Users can view own connections"
    ON connection FOR SELECT
    USING (auth.uid() = user_a OR auth.uid() = user_b);

-- Users can create connection requests (as user_a)
CREATE POLICY "Users can create connection requests"
    ON connection FOR INSERT
    WITH CHECK (auth.uid() = user_a AND status = 'pending');

-- Users can update connection status if they're user_b (recipient)
CREATE POLICY "Recipients can update connection status"
    ON connection FOR UPDATE
    USING (auth.uid() = user_b)
    WITH CHECK (auth.uid() = user_b);

-- Users can delete connections they're part of
CREATE POLICY "Users can delete own connections"
    ON connection FOR DELETE
    USING (auth.uid() = user_a OR auth.uid() = user_b);

-- ===========================================
-- THREAD POLICIES
-- ===========================================

-- Thread participants can view threads
CREATE POLICY "Participants can view threads"
    ON thread FOR SELECT
    USING (auth.uid() = creator_id OR auth.uid() = responder_id);

-- Users can create threads
CREATE POLICY "Users can create threads"
    ON thread FOR INSERT
    WITH CHECK (auth.uid() = creator_id);

-- Participants can delete threads
CREATE POLICY "Participants can delete threads"
    ON thread FOR DELETE
    USING (auth.uid() = creator_id OR auth.uid() = responder_id);

-- ===========================================
-- MESSAGE POLICIES
-- ===========================================

-- Thread participants can view messages
CREATE POLICY "Participants can view messages"
    ON message FOR SELECT
    USING (is_thread_participant(auth.uid(), thread_id));

-- Thread participants can send messages
CREATE POLICY "Participants can send messages"
    ON message FOR INSERT
    WITH CHECK (
        auth.uid() = sender_id
        AND is_thread_participant(auth.uid(), thread_id)
    );

-- Senders can update their own messages (for read receipts)
CREATE POLICY "Users can update message read status"
    ON message FOR UPDATE
    USING (is_thread_participant(auth.uid(), thread_id))
    WITH CHECK (is_thread_participant(auth.uid(), thread_id));

-- Senders can delete their own messages
CREATE POLICY "Senders can delete own messages"
    ON message FOR DELETE
    USING (auth.uid() = sender_id);

-- ===========================================
-- MESSAGE_IMAGE POLICIES
-- ===========================================

-- Thread participants can view message images
CREATE POLICY "Participants can view message images"
    ON message_image FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM message
            WHERE message.id = message_image.message_id
            AND is_thread_participant(auth.uid(), message.thread_id)
        )
    );

-- Message senders can manage images
CREATE POLICY "Senders can manage message images"
    ON message_image FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM message
            WHERE message.id = message_image.message_id
            AND auth.uid() = message.sender_id
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM message
            WHERE message.id = message_image.message_id
            AND auth.uid() = message.sender_id
        )
    );

-- ===========================================
-- INVITE POLICIES
-- ===========================================

-- Inviters can view their own invites
CREATE POLICY "Inviters can view own invites"
    ON invite FOR SELECT
    USING (auth.uid() = inviter_id);

-- Users can view invites used by them (for validation)
CREATE POLICY "Users can view invites used by them"
    ON invite FOR SELECT
    USING (auth.uid() = used_by);

-- Anyone can view valid invite codes (for signup validation)
-- This allows unauthenticated users to validate invite codes during signup
CREATE POLICY "Anyone can view invite codes for validation"
    ON invite FOR SELECT
    USING (used_by IS NULL AND revoked_at IS NULL);

-- Users can create invites
CREATE POLICY "Users can create own invites"
    ON invite FOR INSERT
    WITH CHECK (auth.uid() = inviter_id);

-- Inviters can update their own invites (revoke)
CREATE POLICY "Inviters can update own invites"
    ON invite FOR UPDATE
    USING (auth.uid() = inviter_id)
    WITH CHECK (auth.uid() = inviter_id);

-- System can update invites when they're used (via service role)
-- This is handled via service_role_key in application code
