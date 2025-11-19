-- Seed data for categories
-- The three marketplace categories: new, resale, service

insert into category (id, name, description) values
    ('11111111-1111-1111-1111-111111111101', 'new', 'Locally made goods from artisans and small businesses'),
    ('11111111-1111-1111-1111-111111111102', 'resale', 'Quality used goods that deserve a second life'),
    ('11111111-1111-1111-1111-111111111103', 'service', 'Gig work and specialized skills')
on conflict (id) do nothing;
