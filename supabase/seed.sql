-- A Market - Seed Data for Local Development
-- This file creates test users, items, and connections for local testing

-- NOTE: This seed data is for LOCAL DEVELOPMENT ONLY
-- DO NOT run this in production!

-- ===========================================
-- TEST USERS
-- ===========================================

-- Create test users
-- Note: In production, users are created via Supabase Auth
-- For local testing, we create them directly

INSERT INTO "user" (id, display_name, about, vendor_id, created_at) VALUES
    ('00000000-0000-0000-0000-000000000001', 'Alice Anderson', 'Local artisan specializing in handmade pottery and ceramics. Based in Portland, OR.', 'alice-pottery', NOW() - INTERVAL '30 days'),
    ('00000000-0000-0000-0000-000000000002', 'Bob Builder', 'Professional contractor with 15 years experience. Available for home renovation projects.', 'bob-builds', NOW() - INTERVAL '25 days'),
    ('00000000-0000-0000-0000-000000000003', 'Carol Chen', 'Freelance graphic designer and illustrator. Creating custom artwork for businesses.', 'carol-design', NOW() - INTERVAL '20 days'),
    ('00000000-0000-0000-0000-000000000004', 'David Martinez', 'Tech enthusiast and collector. Always looking for vintage electronics and gadgets.', 'david-tech', NOW() - INTERVAL '15 days'),
    ('00000000-0000-0000-0000-000000000005', 'Emma Wilson', 'Sustainable fashion advocate. Selling pre-loved clothing and accessories.', 'emma-fashion', NOW() - INTERVAL '10 days');

-- Set invited_by relationships (Alice invited everyone)
UPDATE "user" SET invited_by = '00000000-0000-0000-0000-000000000001'
WHERE id != '00000000-0000-0000-0000-000000000001';

-- ===========================================
-- CONTACT INFO
-- ===========================================

INSERT INTO contact_info (user_id, contact_type, value, visibility) VALUES
    -- Alice's contact info
    ('00000000-0000-0000-0000-000000000001', 'email', 'alice@example.com', 'public'),
    ('00000000-0000-0000-0000-000000000001', 'phone', '+15551234001', 'private'),

    -- Bob's contact info
    ('00000000-0000-0000-0000-000000000002', 'email', 'bob@example.com', 'private'),
    ('00000000-0000-0000-0000-000000000002', 'phone', '+15551234002', 'hidden'),

    -- Carol's contact info
    ('00000000-0000-0000-0000-000000000003', 'email', 'carol@example.com', 'public'),

    -- David's contact info
    ('00000000-0000-0000-0000-000000000004', 'email', 'david@example.com', 'private'),
    ('00000000-0000-0000-0000-000000000004', 'phone', '+15551234004', 'private'),

    -- Emma's contact info
    ('00000000-0000-0000-0000-000000000005', 'email', 'emma@example.com', 'public'),
    ('00000000-0000-0000-0000-000000000005', 'phone', '+15551234005', 'public');

-- ===========================================
-- USER SETTINGS
-- ===========================================

INSERT INTO user_settings (user_id, setting_key, setting_value) VALUES
    ('00000000-0000-0000-0000-000000000001', 'theme', '"dusk"'),
    ('00000000-0000-0000-0000-000000000002', 'theme', '"ember"'),
    ('00000000-0000-0000-0000-000000000003', 'theme', '"ocean"'),
    ('00000000-0000-0000-0000-000000000004', 'theme', '"forest"'),
    ('00000000-0000-0000-0000-000000000005', 'theme', '"dusk"');

-- ===========================================
-- CONNECTIONS
-- ===========================================

INSERT INTO connection (user_a, user_b, status, created_at) VALUES
    -- Alice and Bob are connected
    ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'accepted', NOW() - INTERVAL '20 days'),

    -- Alice and Carol are connected
    ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000003', 'accepted', NOW() - INTERVAL '18 days'),

    -- Bob and David are connected
    ('00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000004', 'accepted', NOW() - INTERVAL '15 days'),

    -- Carol and Emma have pending connection
    ('00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000005', 'pending', NOW() - INTERVAL '5 days'),

    -- David and Alice are connected
    ('00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001', 'accepted', NOW() - INTERVAL '12 days');

-- ===========================================
-- ITEMS
-- ===========================================

-- Get category IDs first (these were created in migration)
DO $$
DECLARE
    cat_new UUID;
    cat_resale UUID;
    cat_service UUID;
