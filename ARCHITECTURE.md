# Market - High Level Architecture

## Overview

A trust-based, invite-only marketplace built with Astro, React, and Supabase. Users can list items to sell or post requests for items they want to buy, then communicate directly through messaging threads.

## Engineering Principles

### 1. Declarative Configuration

All infrastructure defined as code:

- **Supabase**: Database schema via SQL migrations, RLS policies in migrations
- **Cloudflare**: Workers config in `wrangler.toml`, environment variables in `.dev.vars`
- **Benefits**: Version controlled, reproducible, reviewable, no manual dashboard configuration

### 2. Local Development Parity

Full stack runs locally via `npm run` commands:

- Supabase stack (database, auth, storage, API)
- Astro dev server
- Twilio test credentials
- No cloud dependencies for development

### 3. Automated Testing

Every feature requires test coverage, verified on every PR:

- **Unit tests** (Vitest): Utilities, validation, business logic
- **Integration tests** (Playwright): Auth, item CRUD, messaging, connections
- **CI/CD**: All tests pass before merge, coverage reports
- **Priority flows**: Signup, item operations with RLS, threads, connection requests

### 4. Intuitive User Experience

Every feature should support both power users and those who rank low on the "techniness" spectrum.

- All the main features should be high intuitive, even to those who are totally new to the platform.
- Create extra features for power users, but don't overwhelm normal users with power user features.
- Prefer preserving simplicity over implementing additional complexity.

## Technology Stack

### Frontend

- **Framework**: Astro 5.x (hybrid SSR + static)
- **Interactive Components**: React 19
- **Styling**: Tailwind CSS 4.x
- **State Management**: React Context + Zustand
- **Forms**: React Hook Form + Zod validation
- **PWA**: Service workers for installable app

### Backend

- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth (email/phone OTP via Twilio)
- **Storage**: Supabase Storage (single bucket)
- **Real-time**: Supabase Realtime
- **API**: Supabase REST + PostgREST with RLS

### Deployment

- **Hosting**: Cloudflare Workers
- **SSR**: Cloudflare Workers
- **CDN**: Cloudflare CDN

## Core Architecture

### Routing Strategy

- **Static pages**: Landing, about
- **SSR pages** (authenticated): Dashboard, items, item detail, profile, vendor pages, messages, signup
- **Vendor routing**: `/{vendor_id}` primary, `/v/{vendor_id}` fallback for conflicts with built-in pages
- Astro file-based routing handles precedence naturally

### Rendering Approach

- Static pages for public content
- SSR for authenticated/dynamic content
- React islands for interactive components (forms, messaging, search/filters)
- Hybrid approach optimizes for privacy (RLS) and performance

## Database Schema

### user

- id (uuid, pk)
- display_name (text)
- about (text)
- avatar_url (text)
- vendor_id (text, unique, nullable) -- alphanumeric + underscore/dash
- created_at (timestamp)
- invited_by (uuid, fk -> user.id)

### contact_info

- id (uuid, pk)
- user_id (uuid, fk -> user.id)
- contact_type (enum: email|phone)
- value (text)
- visibility (enum: hidden|connections-only|public)
- created_at (timestamp)

### user_settings

- id (uuid, pk)
- user_id (uuid, fk -> user.id)
- setting_key (text)
- setting_value (jsonb)
- created_at (timestamp)
- updated_at (timestamp)

### category

- id (uuid, pk)
- name (text) -- new, resale, service
- description (text)
- created_at (timestamp)

### item

- id (uuid, pk)
- user_id (uuid, fk -> user.id)
- type (enum: buy|sell)
- category_id (uuid, fk -> category.id)
- title (text)
- description (text)
- price_string (text) -- price or budget
- visibility (enum: hidden|connections-only|public)
- status (enum: active|archived|deleted)
- created_at (timestamp)
- updated_at (timestamp)

### item_image

- id (uuid, pk)
- item_id (uuid, fk -> item.id)
- url (text)
- alt_text (text)
- order_index (integer)
- created_at (timestamp)

### watch

- id (uuid, pk)
- name (text)
- query_params (text)
- notify (uuid, fk -> contact_info.id, nullable)

### connection

- id (uuid, pk)
- user_a (uuid, fk -> user.id) -- requester
- user_b (uuid, fk -> user.id) -- recipient
- status (enum: pending|accepted|declined)
- created_at (timestamp)
- unique(user_a, user_b)

### thread

- id (uuid, pk)
- item_id (uuid, fk -> item.id)
- creator_id (uuid, fk -> user.id) -- thread initiator
- responder_id (uuid, fk -> user.id) -- other participant
- created_at (timestamp)
- unique(item_id, creator_id, responder_id)

