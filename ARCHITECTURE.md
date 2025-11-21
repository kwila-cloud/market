# Market - High Level Architecture

## Overview

A trust-based, invite-only marketplace built with Astro, React, and Supabase. Users can list items to sell or post requests for items they want to buy, then communicate directly through messaging threads.

## Engineering Principles

### 1. Declarative Configuration

All infrastructure defined as code:

- **Supabase**: Database schema via declarative SQL files in `supabase/schemas/`, migrations auto-generated via `supabase db diff`
- **Cloudflare**: Workers config in `wrangler.toml`, environment variables in `.dev.vars`
- **Benefits**: Version controlled, reproducible, reviewable, no manual dashboard configuration, single source of truth

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
- **Storage**: Supabase Storage (images bucket with structured folders: avatars/, items/, messages/)
- **Real-time**: Supabase Realtime
- **API**: Supabase REST + PostgREST with RLS, Custom API routes with JWT authentication

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

See [here](supabase/schemas)

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
1. User enters invitee's full name
1. User confirms two requirements:
   - "I have met this person in person multiple times and know them well"
   - "I agree to allow this person to have access to my Contacts-Only information"
1. System checks rate limit via `can_create_invite()` database function (uses database time, excludes revoked invites)
1. If non-revoked invite exists within last 24 hours: shows limit message
1. If eligible: generates 8-character code (uppercase alphanumeric, excludes I/L/O/0/1)
1. Creates invite record with invitee name
1. User can copy/share code or revoke anytime (sets revoked_at)

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

(Only important directories and files are shown for brevity)

```
project-root/
├── wrangler.jsonc              # Cloudflare Workers config
├── supabase/
│   ├── config.toml            # Supabase configuration
│   ├── schemas/               # Declarative database schemas (source of truth)
│   ├── migrations/            # Auto-generated from schemas via `supabase db diff`
│   │   └── *.sql
│   ├── seeds/                 # Test data for local development
│   └── storage/               # Seed storage files
│       └── images/
│           ├── avatars/
│           ├── items/
│           └── messages/
├── src/
│   ├── pages/                 # Astro routes
│   │   ├── api/              # API endpoints (JWT-authenticated)
│   │   │   └── invites/
│   │   ├── auth/
│   │   ├── index.astro       # Landing page
│   │   ├── about.mdx         # About page (MDX)
│   │   ├── content-policy.mdx # Content policy (MDX)
│   │   ├── dashboard.astro   # User dashboard
│   │   └── invites.astro     # Invite management
│   ├── components/
│   │   ├── react/            # Interactive components
│   │   └── astro/           # Static components
│   ├── layouts/
│   │   ├── Layout.astro           # Base layout
│   │   ├── PageLayoutWithBreadcrumbs.astro
│   │   └── ProseLayout.astro      # MDX layout
│   ├── lib/
│   │   ├── auth.ts                # Auth utilities (createSupabaseWithJWT, etc.)
│   │   ├── database.types.ts      # Generated TypeScript types
│   │   ├── globals.ts
│   │   ├── storage.ts
│   │   ├── themeManager.ts
│   │   └── themes.ts
│   ├── styles/
│   │   ├── global.css
│   │   └── themes.css
│   └── middleware.ts              # Route protection
├── tests/
│   ├── unit/                      # Unit tests (Vitest)
│   ├── e2e/                       # E2E tests (Playwright)
│   └── setup.ts
└── .github/
    └── workflows/
        ├── ci.yml                  # CI/CD pipeline
        ├── code-review.yml
        ├── opencode.yml
        └── preview-deploy.yaml
```

## Security

### Authentication

- Email or phone OTP (passwordless via Supabase/Twilio)
- Session management via Supabase Auth
- Protected routes via Astro middleware
- Invite-only prevents open signups
- API routes use JWT bearer tokens with `createSupabaseWithJWT()` for RLS context

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
- Single 'images' bucket with structured folders (avatars/, items/, messages/)
- Storage RLS policies enforce visibility rules matching parent entities

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
