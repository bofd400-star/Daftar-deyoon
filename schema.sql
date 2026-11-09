-- Run once in Supabase SQL Editor. Each authenticated account can access only its own data.
create table if not exists public.customers (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 name text not null check(length(trim(name))>0),
 phone text not null default '',
 created_at timestamptz not null default now(),
 unique(id,user_id)
);
create table if not exists public.entries (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 customer_id uuid not null,
 kind text not null check(kind in ('debt','payment')),
 amount bigint not null check(amount>0),
 note text not null default '',
 created_at timestamptz not null default now(),
 foreign key(customer_id,user_id) references public.customers(id,user_id) on delete cascade
);
create index if not exists customers_owner_idx on public.customers(user_id);
create index if not exists entries_owner_idx on public.entries(user_id,customer_id);
alter table public.customers enable row level security;
alter table public.entries enable row level security;
create policy "customer owner" on public.customers for all to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
create policy "entry owner" on public.entries for all to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
-- For live changes, enable Realtime for both tables in Supabase Dashboard > Database > Publications.
