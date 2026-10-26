-- مخطط قاعدة بيانات Supabase لتطبيق Sultan Voic الملكي (30 مقعد)

-- جدول الحسابات والألقاب
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  display_name text not null,
  avatar_url text,
  role text default 'user' check (role in ('super_admin', 'manager', 'admin', 'supervisor', 'vip', 'user')),
  svip_level int default 0 check (svip_level between 0 and 9),
  coins bigint default 1000,
  diamonds bigint default 0,
  agency_id uuid,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- جدول الغرف الملكية
create table if not exists public.rooms (
  id text primary key,
  title text not null,
  owner_id uuid references public.profiles(id),
  total_seats int default 30,
  is_locked boolean default false,
  background_theme text default 'royal_obsidian',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- جدول المقاعد الـ 30 في كل غرفة
create table if not exists public.room_seats (
  room_id text references public.rooms(id) on delete cascade,
  seat_index int check (seat_index between 0 and 29),
  user_id uuid references public.profiles(id) on delete set null,
  is_locked boolean default false,
  is_muted boolean default false,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (room_id, seat_index)
);

-- جدول الوكالات وتفويض المشرفين
create table if not exists public.agencies (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  agency_code text unique not null,
  owner_id uuid references public.profiles(id),
  supervisor_ids uuid[] default array[]::uuid[],
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- جدول نظام التحديث الإجباري لإصدارات التطبيق (APK)
create table if not exists public.app_versions (
  id serial primary key,
  latest_version text not null default '1.1.0',
  min_required_version text not null default '1.1.0',
  force_update boolean not null default true,
  download_url text not null default 'https://sultanvoic.com/download/sultan_voic_v1.1.0.apk',
  update_title text not null default 'تحديث إمبراطوري جديد متاح لـ Sultan Voic 👑',
  update_notes text[] default array[
    'إطلاق تأثير الصقر الأسود الملكي والأشعة المظلمة لـ SVIP 9',
    'ترقية نقاء وسرعة الغرف الصوتية الفورية (LiveKit Token 200)',
    'إضافة لعبة عجلة الحظ الملكية (Lucky Wheel)',
    'سد الثغرات وتأمين حماية الغرف الملكية ضد التعليق'
  ]::text[],
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- إدراج الإصدار الافتراضي لتفعيل التحديث الإجباري فوراً
insert into public.app_versions (latest_version, min_required_version, force_update, download_url, update_title)
values ('1.1.0', '1.1.0', true, 'https://sultanvoic.com/download/sultan_voic_v1.1.0.apk', 'تحديث إمبراطوري إجباري جديد لـ Sultan Voic 👑')
on conflict do nothing;

-- تمكين Realtime للمزامنة الفورية
alter publication supabase_realtime add table public.rooms;
alter publication supabase_realtime add table public.room_seats;
alter publication supabase_realtime add table public.profiles;
alter publication supabase_realtime add table public.app_versions;