### message

- id (uuid, pk)
- thread_id (uuid, fk -> thread.id)
- sender_id (uuid, fk -> user.id)
- content (text)
- read (boolean)
- created_at (timestamp)

### message_image

- id (uuid, pk)
- message_id (uuid, fk -> message.id)
- url (text)
- order_index (integer)
- created_at (timestamp)

### invite

- id (uuid, pk)
- inviter_id (uuid, fk -> user.id)
- invite_code (text, unique) -- 8 alphanumeric characters
- used_by (uuid, fk -> user.id, nullable)
- used_at (timestamp, nullable)
- revoked_at (timestamp, nullable)
- created_at (timestamp)

## Row Level Security (RLS)

### user

- Public profiles: All authenticated users
- Vendor profiles: Accessible via public routes (does not require authentication)

### contact_info

- Hidden: System only
- Connections Only: Direct connections only (status='accepted')
- Public: Anyone can view, even if not authenticated

### user_settings

- Read/Write: Owner only (user_id)

### category

- Public: All authenticated users (read-only)

### item

- Hidden: Creator only
- Connections Only: Creator + direct connections (status='accepted')
- Public: All authenticated users
- Buy items: Creator shown as "Anonymous" to non-connections

### item_image

- Follows parent item visibility rules
- Images inherit visibility from their item

### connection

- Read: Both parties (user_a or user_b)
- Write: user_a creates with status='pending', user_b updates status

### thread

- Read/write: Participants only (creator_id or responder_id)
- Thread creator identity follows item visibility rules

### message

- Read/write: Participants only (sender_id or recipient in thread)
- Message images inherit thread visibility

### message_image

- Follows parent message visibility rules
- Images inherit visibility from their message

### invite

- Read/Write: Inviter only (inviter_id)
- Read: Used by user (used_by) for validation

## Key Flows

### Invite & Onboarding

1. User clicks invite link with code
1. Server validates code (not used, not revoked)
1. Shows inviter name + auth method choice (email or phone OTP)
1. User enters email/phone, receives OTP (Supabase/Twilio)
1. Verifies OTP, creates account
1. Creates user record with invited_by
1. Creates contact_info (visibility=hidden)
1. Creates connection (user_a=inviter, user_b=invitee, status='accepted')
1. Marks invite as used
1. Mandatory 3-step wizard: account type, contact visibility, about/avatar
1. Redirects to dashboard

### Item Creation

1. User creates item (buy or sell)
1. Form: type, category, title, description, price_string, images (required for sell), visibility
1. Item created with status='active'
1. Images stored in item_image table with order_index
1. Visible per visibility rules + connection status

### Messaging

1. User sees item, clicks "Start conversation"
1. System checks for existing thread (one per user per item)
1. If exists: opens thread; if not: creates thread
1. Thread identified by item (maintains anonymity if applicable)
1. Users exchange text + images
1. Buy item creator remains "Anonymous" to non-connections even in threads
1. Thread stays active indefinitely

### Connection Requests

1. User views profile, clicks "Connect"
1. Creates connection record (user_a=requester, user_b=recipient, status='pending')
1. Recipient sees pending request (manual check, no notifications in MVP)
1. Recipient accepts/declines (updates status)
1. If accepted: unlocks contact info and items that are set as "Connections Only", prioritization, direct messaging

### Invite Generation

1. User clicks "Invite someone"
1. System checks last invite timestamp
1. If < 24 hours: shows limit message
1. If eligible: generates 8-character code
1. Creates invite record
1. User can revoke anytime (sets revoked_at)

## Site Structure

### Main Navigation

- **Vendors**: `/vendors` - a list of profiles that have `vendor_id` set
- **New Items**: `/items?type=sell&category=new`
- **Resale Items**: `/items?type=sell&category=resale`
- **Services**: `/items?type=sell&category=service`
- **Requests**: `/items?type=buy`

### Items Page

