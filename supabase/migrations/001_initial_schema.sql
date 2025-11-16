-- A Market - Initial Database Schema
-- This migration creates all core tables for the marketplace

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ===========================================
-- ENUMS
-- ===========================================

CREATE TYPE contact_type_enum AS ENUM ('email', 'phone');
CREATE TYPE visibility_enum AS ENUM ('hidden', 'private', 'public');
CREATE TYPE item_type_enum AS ENUM ('buy', 'sell');
CREATE TYPE item_status_enum AS ENUM ('active', 'archived', 'deleted');
CREATE TYPE connection_status_enum AS ENUM ('pending', 'accepted', 'declined');

-- ===========================================
-- TABLES
-- ===========================================

-- Users table
CREATE TABLE "user" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    display_name TEXT NOT NULL,
    about TEXT,
    avatar_url TEXT,
    vendor_id TEXT UNIQUE,
    invited_by UUID REFERENCES "user"(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT vendor_id_format CHECK (vendor_id ~ '^[a-zA-Z0-9_-]+$')
);

-- Contact information with visibility controls
CREATE TABLE contact_info (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,
    contact_type contact_type_enum NOT NULL,
    value TEXT NOT NULL,
    visibility visibility_enum NOT NULL DEFAULT 'hidden',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- User settings (key-value pairs)
CREATE TABLE user_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,
    setting_key TEXT NOT NULL,
    setting_value JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, setting_key)
);

-- Item categories
CREATE TABLE category (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Items (buy requests and sell listings)
CREATE TABLE item (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,
    type item_type_enum NOT NULL,
    category_id UUID NOT NULL REFERENCES category(id),
    title TEXT NOT NULL,
    description TEXT,
    price_string TEXT,
    visibility visibility_enum NOT NULL DEFAULT 'public',
    status item_status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Item images
CREATE TABLE item_image (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_id UUID NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    alt_text TEXT,
    order_index INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Watch list (saved searches)
CREATE TABLE watch (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    query_params TEXT NOT NULL,
    notify UUID REFERENCES contact_info(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- User connections
CREATE TABLE connection (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_a UUID NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,
    user_b UUID NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,
    status connection_status_enum NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_a, user_b),
    CONSTRAINT no_self_connection CHECK (user_a != user_b)
);

-- Message threads
CREATE TABLE thread (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_id UUID NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    creator_id UUID NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,
    responder_id UUID NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(item_id, creator_id, responder_id),
    CONSTRAINT no_self_thread CHECK (creator_id != responder_id)
);

-- Messages
CREATE TABLE message (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    thread_id UUID NOT NULL REFERENCES thread(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Message images
CREATE TABLE message_image (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    message_id UUID NOT NULL REFERENCES message(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    order_index INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Invite codes
CREATE TABLE invite (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    inviter_id UUID NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,
    invite_code TEXT NOT NULL UNIQUE,
    used_by UUID REFERENCES "user"(id) ON DELETE SET NULL,
    used_at TIMESTAMPTZ,
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT invite_code_format CHECK (invite_code ~ '^[A-Z0-9]{8}$')
);

-- ===========================================
-- INDEXES
-- ===========================================

-- User indexes
CREATE INDEX idx_user_vendor_id ON "user"(vendor_id) WHERE vendor_id IS NOT NULL;
CREATE INDEX idx_user_invited_by ON "user"(invited_by);

-- Contact info indexes
CREATE INDEX idx_contact_info_user_id ON contact_info(user_id);
CREATE INDEX idx_contact_info_visibility ON contact_info(visibility);

-- User settings indexes
CREATE INDEX idx_user_settings_user_id ON user_settings(user_id);
CREATE INDEX idx_user_settings_key ON user_settings(setting_key);

-- Category indexes
CREATE INDEX idx_category_name ON category(name);

-- Item indexes
CREATE INDEX idx_item_user_id ON item(user_id);
CREATE INDEX idx_item_type ON item(type);
CREATE INDEX idx_item_category_id ON item(category_id);
CREATE INDEX idx_item_status ON item(status);
CREATE INDEX idx_item_visibility ON item(visibility);
CREATE INDEX idx_item_created_at ON item(created_at DESC);

-- Item image indexes
CREATE INDEX idx_item_image_item_id ON item_image(item_id);
CREATE INDEX idx_item_image_order ON item_image(item_id, order_index);

-- Watch indexes
CREATE INDEX idx_watch_user_id ON watch(user_id);

-- Connection indexes
CREATE INDEX idx_connection_user_a ON connection(user_a);
CREATE INDEX idx_connection_user_b ON connection(user_b);
CREATE INDEX idx_connection_status ON connection(status);

-- Thread indexes
CREATE INDEX idx_thread_item_id ON thread(item_id);
CREATE INDEX idx_thread_creator_id ON thread(creator_id);
CREATE INDEX idx_thread_responder_id ON thread(responder_id);

-- Message indexes
CREATE INDEX idx_message_thread_id ON message(thread_id);
CREATE INDEX idx_message_sender_id ON message(sender_id);
CREATE INDEX idx_message_created_at ON message(created_at DESC);

-- Message image indexes
CREATE INDEX idx_message_image_message_id ON message_image(message_id);

-- Invite indexes
CREATE INDEX idx_invite_inviter_id ON invite(inviter_id);
CREATE INDEX idx_invite_code ON invite(invite_code);
CREATE INDEX idx_invite_used_by ON invite(used_by);

-- ===========================================
-- FUNCTIONS
-- ===========================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ===========================================
-- TRIGGERS
-- ===========================================

-- Trigger for user_settings updated_at
CREATE TRIGGER update_user_settings_updated_at
    BEFORE UPDATE ON user_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger for item updated_at
CREATE TRIGGER update_item_updated_at
    BEFORE UPDATE ON item
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ===========================================
-- SEED DEFAULT CATEGORIES
-- ===========================================

INSERT INTO category (name, description) VALUES
    ('new', 'Brand new items and products'),
    ('resale', 'Pre-owned items for resale'),
    ('service', 'Services offered by vendors');
