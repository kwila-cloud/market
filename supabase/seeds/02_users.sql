-- Seed data for users
-- Updates user records created by auth trigger with full profile data
-- Test users for local development and preview environments

-- User 1: Alice (the initial user, vendor)
update "user" set
    display_name = 'Alice Johnson',
    about = 'Local artisan specializing in handmade pottery and ceramics. Based in Portland.',
    vendor_id = 'alice-pottery',
    created_at = '2025-10-20 10:00:00+00'
where id = '22222222-2222-2222-2222-222222222201';

-- User 2: Bob (invited by Alice, vendor)
update "user" set
    display_name = 'Bob Smith',
    about = 'Freelance software developer and 3D printing enthusiast.',
    vendor_id = 'bob-tech',
    invited_by = '22222222-2222-2222-2222-222222222201',
    created_at = '2025-10-25 14:30:00+00'
where id = '22222222-2222-2222-2222-222222222202';

-- User 3: Carol (invited by Alice, not a vendor)
update "user" set
    display_name = 'Carol Davis',
    about = 'Looking for quality used items and local services.',
    invited_by = '22222222-2222-2222-2222-222222222201',
    created_at = '2025-10-30 09:15:00+00'
where id = '22222222-2222-2222-2222-222222222203';

-- User 4: David (invited by Bob, vendor)
update "user" set
    display_name = 'David Lee',
    about = 'Professional handyman offering home repair and maintenance services.',
    vendor_id = 'david-repairs',
    invited_by = '22222222-2222-2222-2222-222222222202',
    created_at = '2025-11-04 11:00:00+00'
where id = '22222222-2222-2222-2222-222222222204';

-- User 5: Eve (invited by Carol, not a vendor)
update "user" set
    display_name = 'Eve Martinez',
    about = 'Small business owner interested in local networking.',
    invited_by = '22222222-2222-2222-2222-222222222203',
    created_at = '2025-11-09 16:45:00+00'
where id = '22222222-2222-2222-2222-222222222205';

-- Contact info updates and additions
-- The trigger creates email contact_info as 'hidden', update visibility as needed

-- Alice: update email to public, add phone as connections-only
update contact_info set
    id = '33333333-3333-3333-3333-333333333301',
    visibility = 'public'
where user_id = '22222222-2222-2222-2222-222222222201' and contact_type = 'email';

insert into contact_info (id, user_id, contact_type, value, visibility) values
    ('33333333-3333-3333-3333-333333333302', '22222222-2222-2222-2222-222222222201', 'phone', '555-0101', 'connections-only')
on conflict (id) do nothing;

-- Bob: update email to connections-only
update contact_info set
    id = '33333333-3333-3333-3333-333333333303',
    visibility = 'connections-only'
where user_id = '22222222-2222-2222-2222-222222222202' and contact_type = 'email';

-- Carol: email stays hidden (default from trigger)
update contact_info set
    id = '33333333-3333-3333-3333-333333333304'
where user_id = '22222222-2222-2222-2222-222222222203' and contact_type = 'email';

-- David: update email to public, add phone as public
update contact_info set
    id = '33333333-3333-3333-3333-333333333305',
    visibility = 'public'
where user_id = '22222222-2222-2222-2222-222222222204' and contact_type = 'email';

insert into contact_info (id, user_id, contact_type, value, visibility) values
    ('33333333-3333-3333-3333-333333333306', '22222222-2222-2222-2222-222222222204', 'phone', '555-0104', 'public')
on conflict (id) do nothing;

-- Eve: add phone as connections-only (no email in original seed, but trigger created one)
-- Note: Eve's email was not in original seed but trigger will create it as hidden
update contact_info set
    id = '33333333-3333-3333-3333-333333333308'
where user_id = '22222222-2222-2222-2222-222222222205' and contact_type = 'email';

insert into contact_info (id, user_id, contact_type, value, visibility) values
    ('33333333-3333-3333-3333-333333333307', '22222222-2222-2222-2222-222222222205', 'phone', '555-0105', 'connections-only')
on conflict (id) do nothing;
