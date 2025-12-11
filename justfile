# Market development recipes

# Start frontend on localhost only (default port 4321)
start-frontend-local:
    npm run start:frontend

# Start frontend on all network interfaces (0.0.0.0:4321) for LAN access
start-frontend-lan:
    npm run start:frontend -- --host 0.0.0.0

# Start local backend (Supabase)
start-backend:
    npm run start:backend

# Stop local backend
stop-backend:
    npm run stop:backend
