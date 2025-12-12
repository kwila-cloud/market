-- Seed data for users
-- Creates user records manually now that auto-create trigger is removed
-- Test users for local development and preview environments

-- Insert user records
insert into "user" (id, auth_user_id, display_name, about, vendor_id, invited_by, created_at) values
    -- User 1: Alice (the initial user, vendor)
    (
        '22222222-2222-2222-2222-222222222201',
        '22222222-2222-2222-2222-222222222201',
        'Alice Johnson',
        'Local artisan specializing in handmade pottery and ceramics. Based in Portland.',
        'alice-pottery',
        null,
        '2025-10-20 10:00:00+00'
    ),
    -- User 2: Bob (invited by Alice, vendor)
    (
        '22222222-2222-2222-2222-222222222202',
        '22222222-2222-2222-2222-222222222202',
        'Bob Smith',
        'Freelance software developer and 3D printing enthusiast.',
        'bob-tech',
        '22222222-2222-2222-2222-222222222201',
        '2025-10-25 14:30:00+00'
    ),
    -- User 3: Carol (invited by Alice, not a vendor)
    (
        '22222222-2222-2222-2222-222222222203',
        '22222222-2222-2222-2222-222222222203',
        'Carol Davis',
        'Looking for quality used items and local services.',
        null,
        '22222222-2222-2222-2222-222222222201',
        '2025-10-30 09:15:00+00'
    ),
    -- User 4: David (invited by Bob, vendor)
    (
        '22222222-2222-2222-2222-222222222204',
        '22222222-2222-2222-2222-222222222204',
        'David Lee',
        'Professional handyman offering home repair and maintenance services.',
        'david-repairs',
        '22222222-2222-2222-2222-222222222202',
        '2025-11-04 11:00:00+00'
    ),
    -- User 5: Eve (invited by Carol, not a vendor)
    (
        '22222222-2222-2222-2222-222222222205',
        '22222222-2222-2222-2222-222222222205',
        'Eve Martinez',
        'Small business owner interested in local networking.',
        null,
        '22222222-2222-2222-2222-222222222203',
        '2025-11-09 16:45:00+00'
    )
on conflict (id) do nothing;

-- Contact info
-- Create contact info records manually

insert into contact_info (id, user_id, contact_type, value, visibility) values
    -- Alice: email (public), phone (connections-only)
    ('33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', 'email', 'alice.market@kwila.cloud', 'public'),
    ('33333333-3333-3333-3333-333333333302', '22222222-2222-2222-2222-222222222201', 'phone', '555-0101', 'connections-only'),
    -- Bob: email (connections-only)
    ('33333333-3333-3333-3333-333333333303', '22222222-2222-2222-2222-222222222202', 'email', 'bob.market@kwila.cloud', 'connections-only'),
    -- Carol: email (hidden)
    ('33333333-3333-3333-3333-333333333304', '22222222-2222-2222-2222-222222222203', 'email', 'carol.market@kwila.cloud', 'hidden'),
    -- David: email (public), phone (public)
    ('33333333-3333-3333-3333-333333333305', '22222222-2222-2222-2222-222222222204', 'email', 'david.market@kwila.cloud', 'public'),
    ('33333333-3333-3333-3333-333333333306', '22222222-2222-2222-2222-222222222204', 'phone', '555-0104', 'public'),
    -- Eve: email (hidden), phone (connections-only)
    ('33333333-3333-3333-3333-333333333307', '22222222-2222-2222-2222-222222222205', 'phone', '555-0105', 'connections-only'),
    ('33333333-3333-3333-3333-333333333308', '22222222-2222-2222-2222-222222222205', 'email', 'eve.market@kwila.cloud', 'hidden')
on conflict (id) do nothing;