- Unified search across all items
- Filters: type, category, price range, connections
- Sort: newest, relevance
- Connection-prioritized feed (connections' items first)
- Buy items from non-connections show "Anonymous"

### Vendor Profiles

Routes: `/{vendor_id}` or `/v/{vendor_id}`

Content:

- Vendor about, avatar, contact info (per visibility)
- Main focus: all active and public sell items (all categories)
- Include option to view public archived items (by default, filter will be set to show active items only)
- No buy items shown

### User Profiles

Routes: `/profile/{user_id}`

Content:

- About, avatar, contact info (per visibility)
- Display all active and public sell AND buy items (all categories)
- Include option to view archived items (by default, filter will be set to show active items only)

## Project Structure

```
project-root/
├── wrangler.toml               # Cloudflare Workers config
├── supabase/
│   ├── config.toml            # Supabase configuration
│   ├── migrations/
│   │   ├── 001_initial_schema.sql
│   │   ├── 002_rls_policies.sql
│   │   └── 003_indexes.sql
│   └── seed.sql               # Test data
├── src/
│   ├── pages/                 # Astro routes
│   │   ├── index.astro       # Landing page
│   │   ├── about.astro       # About page
│   │   ├── dashboard.astro   # User dashboard
│   │   ├── items/
│   │   │   ├── index.astro   # Item listings
│   │   │   ├── [id].astro    # Item details
│   │   │   └── new.astro     # Create item
│   │   ├── vendors.astro     # Vendor directory
│   │   ├── profile/[id].astro # User profiles
│   │   ├── messages/
│   │   │   └── index.astro   # Message threads
│   │   ├── signup.astro      # Invite signup
│   │   ├── [vendor_id].astro # Vendor profile
│   │   └── v/[vendor_id].astro # Alt vendor route
│   ├── components/
│   │   ├── react/            # Interactive components
│   │   │   ├── ItemForm.tsx
│   │   │   ├── MessageThread.tsx
│   │   │   ├── ItemFeed.tsx
│   │   │   └── ConnectionsList.tsx
│   │   └── astro/           # Static components
│   │       ├── Header.astro
│   │       └── ItemCard.astro
│   ├── layouts/
│   │   ├── BaseLayout.astro  # Common wrapper
│   │   └── AuthLayout.astro  # Auth wrapper
│   └── lib/
│       ├── supabase.ts      # Database client
│       ├── auth.ts          # Auth utilities
│       └── utils/           # Helpers
├── tests/
│   ├── unit/               # Unit tests
│   └── e2e/               # Integration tests
└── .github/
    └── workflows/
        └── ci.yml         # CI/CD pipeline
```

## Security

### Authentication

- Email or phone OTP (passwordless via Supabase/Twilio)
- Session management via Supabase Auth
- Protected routes via Astro middleware
- Invite-only prevents open signups

### Authorization

- RLS policies enforce all access control
- Item visibility at DB level
- Contact info visibility at DB level
- Buy item creator anonymity for non-connections
- Connection status gates private content

### Data Protection

- Image uploads auto-compressed (jpg/png, 5MB max)
- Rate limiting on messages
- Spam flagging on items (manual admin review)

### Static Generation

- Landing page fully static
- Public content cached at CDN edge

### SSR Strategy

- Dynamic pages for authenticated content
- Item feeds server-rendered for RLS enforcement
- Fresh connection data on profile pages

### Image Handling

- Auto-compression on upload (balanced quality/size)
- 5 images per item/message
- Single storage bucket (simpler for MVP)

## Error Handling

- Network failures: Specific, user-friendly messages with actionable steps
- Image uploads: Background queue with progress indicators and retry logic
- Edge cases: Duplicate thread prevention, invite validation, connection deduplication

## Moderation

- Report button on items/threads
- Manual admin review in Supabase (no admin UI in MVP)
- Account deletion: Self-service or admin, anonymizes content
- Ban/delete accounts via Supabase

## MVP Scope

### Included

- Email/phone OTP authentication
- Invite-only signup (1/day, revocable)
- Mandatory onboarding wizard
- Unified items (buy/sell)
- Categories (new/resale/service)
- Visibility controls (hidden/connections-only/public)
- Messaging threads (2 users)
- Connection system (invite + manual requests)
- Vendor profiles (/{vendor_id})
- Portfolio display (fulfilled items)
- Image uploads (5 per item/message)
- Search and filters
- PWA (installable, online-only)
- Watch list (user can persist a set of search term and filters, also choose to receive weekly notification about new items)

## Future Enhancements

### Near-term (v1.0)

- Notifications system (in-app, push, email/SMS, per-type preferences)
- Content reporting/moderation
- Thread archiving (user-level, doesn't affect other participant)
- Multi-user threads (3+ participants)
- Separate storage buckets (items/messages/profiles)
- Advanced search (saved searches, price filters, location radius)
- Data export

### Medium-term (After onboarding several dozen regular users)

- Multi-user vendors
- Reputation/trust scores
- Business analytics dashboard
- Enhanced portfolio (curated showcases, project descriptions)
- Mobile app (React Native)
- Offline mode (cached browsing)

### Long-term (Only when necessary)

- Payment integration (optional escrow)
- Shipping/logistics
- Community features (forums, events)
- AI-powered matching
- Multi-language support
