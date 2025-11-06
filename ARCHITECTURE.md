# A Market - High Level Architecture

## Overview
A trust-based, invite-only marketplace built with Astro, React, and Supabase. Users can list items to sell or post requests for items they want to buy, then communicate directly through messaging threads.

## Engineering Principles

### 1. Declarative Configuration
All infrastructure defined as code:
- **Supabase**: Database schema via SQL migrations, RLS policies in migrations, storage/auth config in `supabase/config.toml`
- **Cloudflare**: Workers config in `wrangler.toml`, environment variables in `.dev.vars`
- **Benefits**: Version controlled, reproducible, reviewable, no manual dashboard configuration

### 2. Local Development Parity
Full stack runs locally via Docker Compose with single command setup:
- Supabase stack (database, auth, storage, API)
- Astro dev server
- Twilio mock/test credentials
- No cloud dependencies for development

### 3. Automated Testing
Every feature requires test coverage, verified on every PR:
- **Unit tests** (Vitest): Utilities, validation, business logic
- **Integration tests** (Playwright): Auth, item CRUD, messaging, connections, visibility rules
- **CI/CD**: All tests pass before merge, coverage reports
- **Priority flows**: Signup, item operations with RLS, threads, connection requests

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
- **Real-time**: Polling (5-10 second intervals)
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

### users
- id (uuid, pk)
- display_name (text)
- about (text)
- avatar_url (text)
- vendor_id (text, unique, nullable) -- alphanumeric + underscore/dash
- created_at (timestamp)
- invited_by (uuid, fk -> users.id)

### contact_info
- id (uuid, pk)
- user_id (uuid, fk -> users.id)
- contact_type (enum: email|phone)
- value (text)
- visibility (enum: hidden|private|public)
- is_primary (boolean) -- auth contact
- created_at (timestamp)

### connections
- id (uuid, pk)
- user_a (uuid, fk -> users.id) -- requester
- user_b (uuid, fk -> users.id) -- recipient
- status (enum: pending|accepted|declined)
- created_at (timestamp)
- unique(user_a, user_b)

### items
- id (uuid, pk)
- user_id (uuid, fk -> users.id)
- type (enum: buy|sell)
- category (enum: new|resale|service)
- title (text)
- description (text)
- price_string (text) -- budget for buy, asking price for sell
- images (text[]) -- required for sell, optional for buy
- visibility (enum: hidden|private|public)
- status (enum: active|archived|deleted)
- created_at (timestamp)
- updated_at (timestamp)

### threads
- id (uuid, pk)
- item_id (uuid, fk -> items.id)
- creator_id (uuid, fk -> users.id) -- thread initiator
- responder_id (uuid, fk -> users.id) -- other participant
- created_at (timestamp)
- unique(item_id, creator_id, responder_id)

### messages
- id (uuid, pk)
- thread_id (uuid, fk -> threads.id)
- sender_id (uuid, fk -> users.id)
- content (text)
- images (text[]) -- 0-5 images
- read (boolean)
- created_at (timestamp)

### invites
- id (uuid, pk)
- inviter_id (uuid, fk -> users.id)
- invite_code (text, unique) -- 8 alphanumeric characters
- used_by (uuid, fk -> users.id, nullable)
- used_at (timestamp, nullable)
- revoked_at (timestamp, nullable)
- created_at (timestamp)

### Indexes
- items: (status, visibility, created_at), (user_id), (type, category)
- threads: (item_id, creator_id, responder_id) unique, (item_id), (creator_id), (responder_id)
- messages: (thread_id, created_at), (sender_id)
- connections: (user_a, user_b) unique, (user_b, status)
- invites: (invite_code), (inviter_id)

## Row Level Security (RLS)

### Items
- Hidden: Creator only
- Private: Creator + direct connections (status='accepted')
- Public: All authenticated users
- Buy items: Creator shown as "Anonymous" to non-connections

### Threads & Messages
- Read/write: Participants only (creator_id or responder_id)
- Thread creator identity follows item visibility rules

### Contact Info
- Hidden: System only
- Private: Direct connections only (status='accepted')
- Public: All authenticated users

### Connections
- Read: Both parties (user_a or user_b)
- Write: user_a creates with status='pending', user_b updates status

### Users
- Public profiles: All authenticated users
- Vendor profiles: Accessible via public routes

## Key Flows

### Invite & Onboarding
1. User clicks invite link (`/signup?code=A7K9M2X4`)
1. Server validates code (not used, not revoked)
1. Shows inviter name + auth method choice (email or phone OTP)
1. User enters email/phone, receives OTP (Supabase/Twilio)
1. Verifies OTP, creates account
1. Creates user record with invited_by
1. Creates contact_info (is_primary=true, default visibility)
1. Creates connection (user_a=inviter, user_b=invitee, status='accepted')
1. Marks invite as used
1. Mandatory 4-step wizard: account type, contact visibility, about/avatar, tutorial
1. Redirects to dashboard

### Item Creation
1. User creates item (buy or sell)
1. Form: type, category, title, description, price_string, images (required for sell), visibility
1. Item created with status='active'
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
1. If accepted: unlocks private contact info, private items, prioritization, direct messaging

