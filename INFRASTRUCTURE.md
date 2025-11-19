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

TODO: add info about Supabase auth infra here
