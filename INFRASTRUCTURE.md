# Intrastructure

## Hosting

Cloudflare Workers for frontend SSR hosting.

Deployments were set up in the Cloudflare dashboard with the GitHub integration. Production deployments run on `main` branch (automatically triggered in Cloudflare). Preview deployments run on pull requests triggered by GitHub Action that gets the appropriate environment variables for accessing the Supabase preview branch.

## Database

Supabase for database hosting.

Preview branches are set up with the GitHub integration, using the following settings:

- Supabase directory: .
- Deploy to production: enabled
- Production branch name: main
- Automatic branching: enabled
- Branch limit: 2
- Supabase changes only: disabled

The [preview deploy](.github/workflows/preview-deploy.yaml) workflow triggers Cloudflare preview deployments based on preview branches in Supabase.

## Storage

Supabase Storage for file uploads (avatars, item images, message images).

Single `images` bucket with 5MiB file size limit. Allowed types: jpeg, png, webp.

Folder structure: `avatars/{user_id}/`, `items/{item_id}/`, `messages/{message_id}/`

RLS policies mirror database table policies - avatars are public, item/message images follow their respective visibility rules.

Storage utilities available in `src/lib/storage.ts`.

## Authentication

Supabase Auth with email OTP (one-time password) verification.

### Configuration

- **Auth method**: Email OTP (6-digit codes)
- **OTP expiry**: 3600 seconds (1 hour)
- **User signups**: Disabled for direct signup (invite-only)
- **Email confirmation**: Disabled (users verified through OTP)

### Flow

1. User enters email on `/auth/login`
2. Supabase sends 6-digit OTP to email
3. User enters code on `/auth/verify`
4. Session cookie set on successful verification
5. User redirected to `/dashboard`

### Local Development

Emails are caught by **Inbucket** (port 54324) during local development. Visit `http://localhost:54324` to view sent emails and OTP codes.

### Route Protection

Middleware (`src/middleware.ts`) protects all routes by default. Public routes are defined in `src/lib/auth.ts`:

- **Public routes**: `/`, `/about`, `/content-policy`, `/auth/login`, `/auth/verify`
- **Auth routes**: `/auth/login`, `/auth/verify` (redirects to `/dashboard` if authenticated)
- **All other routes**: Require authentication (redirects to `/auth/login` if unauthenticated)

### Session Management

- Server-side: `createSupabaseServerClient()` with cookie handling
- Client-side: `createSupabaseBrowserClient()` for browser operations
- Utilities available in `src/lib/auth.ts`

### Production Setup

For production, configure custom SMTP in Supabase dashboard:

- Project Settings → Authentication → SMTP Settings
- Recommended providers: SendGrid, Postmark, AWS SES
