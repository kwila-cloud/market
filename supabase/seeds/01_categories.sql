-- Seed data for categories
-- The three marketplace categories: new, resale, service

insert into category (id, name, description) values
    ('new', 'New', 'Locally made goods from artisans and small businesses'),
    ('resale', 'Resale', 'Quality used goods that deserve a second life'),
    ('service', 'Service', 'Gig work and specialized skills')
on conflict (id) do nothing;
