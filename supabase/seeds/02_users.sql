-- Seed data for users
-- Test users for local development and preview environments

-- User 1: Alice (the initial user, vendor)
insert into "user" (id, display_name, about, vendor_id, created_at) values
    ('22222222-2222-2222-2222-222222222201', 'Alice Johnson', 'Local artisan specializing in handmade pottery and ceramics. Based in Portland.', 'alice-pottery', '2025-10-20 10:00:00+00')
on conflict (id) do nothing;

-- User 2: Bob (invited by Alice, vendor)
insert into "user" (id, display_name, about, vendor_id, invited_by, created_at) values
    ('22222222-2222-2222-2222-222222222202', 'Bob Smith', 'Freelance software developer and 3D printing enthusiast.', 'bob-tech', '22222222-2222-2222-2222-222222222201', '2025-10-25 14:30:00+00')
on conflict (id) do nothing;

-- User 3: Carol (invited by Alice, not a vendor)
insert into "user" (id, display_name, about, invited_by, created_at) values
    ('22222222-2222-2222-2222-222222222203', 'Carol Davis', 'Looking for quality used items and local services.', '22222222-2222-2222-2222-222222222201', '2025-10-30 09:15:00+00')
on conflict (id) do nothing;

-- User 4: David (invited by Bob, vendor)
insert into "user" (id, display_name, about, vendor_id, invited_by, created_at) values
    ('22222222-2222-2222-2222-222222222204', 'David Lee', 'Professional handyman offering home repair and maintenance services.', 'david-repairs', '22222222-2222-2222-2222-222222222202', '2025-11-04 11:00:00+00')
on conflict (id) do nothing;

-- User 5: Eve (invited by Carol, not a vendor)
insert into "user" (id, display_name, about, invited_by, created_at) values
    ('22222222-2222-2222-2222-222222222205', 'Eve Martinez', 'Small business owner interested in local networking.', '22222222-2222-2222-2222-222222222203', '2025-11-09 16:45:00+00')
on conflict (id) do nothing;

-- Contact info for users
insert into contact_info (id, user_id, contact_type, value, visibility) values
    -- Alice: public email, connections-only phone
    ('33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', 'email', 'alice@example.com', 'public'),
    ('33333333-3333-3333-3333-333333333302', '22222222-2222-2222-2222-222222222201', 'phone', '555-0101', 'connections-only'),
    -- Bob: connections-only email
    ('33333333-3333-3333-3333-333333333303', '22222222-2222-2222-2222-222222222202', 'email', 'bob@example.com', 'connections-only'),
    -- Carol: hidden email
    ('33333333-3333-3333-3333-333333333304', '22222222-2222-2222-2222-222222222203', 'email', 'carol@example.com', 'hidden'),
    -- David: public email and phone
    ('33333333-3333-3333-3333-333333333305', '22222222-2222-2222-2222-222222222204', 'email', 'david@example.com', 'public'),
    ('33333333-3333-3333-3333-333333333306', '22222222-2222-2222-2222-222222222204', 'phone', '555-0104', 'public'),
    -- Eve: connections-only phone
    ('33333333-3333-3333-3333-333333333307', '22222222-2222-2222-2222-222222222205', 'phone', '555-0105', 'connections-only')
on conflict (id) do nothing;