### Invite Generation
1. User clicks "Invite someone"
1. System checks last invite timestamp
1. If < 24 hours: shows limit message
1. If eligible: generates 8-char alphanumeric code
1. Creates invite record
1. Returns link: `/signup?code=CODE`
1. User can revoke anytime (sets revoked_at)

## Site Structure

### Main Navigation
- **Vendors**: Featured vendors + recent sell items
- **New Items**: `/items?type=sell&category=new`
- **Resale Items**: `/items?type=sell&category=resale`
- **Services**: `/items?type=sell&category=service`
- **Requests**: `/items?type=buy` (optional category filter)

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
- All active sell items
- Portfolio grid (fulfilled items with public visibility)
- No buy items shown

## Project Structure

```
project-root/
├── docker-compose.yml           # Local development services
├── wrangler.toml               # Cloudflare Workers config
├── supabase/
│   ├── config.toml            # Supabase configuration
│   ├── migrations/
│   │   ├── 001_initial_schema.sql
│   │   ├── 002_rls_policies.sql
│   │   └── 003_indexes.sql
│   └── seed.sql               # Development test data
├── src/
│   ├── pages/                 # Astro routes
│   │   ├── index.astro       # (static) Landing page
│   │   ├── about.astro       # (static) About page
│   │   ├── dashboard.astro   # (SSR, auth) User dashboard
│   │   ├── items/
│   │   │   ├── index.astro   # (SSR) Filterable item list
│   │   │   ├── [id].astro    # (SSR) Item details
│   │   │   └── new.astro     # (SSR, auth) Create item
│   │   ├── vendors.astro     # (SSR) Vendor directory
│   │   ├── profile/[id].astro # (SSR) User profiles
│   │   ├── messages/
│   │   │   └── index.astro   # (SSR, auth) Message threads
│   │   ├── signup.astro      # (SSR) Invite signup
│   │   ├── [vendor_id].astro # (SSR) Vendor profile
│   │   └── v/[vendor_id].astro # (SSR) Alt vendor route
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
│   │   └── AuthLayout.astro  # Auth-required wrapper
│   └── lib/
│       ├── supabase.ts      # Database client
│       ├── auth.ts          # Auth utilities
│       └── utils/           # Shared helpers
├── tests/
│   ├── unit/               # Vitest unit tests
│   └── e2e/               # Playwright E2E tests
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

## Performance

### Static Generation
- Landing page fully static
- Public content cached at CDN edge

### SSR Strategy
- Dynamic pages for authenticated content
- Item feeds server-rendered for RLS enforcement
- Fresh connection data on profile pages

### Image Handling
- Auto-compression on upload (balanced quality/size)
- 5+ images per item/message
- Single storage bucket (simpler for MVP)

### Message Polling
- 5-10 second intervals
- Active threads only
- Debounced search inputs

## Error Handling

- Network failures: Specific, user-friendly messages with actionable steps
- Image uploads: Background queue with progress indicators and retry logic
- Edge cases: Duplicate thread prevention, invite validation, connection deduplication

## Moderation

- Report button on items/threads
- Manual admin review in Supabase (no admin UI in MVP)
- Account deletion: Self-service or admin, anonymizes content
- Ban/delete accounts via Supabase

## Development Workflow

### Local Development (Docker Compose)
Everything runs in containers, no local npm required:

```bash
# First time setup
git clone [repo]
docker-compose up -d

# Access services
- Astro dev server: http://localhost:4321
- Supabase Studio: http://localhost:54323
- Supabase API: http://localhost:54321

# Run migrations
docker-compose exec supabase supabase migration up

# Optional: Seed data
docker-compose exec supabase psql -f /docker-entrypoint-initdb.d/seed.sql

# Run tests in container
docker-compose exec app npm run test
docker-compose exec app npm run test:e2e

# Stop services
docker-compose down
```

**docker-compose.yml includes**:
- Supabase (postgres, auth, storage, API)
- Astro dev server with Workers
- Test runner container

### Environment Variables
```
# .env (in docker-compose)
PUBLIC_SUPABASE_URL=http://localhost:54321
PUBLIC_SUPABASE_ANON_KEY=<local-key>
SUPABASE_SERVICE_ROLE_KEY=<local-key>
TWILIO_ACCOUNT_SID=<test-sid>
TWILIO_AUTH_TOKEN=<test-token>
TWILIO_PHONE_NUMBER=<test-number>
```

## CI Pipelines (GitHub Actions)

### Merge Request Checks
1. Checkout code
1. Start Docker services
1. Run migrations
1. Run unit tests
1. Run integration tests
1. Report coverage
1. Block merge if tests fail

### Push to Main

1. Run tests & build
1. Deploy to Cloudflare Workers
1. Run Supabase migrations
1. Production live

## MVP Scope

### Included
- Email/phone OTP authentication
- Invite-only signup (1/day, revocable)
- Mandatory onboarding wizard
- Unified items (buy/sell)
- Categories (new/resale/service)
- Visibility controls (hidden/private/public)
- Messaging threads (2 users)
- Connection system (invite + manual requests)
- Vendor profiles (/{vendor_id})
- Portfolio display (fulfilled items)
- Image uploads (5 per item/message)
- Search and filters
- PWA (installable, online-only)

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