BEGIN
    SELECT id INTO cat_new FROM category WHERE name = 'new';
    SELECT id INTO cat_resale FROM category WHERE name = 'resale';
    SELECT id INTO cat_service FROM category WHERE name = 'service';

    -- Alice's items (pottery vendor)
    INSERT INTO item (id, user_id, type, category_id, title, description, price_string, visibility, status, created_at) VALUES
        ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'sell', cat_new, 'Handmade Ceramic Mug Set', 'Beautiful set of 4 handmade ceramic mugs. Each mug is unique with a rustic glaze finish. Microwave and dishwasher safe.', '$80', 'public', 'active', NOW() - INTERVAL '15 days'),
        ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'sell', cat_new, 'Large Pottery Planter', 'Hand-thrown terracotta planter perfect for indoor plants. Includes drainage hole. 12 inches diameter.', '$65', 'public', 'active', NOW() - INTERVAL '10 days'),
        ('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 'sell', cat_new, 'Custom Pottery Commission', 'I take custom orders for pottery pieces. Contact me with your ideas!', 'Varies', 'public', 'active', NOW() - INTERVAL '5 days');

    -- Bob's items (contractor)
    INSERT INTO item (id, user_id, type, category_id, title, description, price_string, visibility, status, created_at) VALUES
        ('10000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000002', 'sell', cat_service, 'Kitchen Renovation Services', 'Complete kitchen remodeling services including cabinets, countertops, and flooring. Free estimates!', 'Starting at $15,000', 'public', 'active', NOW() - INTERVAL '18 days'),
        ('10000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000002', 'buy', cat_resale, 'Looking for: Quality Power Tools', 'Expanding my tool collection. Interested in DeWalt or Milwaukee power tools in good condition.', '$50-300 per tool', 'public', 'active', NOW() - INTERVAL '8 days');

    -- Carol's items (designer)
    INSERT INTO item (id, user_id, type, category_id, title, description, price_string, visibility, status, created_at) VALUES
        ('10000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000003', 'sell', cat_service, 'Logo Design Package', 'Professional logo design with 3 concepts and unlimited revisions. Includes vector files.', '$500', 'public', 'active', NOW() - INTERVAL '12 days'),
        ('10000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000003', 'sell', cat_service, 'Social Media Graphics', 'Custom social media graphics for your business. Package includes 10 unique posts.', '$250', 'public', 'active', NOW() - INTERVAL '7 days'),
        ('10000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000003', 'buy', cat_resale, 'Wanted: Vintage Design Books', 'Looking for classic design and typography books from the 70s-90s. Especially interested in Massimo Vignelli.', 'Up to $50 per book', 'private', 'active', NOW() - INTERVAL '3 days');

    -- David's items (tech collector)
    INSERT INTO item (id, user_id, type, category_id, title, description, price_string, visibility, status, created_at) VALUES
        ('10000000-0000-0000-0000-000000000009', '00000000-0000-0000-0000-000000000004', 'buy', cat_resale, 'Seeking: Original Game Boy', 'Looking for original Nintendo Game Boy in working condition. Prefer complete in box but will consider loose.', '$100-300', 'public', 'active', NOW() - INTERVAL '14 days'),
        ('10000000-0000-0000-0000-000000000010', '00000000-0000-0000-0000-000000000004', 'buy', cat_resale, 'Wanted: Vintage Calculators', 'Collector seeking vintage calculators from the 70s and 80s. HP, TI, Casio all welcome!', 'Varies', 'public', 'active', NOW() - INTERVAL '6 days');

    -- Emma's items (sustainable fashion)
    INSERT INTO item (id, user_id, type, category_id, title, description, price_string, visibility, status, created_at) VALUES
        ('10000000-0000-0000-0000-000000000011', '00000000-0000-0000-0000-000000000005', 'sell', cat_resale, 'Vintage Levi''s Jeans', 'Authentic vintage Levi''s 501 jeans from the 90s. Size 32x32. Excellent condition.', '$85', 'public', 'active', NOW() - INTERVAL '9 days'),
        ('10000000-0000-0000-0000-000000000012', '00000000-0000-0000-0000-000000000005', 'sell', cat_resale, 'Patagonia Fleece Jacket', 'Gently used Patagonia Better Sweater fleece. Women''s size medium. Navy blue.', '$60', 'public', 'active', NOW() - INTERVAL '4 days'),
        ('10000000-0000-0000-0000-000000000013', '00000000-0000-0000-0000-000000000005', 'sell', cat_resale, 'Designer Handbag Collection', 'Various pre-loved designer handbags. Kate Spade, Michael Kors, Coach. See photos for details.', '$50-200', 'public', 'active', NOW() - INTERVAL '2 days');
END $$;

-- ===========================================
-- INVITES
-- ===========================================

INSERT INTO invite (inviter_id, invite_code, created_at) VALUES
    -- Active invite from Alice
    ('00000000-0000-0000-0000-000000000001', 'ABC12345', NOW() - INTERVAL '2 days'),

    -- Used invite from Alice (used by Bob)
    ('00000000-0000-0000-0000-000000000001', 'DEF67890', NOW() - INTERVAL '25 days'),

    -- Revoked invite from Carol
    ('00000000-0000-0000-0000-000000000003', 'GHI11111', NOW() - INTERVAL '10 days');

-- Mark Bob's invite as used
UPDATE invite SET used_by = '00000000-0000-0000-0000-000000000002', used_at = NOW() - INTERVAL '24 days'
WHERE invite_code = 'DEF67890';

-- Mark Carol's invite as revoked
UPDATE invite SET revoked_at = NOW() - INTERVAL '9 days'
WHERE invite_code = 'GHI11111';

-- ===========================================
-- MESSAGE THREADS (sample)
-- ===========================================

-- Thread between David and Alice about ceramic mugs
INSERT INTO thread (id, item_id, creator_id, responder_id, created_at) VALUES
    ('20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001', NOW() - INTERVAL '5 days');

-- Thread between Emma and Bob about power tools
INSERT INTO thread (id, item_id, creator_id, responder_id, created_at) VALUES
    ('20000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000002', NOW() - INTERVAL '3 days');

-- ===========================================
-- MESSAGES
-- ===========================================

-- Messages in David-Alice thread about mugs
INSERT INTO message (thread_id, sender_id, content, read, created_at) VALUES
    ('20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000004', 'Hi Alice! I love these mugs. Are they still available?', TRUE, NOW() - INTERVAL '5 days'),
    ('20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Yes they are! I just finished glazing them this week.', TRUE, NOW() - INTERVAL '4 days' - INTERVAL '18 hours'),
    ('20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000004', 'Perfect! Can I pick them up this weekend?', TRUE, NOW() - INTERVAL '4 days' - INTERVAL '12 hours'),
    ('20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Sure! I''ll send you my address. Saturday afternoon works best for me.', FALSE, NOW() - INTERVAL '4 days' - INTERVAL '6 hours');

-- Messages in Emma-Bob thread about tools
INSERT INTO message (thread_id, sender_id, content, read, created_at) VALUES
    ('20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000005', 'Hi Bob! I have a DeWalt drill set that might interest you. Barely used.', TRUE, NOW() - INTERVAL '3 days'),
    ('20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'That sounds great! What model and what are you asking for it?', FALSE, NOW() - INTERVAL '2 days' - INTERVAL '20 hours');

-- ===========================================
-- WATCH LIST (sample)
-- ===========================================

INSERT INTO watch (user_id, name, query_params, created_at) VALUES
    ('00000000-0000-0000-0000-000000000004', 'Vintage Electronics', 'type=sell&category=resale&q=vintage+electronic', NOW() - INTERVAL '10 days'),
    ('00000000-0000-0000-0000-000000000003', 'Design Services', 'type=sell&category=service&q=design', NOW() - INTERVAL '7 days');

-- ===========================================
-- SUCCESS MESSAGE
-- ===========================================

DO $$
BEGIN
    RAISE NOTICE '✓ Seed data created successfully!';
    RAISE NOTICE '  - 5 test users';
    RAISE NOTICE '  - 13 items (various types)';
    RAISE NOTICE '  - 5 connections';
    RAISE NOTICE '  - 2 message threads with 6 messages';
    RAISE NOTICE '  - 3 invite codes';
    RAISE NOTICE '  ';
    RAISE NOTICE 'Test user IDs:';
    RAISE NOTICE '  Alice: 00000000-0000-0000-0000-000000000001';
    RAISE NOTICE '  Bob:   00000000-0000-0000-0000-000000000002';
    RAISE NOTICE '  Carol: 00000000-0000-0000-0000-000000000003';
    RAISE NOTICE '  David: 00000000-0000-0000-0000-000000000004';
    RAISE NOTICE '  Emma:  00000000-0000-0000-0000-000000000005';
END $$;
