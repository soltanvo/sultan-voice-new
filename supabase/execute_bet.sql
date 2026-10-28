-- ============================================================================
-- SECURE SERVER-SIDE BETTING INTEGRITY & TRANSACTION RPC
-- تطبيق حماية الألعاب وحفظ رصيد المستخدمين عبر دالة معالجة ذرية في الخادم
-- ============================================================================

-- 1. جدول سجلات الألعاب والرهانات
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

-- فهرس لتسريع استعلام معدل الرهان (Rate Limiting) وسجل الحساب
create index if not exists idx_game_logs_user_rate on public.game_logs (user_id, created_at desc);

-- 2. دالة المعالجة الذرية الصارمة execute_bet لمنع أي تلاعب من جانب العميل
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
  -- أ) التحقق من الحد الأدنى للرهان
  if p_bet_amount <= 0 then
    return jsonb_build_object(
      'success', false,
      'error', 'قيمة الرهان يجب أن تكون أكبر من صفر'
    );
  end if;

  -- ب) منع هجمات النقر السريع والتكراري (Rate-limiting: 800ms)
  select created_at into v_last_bet_time
  from public.game_logs
  where user_id = p_user_id
  order by created_at desc
  limit 1;

  if v_last_bet_time is not null and (now() - v_last_bet_time) < interval '800 milliseconds' then
    return jsonb_build_object(
      'success', false,
      'error', 'يرجى الانتظار بين الجولات لمنع التكرار السريع'
    );
  end if;

  -- ج) قفل وتحديث رصيد المستخدم بشكل ذري لمنع الـ Race Condition (FOR UPDATE)
  select coins into v_current_balance
  from public.profiles
  where id = p_user_id
  for update;

  if v_current_balance is null then
    return jsonb_build_object(
      'success', false,
      'error', 'المستخدم غير موجود'
    );
  end if;

  -- د) التحقق من كفاية الرصيد
  if v_current_balance < p_bet_amount then
    return jsonb_build_object(
      'success', false,
      'error', 'رصيد الكوينز غير كافٍ لإتمام الرهان'
    );
  end if;

  -- هـ) توليد النتيجة بشكل عشوائي آمن في الخادم (Server-authoritative RNG)
  v_random_val := random();

  if v_random_val < 0.38 then
    -- خسارة الجولة
    v_multiplier := 0;
    v_win_amount := 0;
    v_outcome := 'loss';
  elsif v_random_val < 0.75 then
    -- فوز عادي مضاعف x2
    v_multiplier := 2;
    v_win_amount := p_bet_amount * v_multiplier;
    v_outcome := 'win';
  elsif v_random_val < 0.92 then
    -- فوز كبير مضاعف x5
    v_multiplier := 5;
    v_win_amount := p_bet_amount * v_multiplier;
    v_outcome := 'win';
  else
    -- جاكبوت ملكي مضاعف x20
    v_multiplier := 20;
    v_win_amount := p_bet_amount * v_multiplier;
    v_outcome := 'jackpot';
  end if;

  -- و) احتساب وتطبيق الرصيد الجديد ذرياً
  v_new_balance := (v_current_balance - p_bet_amount) + v_win_amount;

  update public.profiles
  set coins = v_new_balance,
      updated_at = now()
  where id = p_user_id;

  -- ز) تسجيل العملية في سجل الألعاب الموثق
  insert into public.game_logs (user_id, game_type, bet_amount, win_amount, multiplier, outcome)
  values (p_user_id, p_game_type, p_bet_amount, v_win_amount, v_multiplier, v_outcome);

  -- ح) إرجاع الاستجابة الآمنة بصيغة JSON
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
