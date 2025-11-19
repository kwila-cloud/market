-- Seed data for auth.users
-- Creates auth users for local development and preview environments
-- These must be created BEFORE the user table seeds since the trigger
-- will create basic user records automatically

-- Note: All test users use password 'password123' for local development
-- The trigger will automatically create corresponding public.user records

insert into auth.users (
    id,
    instance_id,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at,
    raw_app_meta_data,
    raw_user_meta_data,
    aud,
    role
) values
    -- Alice
    (
        '22222222-2222-2222-2222-222222222201',
        '00000000-0000-0000-0000-000000000000',
        'alice@example.com',
        crypt('password123', gen_salt('bf')),
        '2025-10-20 10:00:00+00',
        '2025-10-20 10:00:00+00',
        '2025-10-20 10:00:00+00',
        '{"provider": "email", "providers": ["email"]}',
        '{}',
        'authenticated',
        'authenticated'
    ),
    -- Bob
    (
        '22222222-2222-2222-2222-222222222202',
        '00000000-0000-0000-0000-000000000000',
        'bob@example.com',
        crypt('password123', gen_salt('bf')),
        '2025-10-25 14:30:00+00',
        '2025-10-25 14:30:00+00',
        '2025-10-25 14:30:00+00',
        '{"provider": "email", "providers": ["email"]}',
        '{}',
        'authenticated',
        'authenticated'
    ),
    -- Carol
    (
        '22222222-2222-2222-2222-222222222203',
        '00000000-0000-0000-0000-000000000000',
        'carol@example.com',
        crypt('password123', gen_salt('bf')),
        '2025-10-30 09:15:00+00',
        '2025-10-30 09:15:00+00',
        '2025-10-30 09:15:00+00',
        '{"provider": "email", "providers": ["email"]}',
        '{}',
        'authenticated',
        'authenticated'
    ),
    -- David
    (
        '22222222-2222-2222-2222-222222222204',
        '00000000-0000-0000-0000-000000000000',
        'david@example.com',
        crypt('password123', gen_salt('bf')),
        '2025-11-04 11:00:00+00',
        '2025-11-04 11:00:00+00',
        '2025-11-04 11:00:00+00',
        '{"provider": "email", "providers": ["email"]}',
        '{}',
        'authenticated',
        'authenticated'
    ),
    -- Eve
    (
        '22222222-2222-2222-2222-222222222205',
        '00000000-0000-0000-0000-000000000000',
        'eve@example.com',
        crypt('password123', gen_salt('bf')),
        '2025-11-09 16:45:00+00',
        '2025-11-09 16:45:00+00',
        '2025-11-09 16:45:00+00',
        '{"provider": "email", "providers": ["email"]}',
        '{}',
        'authenticated',
        'authenticated'
    )
on conflict (id) do nothing;
