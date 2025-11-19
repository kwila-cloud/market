-- Seed data for images
-- Avatar and item images for local development

-- Update users with avatar storage paths
-- These reference files in supabase/storage/images/ which are loaded into the 'images' bucket
update "user" set avatar_url = 'avatars/22222222-2222-2222-2222-222222222201/avatar.png' where id = '22222222-2222-2222-2222-222222222201';
update "user" set avatar_url = 'avatars/22222222-2222-2222-2222-222222222202/avatar.png' where id = '22222222-2222-2222-2222-222222222202';
update "user" set avatar_url = 'avatars/22222222-2222-2222-2222-222222222203/avatar.png' where id = '22222222-2222-2222-2222-222222222203';
update "user" set avatar_url = 'avatars/22222222-2222-2222-2222-222222222204/avatar.png' where id = '22222222-2222-2222-2222-222222222204';
update "user" set avatar_url = 'avatars/22222222-2222-2222-2222-222222222205/avatar.png' where id = '22222222-2222-2222-2222-222222222205';

-- Item images for active items
-- These reference files in supabase/storage/images/ which are loaded into the 'images' bucket

-- Alice's items
insert into item_image (id, item_id, url, alt_text, order_index) values
    -- Handmade Ceramic Vase
    ('55555555-5555-5555-5555-555555555501', '44444444-4444-4444-4444-444444444401', 'items/44444444-4444-4444-4444-444444444401/0.png', 'Handmade ceramic vase with blue glaze - front view', 0),
    ('55555555-5555-5555-5555-555555555502', '44444444-4444-4444-4444-444444444401', 'items/44444444-4444-4444-4444-444444444401/1.png', 'Handmade ceramic vase - detail of glaze', 1),
    -- Set of 4 Ceramic Mugs
    ('55555555-5555-5555-5555-555555555503', '44444444-4444-4444-4444-444444444402', 'items/44444444-4444-4444-4444-444444444402/0.png', 'Set of four ceramic mugs - grouped', 0),
    ('55555555-5555-5555-5555-555555555504', '44444444-4444-4444-4444-444444444402', 'items/44444444-4444-4444-4444-444444444402/1.png', 'Ceramic mug - handle detail', 1)
on conflict (id) do nothing;

-- Bob's items
insert into item_image (id, item_id, url, alt_text, order_index) values
    -- Custom 3D Printed Phone Stand
    ('55555555-5555-5555-5555-555555555505', '44444444-4444-4444-4444-444444444403', 'items/44444444-4444-4444-4444-444444444403/0.png', '3D printed phone stand - with phone', 0),
    ('55555555-5555-5555-5555-555555555506', '44444444-4444-4444-4444-444444444403', 'items/44444444-4444-4444-4444-444444444403/1.png', '3D printed phone stand - color options', 1),
    -- Website Development (service - usually no image, but adding one for demo)
    ('55555555-5555-5555-5555-555555555507', '44444444-4444-4444-4444-444444444404', 'items/44444444-4444-4444-4444-444444444404/0.png', 'Sample website design mockup', 0)
on conflict (id) do nothing;

-- David's items (services - adding representative images)
insert into item_image (id, item_id, url, alt_text, order_index) values
    -- Home Repair Services
    ('55555555-5555-5555-5555-555555555508', '44444444-4444-4444-4444-444444444407', 'items/44444444-4444-4444-4444-444444444407/0.png', 'Home repair tools and workbench', 0),
    -- Furniture Assembly
    ('55555555-5555-5555-5555-555555555509', '44444444-4444-4444-4444-444444444408', 'items/44444444-4444-4444-4444-444444444408/0.png', 'Assembled furniture example', 0)
on conflict (id) do nothing;

-- Eve's items
insert into item_image (id, item_id, url, alt_text, order_index) values
    -- Vintage Office Desk
    ('55555555-5555-5555-5555-555555555510', '44444444-4444-4444-4444-444444444410', 'items/44444444-4444-4444-4444-444444444410/0.png', 'Vintage office desk - front view', 0),
    ('55555555-5555-5555-5555-555555555511', '44444444-4444-4444-4444-444444444410', 'items/44444444-4444-4444-4444-444444444410/1.png', 'Vintage office desk - drawer detail', 1),
    ('55555555-5555-5555-5555-555555555512', '44444444-4444-4444-4444-444444444410', 'items/44444444-4444-4444-4444-444444444410/2.png', 'Vintage office desk - side view', 2)
on conflict (id) do nothing;

-- Archived items (to show they had images too)
insert into item_image (id, item_id, url, alt_text, order_index) values
    -- Alice's Ceramic Serving Bowl (archived)
    ('55555555-5555-5555-5555-555555555513', '44444444-4444-4444-4444-444444444411', 'items/44444444-4444-4444-4444-444444444411/0.png', 'Ceramic serving bowl - top view', 0)
on conflict (id) do nothing;
