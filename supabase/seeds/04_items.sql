-- Seed data for items
-- Sample marketplace listings for local development

-- Alice's items (new - pottery)
insert into item (id, user_id, type, category_id, title, description, price_string, visibility, status, created_at) values
    ('44444444-4444-4444-4444-444444444401', '22222222-2222-2222-2222-222222222201', 'sell', 'new', 'Handmade Ceramic Vase', 'Beautiful hand-thrown vase with blue glaze. Perfect for fresh flowers or as a standalone piece. Approx 8" tall.', '$45', 'public', 'active', '2025-10-22 11:30:00+00'),
    ('44444444-4444-4444-4444-444444444402', '22222222-2222-2222-2222-222222222201', 'sell', 'new', 'Set of 4 Ceramic Mugs', 'Matching set of handcrafted mugs. Microwave and dishwasher safe. Each holds about 12oz.', '$60', 'public', 'active', '2025-10-30 14:00:00+00')
on conflict (id) do nothing;

-- Bob's items (new - 3D prints, service - software)
insert into item (id, user_id, type, category_id, title, description, price_string, visibility, status, created_at) values
    ('44444444-4444-4444-4444-444444444403', '22222222-2222-2222-2222-222222222202', 'sell', 'new', 'Custom 3D Printed Phone Stand', 'Adjustable phone stand, available in multiple colors. Specify your color preference when ordering.', '$15', 'public', 'active', '2025-10-28 09:00:00+00'),
    ('44444444-4444-4444-4444-444444444404', '22222222-2222-2222-2222-222222222202', 'sell', 'service', 'Website Development', 'Custom website development for small businesses. Includes design, development, and basic SEO setup.', 'Starting at $500', 'public', 'active', '2025-11-01 10:30:00+00')
on conflict (id) do nothing;

-- Carol's items (buy requests - resale)
insert into item (id, user_id, type, category_id, title, description, price_string, visibility, status, created_at) values
    ('44444444-4444-4444-4444-444444444405', '22222222-2222-2222-2222-222222222203', 'buy', 'resale', 'Looking for Used Stove', 'Need a working gas or electric stove for my apartment. Must be in good condition.', 'Budget: $200', 'public', 'active', '2025-11-02 13:00:00+00'),
    ('44444444-4444-4444-4444-444444444406', '22222222-2222-2222-2222-222222222203', 'buy', 'service', 'Need House Cleaning Service', 'Looking for a reliable house cleaner for bi-weekly visits. 2-bedroom apartment, about 900 sq ft.', 'Budget: $80/visit', 'connections-only', 'active', '2025-11-07 15:30:00+00')
on conflict (id) do nothing;

-- David's items (service - repairs)
insert into item (id, user_id, type, category_id, title, description, price_string, visibility, status, created_at) values
    ('44444444-4444-4444-4444-444444444407', '22222222-2222-2222-2222-222222222204', 'sell', 'service', 'Home Repair Services', 'General handyman services: plumbing, electrical, drywall, painting, and more. Free estimates.', '$50/hour', 'public', 'active', '2025-11-05 08:00:00+00'),
    ('44444444-4444-4444-4444-444444444408', '22222222-2222-2222-2222-222222222204', 'sell', 'service', 'Furniture Assembly', 'Professional assembly of IKEA and other flat-pack furniture. Most items completed same day.', '$30-100 depending on complexity', 'public', 'active', '2025-11-11 12:00:00+00')
on conflict (id) do nothing;

-- Eve's items (buy request - new, resale items for sale)
insert into item (id, user_id, type, category_id, title, description, price_string, visibility, status, created_at) values
    ('44444444-4444-4444-4444-444444444409', '22222222-2222-2222-2222-222222222205', 'buy', 'new', 'Custom Business Cards', 'Looking for someone to design and print custom business cards for my bakery. Need about 500 cards.', 'Budget: $75', 'public', 'active', '2025-11-12 10:00:00+00'),
    ('44444444-4444-4444-4444-444444444410', '22222222-2222-2222-2222-222222222205', 'sell', 'resale', 'Vintage Office Desk', 'Solid wood desk from the 1960s. Great condition with minor wear. Dimensions: 60"x30"x30".', '$175', 'public', 'active', '2025-11-14 09:30:00+00')
on conflict (id) do nothing;

-- Archived items (completed/fulfilled listings)
insert into item (id, user_id, type, category_id, title, description, price_string, visibility, status, created_at) values
    -- Alice's sold pottery
    ('44444444-4444-4444-4444-444444444411', '22222222-2222-2222-2222-222222222201', 'sell', 'new', 'Ceramic Serving Bowl', 'Large hand-thrown serving bowl with earth tone glazes. Perfect for salads or pasta. Approx 12" diameter.', '$55', 'public', 'archived', '2025-10-05 11:00:00+00'),
    -- Bob's completed project
    ('44444444-4444-4444-4444-444444444412', '22222222-2222-2222-2222-222222222202', 'sell', 'service', 'Mobile App Development', 'Custom mobile app development using React Native. Cross-platform iOS and Android support included.', 'Starting at $2500', 'public', 'archived', '2025-09-20 14:00:00+00'),
    -- Carol's fulfilled request
    ('44444444-4444-4444-4444-444444444413', '22222222-2222-2222-2222-222222222203', 'buy', 'resale', 'Looking for Used Bookshelf', 'Need a tall bookshelf for my home office. At least 5 shelves, preferably wood.', 'Budget: $100', 'public', 'archived', '2025-10-20 16:00:00+00'),
    -- David's seasonal service
    ('44444444-4444-4444-4444-444444444414', '22222222-2222-2222-2222-222222222204', 'sell', 'service', 'Holiday Light Installation', 'Professional holiday light installation and removal. Residential only. Includes ladder work and roof mounting.', '$150-400', 'public', 'archived', '2025-08-21 10:00:00+00')
on conflict (id) do nothing;

-- Deleted items (removed by user)
insert into item (id, user_id, type, category_id, title, description, price_string, visibility, status, created_at) values
    -- Alice deleted a duplicate listing
    ('44444444-4444-4444-4444-444444444415', '22222222-2222-2222-2222-222222222201', 'sell', 'new', 'Handmade Ceramic Vase', 'Beautiful hand-thrown vase with blue glaze. Perfect for fresh flowers or as a standalone piece. Approx 8" tall.', '$45', 'public', 'deleted', '2025-10-23 09:00:00+00'),
    -- Bob removed an outdated service
    ('44444444-4444-4444-4444-444444444416', '22222222-2222-2222-2222-222222222202', 'sell', 'service', 'WordPress Maintenance', 'Monthly WordPress updates and backups. Includes security patches and plugin updates.', '$50/month', 'public', 'deleted', '2025-10-10 11:00:00+00'),
    -- Eve cancelled a request
    ('44444444-4444-4444-4444-444444444417', '22222222-2222-2222-2222-222222222205', 'buy', 'resale', 'Looking for Filing Cabinet', 'Need a 2-drawer filing cabinet for my home office. Metal or wood is fine.', 'Budget: $50', 'public', 'deleted', '2025-11-13 14:00:00+00')
on conflict (id) do nothing;
