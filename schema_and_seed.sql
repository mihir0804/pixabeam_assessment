-- PixaBeam Assessment — Supabase Schema + Sample Data
-- Run this in Supabase SQL editor (or psql) as a single script.

-- Extensions (Supabase usually has pgcrypto; this is defensive)
create extension if not exists "pgcrypto";

-- DROP (idempotent for re-runs)
drop table if exists public.rsvps cascade;
drop table if exists public.events cascade;
drop table if exists public.users cascade;

-- USERS
create table public.users (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 100),
  email text not null unique,
  created_at timestamptz not null default now()
);

-- EVENTS
create table public.events (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 1 and 200),
  description text,
  date timestamptz not null,
  city text not null,
  created_by uuid not null references public.users(id) on delete cascade, -- deleting a user deletes their events
  created_at timestamptz not null default now()
);

-- RSVPS
create table public.rsvps (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade, -- deleting a user deletes their RSVPs
  event_id uuid not null references public.events(id) on delete cascade, -- deleting an event deletes its RSVPs
  status text not null check (status in ('Yes','No','Maybe')),
  created_at timestamptz not null default now(),
  unique (user_id, event_id) -- 1 RSVP per user per event
);

-- Helpful indexes
create index if not exists idx_events_date on public.events(date);
create index if not exists idx_rsvps_event on public.rsvps(event_id);
create index if not exists idx_rsvps_user on public.rsvps(user_id);

-- (Optional) Row Level Security for quick demo: disabled to keep the app simple.
-- In a production app, enable RLS and add policies.
alter table public.users disable row level security;
alter table public.events disable row level security;
alter table public.rsvps disable row level security;

-- -------------------
-- SAMPLE DATA
-- -------------------

-- Users (10)
insert into public.users (name, email) values
('Aarav Shah','aarav@example.com'),
('Isha Kapoor','isha@example.com'),
('Rohan Mehta','rohan@example.com'),
('Sara Nair','sara@example.com'),
('Kabir Singh','kabir@example.com'),
('Anaya Gupta','anaya@example.com'),
('Vihaan Rao','vihaan@example.com'),
('Meera Joshi','meera@example.com'),
('Arjun Patel','arjun@example.com'),
('Zoya Khan','zoya@example.com');

-- Events (5) — dates are in the near future
with u as (select id from public.users order by created_at limit 5)
insert into public.events (title, description, date, city, created_by) values
('PixaBeam Product Meetup','Monthly community catch-up and demos', now() + interval '5 day', 'Mumbai', (select id from u offset 0 limit 1)),
('Data Science Hangout','Lightning talks + networking', now() + interval '12 day', 'Bengaluru', (select id from u offset 1 limit 1)),
('Design Jam Night','UX prototyping session', now() + interval '20 day', 'Pune', (select id from u offset 2 limit 1)),
('Startup Founders Brunch','Roundtable on GTM and growth', now() + interval '25 day', 'Delhi', (select id from u offset 3 limit 1)),
('Open Source Sprint','Work with maintainers on issues', now() + interval '30 day', 'Hyderabad', (select id from u offset 4 limit 1));

-- RSVPs (20)
-- Map emails to ids for convenience
with
u as (select id, email from public.users),
e as (select id, title from public.events)
insert into public.rsvps (user_id, event_id, status)
values
-- Aarav
((select id from u where email='aarav@example.com'), (select id from e limit 1 offset 0), 'Yes'),
((select id from u where email='aarav@example.com'), (select id from e limit 1 offset 1), 'Maybe'),
-- Isha
((select id from u where email='isha@example.com'), (select id from e limit 1 offset 0), 'No'),
((select id from u where email='isha@example.com'), (select id from e limit 1 offset 2), 'Yes'),
-- Rohan
((select id from u where email='rohan@example.com'), (select id from e limit 1 offset 3), 'Yes'),
((select id from u where email='rohan@example.com'), (select id from e limit 1 offset 1), 'No'),
-- Sara
((select id from u where email='sara@example.com'), (select id from e limit 1 offset 4), 'Maybe'),
((select id from u where email='sara@example.com'), (select id from e limit 1 offset 2), 'Yes'),
-- Kabir
((select id from u where email='kabir@example.com'), (select id from e limit 1 offset 0), 'Yes'),
((select id from u where email='kabir@example.com'), (select id from e limit 1 offset 4), 'Yes'),
-- Anaya
((select id from u where email='anaya@example.com'), (select id from e limit 1 offset 1), 'Maybe'),
((select id from u where email='anaya@example.com'), (select id from e limit 1 offset 2), 'No'),
-- Vihaan
((select id from u where email='vihaan@example.com'), (select id from e limit 1 offset 3), 'Maybe'),
((select id from u where email='vihaan@example.com'), (select id from e limit 1 offset 4), 'No'),
-- Meera
((select id from u where email='meera@example.com'), (select id from e limit 1 offset 0), 'Yes'),
((select id from u where email='meera@example.com'), (select id from e limit 1 offset 3), 'Yes'),
-- Arjun
((select id from u where email='arjun@example.com'), (select id from e limit 1 offset 1), 'Yes'),
((select id from u where email='arjun@example.com'), (select id from e limit 1 offset 4), 'Maybe'),
-- Zoya
((select id from u where email='zoya@example.com'), (select id from e limit 1 offset 2), 'Yes'),
((select id from u where email='zoya@example.com'), (select id from e limit 1 offset 0), 'Maybe');