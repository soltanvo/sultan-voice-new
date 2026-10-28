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


-- ============================================================================
-- نظام الألعاب الآمن وتسجيل العمليات ومنع التلاعب (Server-Side Betting)
-- ============================================================================

create table if not exists public.game_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade,
  game_type text not null,
  bet_amount bigint not null check (bet_amount > 0),
  win_amount bigint not null default 0,
  multiplier int not null default 0,
  outcome text not null check (outcome in ('win', 'loss', 'jackpot')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create index if not exists idx_game_logs_user_rate on public.game_logs (user_id, created_at desc);

create or replace function public.execute_bet(
  p_user_id uuid,
  p_game_type text,
  p_bet_amount bigint
)
returns jsonb
language plpgsql
security definer
as $$
declare
  v_current_balance bigint;
  v_last_bet_time timestamp with time zone;
  v_random_val float;
  v_multiplier int := 0;
  v_win_amount bigint := 0;
  v_outcome text := 'loss';
  v_new_balance bigint;
begin
  if p_bet_amount <= 0 then
    return jsonb_build_object('success', false, 'error', 'قيمة الرهان يجب أن تكون أكبر من صفر');
  end if;

  -- Rate limiting: 800ms
  select created_at into v_last_bet_time
  from public.game_logs
  where user_id = p_user_id
  order by created_at desc
  limit 1;

  if v_last_bet_time is not null and (now() - v_last_bet_time) < interval '800 milliseconds' then
    return jsonb_build_object('success', false, 'error', 'يرجى الانتظار بين الجولات لمنع النقر السريع');
  end if;

  select coins into v_current_balance
  from public.profiles
  where id = p_user_id
  for update;

  if v_current_balance is null then
    return jsonb_build_object('success', false, 'error', 'المستخدم غير موجود');
  end if;

  if v_current_balance < p_bet_amount then
    return jsonb_build_object('success', false, 'error', 'رصيد الكوينز غير كافٍ لإتمام الرهان');
  end if;

  v_random_val := random();

  if v_random_val < 0.38 then
    v_multiplier := 0;
    v_win_amount := 0;
    v_outcome := 'loss';
  elsif v_random_val < 0.75 then
    v_multiplier := 2;
    v_win_amount := p_bet_amount * v_multiplier;
    v_outcome := 'win';
  elsif v_random_val < 0.92 then
    v_multiplier := 5;
    v_win_amount := p_bet_amount * v_multiplier;
    v_outcome := 'win';
  else
    v_multiplier := 20;
    v_win_amount := p_bet_amount * v_multiplier;
    v_outcome := 'jackpot';
  end if;

  v_new_balance := (v_current_balance - p_bet_amount) + v_win_amount;

  update public.profiles
  set coins = v_new_balance,
      updated_at = now()
  where id = p_user_id;

  insert into public.game_logs (user_id, game_type, bet_amount, win_amount, multiplier, outcome)
  values (p_user_id, p_game_type, p_bet_amount, v_win_amount, v_multiplier, v_outcome);

  return jsonb_build_object(
    'success', true,
    'game_type', p_game_type,
    'bet_amount', p_bet_amount,
    'win_amount', v_win_amount,
    'multiplier', v_multiplier,
    'outcome', v_outcome,
    'new_balance', v_new_balance
  );
end;
$$;
