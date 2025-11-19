-- Enum types used throughout the application
-- These must be created before tables that reference them

-- Contact type for contact_info table
create type contact_type as enum ('email', 'phone');

-- Visibility levels for items and contact info
create type visibility as enum ('hidden', 'connections-only', 'public');

-- Item listing type
create type item_type as enum ('buy', 'sell');

-- Item status
create type item_status as enum ('active', 'archived', 'deleted');

-- Connection request status
create type connection_status as enum ('pending', 'accepted', 'declined');
