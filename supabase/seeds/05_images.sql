-- Seed data for images
-- Avatar and item images using placeholder images for local development

-- Update users with avatar URLs (using picsum placeholder images)
update "user" set avatar_url = 'https://picsum.photos/seed/alice/200/200' where id = '22222222-2222-2222-2222-222222222201';
update "user" set avatar_url = 'https://picsum.photos/seed/bob/200/200' where id = '22222222-2222-2222-2222-222222222202';
update "user" set avatar_url = 'https://picsum.photos/seed/carol/200/200' where id = '22222222-2222-2222-2222-222222222203';
update "user" set avatar_url = 'https://picsum.photos/seed/david/200/200' where id = '22222222-2222-2222-2222-222222222204';
update "user" set avatar_url = 'https://picsum.photos/seed/eve/200/200' where id = '22222222-2222-2222-2222-222222222205';

-- Item images for active items
-- Using picsum with item-specific seeds for consistent placeholder images

-- Alice's items
insert into item_image (id, item_id, url, alt_text, order_index) values
    -- Handmade Ceramic Vase
    ('55555555-5555-5555-5555-555555555501', '44444444-4444-4444-4444-444444444401', 'https://picsum.photos/seed/vase1/800/600', 'Handmade ceramic vase with blue glaze - front view', 0),
    ('55555555-5555-5555-5555-555555555502', '44444444-4444-4444-4444-444444444401', 'https://picsum.photos/seed/vase2/800/600', 'Handmade ceramic vase - detail of glaze', 1),
    -- Set of 4 Ceramic Mugs
    ('55555555-5555-5555-5555-555555555503', '44444444-4444-4444-4444-444444444402', 'https://picsum.photos/seed/mugs1/800/600', 'Set of four ceramic mugs - grouped', 0),
    ('55555555-5555-5555-5555-555555555504', '44444444-4444-4444-4444-444444444402', 'https://picsum.photos/seed/mugs2/800/600', 'Ceramic mug - handle detail', 1)
on conflict (id) do nothing;

-- Bob's items
insert into item_image (id, item_id, url, alt_text, order_index) values
    -- Custom 3D Printed Phone Stand
    ('55555555-5555-5555-5555-555555555505', '44444444-4444-4444-4444-444444444403', 'https://picsum.photos/seed/phonestand1/800/600', '3D printed phone stand - with phone', 0),
    ('55555555-5555-5555-5555-555555555506', '44444444-4444-4444-4444-444444444403', 'https://picsum.photos/seed/phonestand2/800/600', '3D printed phone stand - color options', 1),
    -- Website Development (service - usually no image, but adding one for demo)
    ('55555555-5555-5555-5555-555555555507', '44444444-4444-4444-4444-444444444404', 'https://picsum.photos/seed/webdev/800/600', 'Sample website design mockup', 0)
on conflict (id) do nothing;

-- David's items (services - adding representative images)
insert into item_image (id, item_id, url, alt_text, order_index) values
    -- Home Repair Services
    ('55555555-5555-5555-5555-555555555508', '44444444-4444-4444-4444-444444444407', 'https://picsum.photos/seed/repair1/800/600', 'Home repair tools and workbench', 0),
    -- Furniture Assembly
    ('55555555-5555-5555-5555-555555555509', '44444444-4444-4444-4444-444444444408', 'https://picsum.photos/seed/furniture1/800/600', 'Assembled furniture example', 0)
on conflict (id) do nothing;

-- Eve's items
insert into item_image (id, item_id, url, alt_text, order_index) values
    -- Vintage Office Desk
    ('55555555-5555-5555-5555-555555555510', '44444444-4444-4444-4444-444444444410', 'https://picsum.photos/seed/desk1/800/600', 'Vintage office desk - front view', 0),
    ('55555555-5555-5555-5555-555555555511', '44444444-4444-4444-4444-444444444410', 'https://picsum.photos/seed/desk2/800/600', 'Vintage office desk - drawer detail', 1),
    ('55555555-5555-5555-5555-555555555512', '44444444-4444-4444-4444-444444444410', 'https://picsum.photos/seed/desk3/800/600', 'Vintage office desk - side view', 2)
on conflict (id) do nothing;

-- Archived items (to show they had images too)
insert into item_image (id, item_id, url, alt_text, order_index) values
    -- Alice's Ceramic Serving Bowl (archived)
    ('55555555-5555-5555-5555-555555555513', '44444444-4444-4444-4444-444444444411', 'https://picsum.photos/seed/bowl1/800/600', 'Ceramic serving bowl - top view', 0)
on conflict (id) do nothing;
