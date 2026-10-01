-- Bl4ze.Reward — initial schema (Supabase / Postgres)
create extension if not exists "pgcrypto";

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text,
  full_name text,
  role text not null default 'user',
  bio text,
  avatar_url text,
  social_links jsonb default '{}'::jsonb,
  referral_code text,
  created_date timestamptz not null default now(),
  updated_date timestamptz not null default now()
);

create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text,
  description text,
  icon_url text,
  icon_source text not null default 'none',
  image_url text,
  image_source text not null default 'none',
  color text default '#D4AF37',
  sort_order numeric not null default 0,
  is_visible boolean not null default true,
  is_deleted boolean not null default false,
  seo_title text,
  seo_description text,
  created_date timestamptz not null default now(),
  updated_date timestamptz not null default now()
);

create table if not exists public.sites (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  url text not null,
  original_url text,
  description text,
  reward_info text,
  tags text[] default '{}',
  category_ids text[] default '{}',
  status text not null default 'active',
  warning text,
  platform text not null default 'any',
  mobile_compatible boolean not null default true,
  has_copy_code boolean not null default false,
  promo_code text,
  logo_url text,
  logo_source text not null default 'auto_favicon',
  hero_image_url text,
  is_enabled boolean not null default true,
  is_featured boolean not null default false,
  is_archived boolean not null default false,
  sort_order numeric not null default 0,
  admin_notes text,
  click_count numeric not null default 0,
  like_count numeric not null default 0,
  created_date timestamptz not null default now(),
  updated_date timestamptz not null default now()
);

create table if not exists public.discord_servers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  invite_url text not null,
  guild_id text,
  description text,
  icon_url text,
  sort_order numeric not null default 0,
  is_required boolean not null default true,
  is_enabled boolean not null default true,
  created_date timestamptz not null default now(),
  updated_date timestamptz not null default now()
);

create table if not exists public.site_likes (
  id uuid primary key default gen_random_uuid(),
  site_id uuid not null references public.sites (id) on delete cascade,
  created_by_id uuid references public.profiles (id) on delete cascade,
  created_date timestamptz not null default now(),
  unique (site_id, created_by_id)
);
create table if not exists public.site_favorites (
  id uuid primary key default gen_random_uuid(),
  site_id uuid not null references public.sites (id) on delete cascade,
  created_by_id uuid not null references public.profiles (id) on delete cascade,
  created_date timestamptz not null default now(),
  unique (site_id, created_by_id)
);
create table if not exists public.site_visits (
  id uuid primary key default gen_random_uuid(),
  site_id uuid not null references public.sites (id) on delete cascade,
  site_name text,
  created_by_id uuid references public.profiles (id) on delete set null,
  created_date timestamptz not null default now()
);
create table if not exists public.referrals (
  id uuid primary key default gen_random_uuid(),
  referrer_user_id uuid not null references public.profiles (id) on delete cascade,
  referrer_name text,
  referred_user_id uuid not null references public.profiles (id) on delete cascade,
  referred_email text,
  code_used text,
  created_date timestamptz not null default now()
);
create table if not exists public.user_onboarding (
  id uuid primary key default gen_random_uuid(),
  created_by_id uuid not null references public.profiles (id) on delete cascade,
  terms_accepted boolean not null default false,
  confirmed_server_ids text[] default '{}',
  step numeric not null default 1,
  completed boolean not null default false,
  referred_by text,
  created_date timestamptz not null default now(),
  updated_date timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.sites enable row level security;
alter table public.discord_servers enable row level security;
alter table public.site_likes enable row level security;
alter table public.site_favorites enable row level security;
alter table public.site_visits enable row level security;
alter table public.referrals enable row level security;
alter table public.user_onboarding enable row level security;

create policy "public read categories" on public.categories for select using (is_visible = true and is_deleted = false);
create policy "public read sites" on public.sites for select using (is_enabled = true and is_archived = false);
create policy "public read discord servers" on public.discord_servers for select using (is_enabled = true);
create policy "own likes" on public.site_likes for all using (auth.uid() = created_by_id) with check (auth.uid() = created_by_id);
create policy "own favorites" on public.site_favorites for all using (auth.uid() = created_by_id) with check (auth.uid() = created_by_id);
create policy "own onboarding" on public.user_onboarding for all using (auth.uid() = created_by_id) with check (auth.uid() = created_by_id);
create policy "own profile" on public.profiles for all using (auth.uid() = id) with check (auth.uid() = id);
