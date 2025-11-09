# Cloudflare Workers Deployment Guide

## Manual Deployment from CLI

### Prerequisites
1. Install Wrangler CLI: `npm install -g wrangler`
2. Login to Cloudflare: `wrangler login`
3. Get your Account ID from Cloudflare Dashboard
4. Create an API token with Workers write permissions

### Environment Variables Required
```bash
# Set your environment variables
export CF_API_TOKEN="your-api-token-here"
export CF_ACCOUNT_ID="your-account-id-here"
```

### Manual Deployment Steps

1. **Build the project:**
   ```bash
   npm run build
   ```

2. **Deploy to Cloudflare Workers:**
   ```bash
   wrangler deploy --name market
   ```

3. **Configure custom domain (market.kwila.cloud):**
   - In Cloudflare Dashboard → Workers & Pages → market
   - Add route: `market.kwila.cloud/*`
   - Or use Wrangler: `wrangler route add market.kwila.cloud/*`

### GitHub Action Setup

The repository is configured with automatic deployment when code is merged to `main`. You'll need to set these GitHub secrets:

1. **CF_API_TOKEN**: Your Cloudflare API token
2. **CF_ACCOUNT_ID**: Your Cloudflare account ID

The action will automatically:
- Install dependencies
- Build the Astro project
- Deploy to Cloudflare Workers
- Test the deployment

### Troubleshooting

**Common issues:**
- Make sure Wrangler is logged in locally
- Verify API token has correct permissions
- Check that the build completes successfully
- Ensure environment variables are set correctly

**Test deployment locally:**
```bash
wrangler dev
```