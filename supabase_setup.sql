-- ============================================
-- このSQLをSupabaseの「SQL Editor」に全部貼って実行する
-- ============================================

-- 通常カード(復習対象)
create table public.cards (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id),
  subject text not null,
  chapter text not null,
  question text not null,
  answer text not null,
  principle_type text default 'none',
  principle_text text,
  principle_image_path text,
  interval int default 0,
  repetition int default 0,
  efactor float8 default 2.5,
  next_review date not null,
  created_at date not null default current_date
);

alter table public.cards enable row level security;

create policy "本人のカードのみ全操作可能" on public.cards
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- 疑問点(復習対象外、蓄積のみ)
create table public.doubts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id),
  question text,
  answer text,
  image_path text,
  created_at date not null default current_date
);

alter table public.doubts enable row level security;

create policy "本人の疑問点のみ全操作可能" on public.doubts
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ============================================
-- 写真用の非公開ストレージ(他人は一切見れない)
-- ============================================
insert into storage.buckets (id, name, public)
values ('private-media', 'private-media', false);

create policy "本人のファイルのみ読み込み可能" on storage.objects
  for select using (
    bucket_id = 'private-media'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "本人のファイルのみアップロード可能" on storage.objects
  for insert with check (
    bucket_id = 'private-media'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "本人のファイルのみ削除可能" on storage.objects
  for delete using (
    bucket_id = 'private-media'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
