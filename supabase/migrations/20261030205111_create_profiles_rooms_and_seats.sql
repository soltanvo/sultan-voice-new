/*
# Create profiles, rooms and room seats

1. New Tables
- `profiles`: one row per signed-in user (display name, role, coin balance, SVIP level). Created automatically when someone signs up.
- `rooms`: the official voice rooms (customer service room and management room).
- `room_seats`: 30 microphone seats per room. A seat is either empty or held by one user.

2. Automation
- A trigger on sign-up creates the matching profile row, so the app never has to write profiles itself.

3. Security
- Row level security is enabled on all three tables.
- Signed-in users can read their own profile, the room list, and all seats.
- Users can change only their own display name.
- Users can take an empty (unlocked) seat, move their own seat state, and leave their seat. They cannot modify other users' seats.
- Coin balance, role and SVIP level are read-only from the app.

4. Seed data
- The two official rooms and their 30 seats each are inserted if missing.
*/

CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name text NOT NULL,
  role text NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'supervisor', 'manager', 'super_admin')),
  coins bigint NOT NULL DEFAULT 1000 CHECK (coins >= 0),
  svip_level smallint NOT NULL DEFAULT 0 CHECK (svip_level BETWEEN 0 AND 9),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS rooms (
  id text PRIMARY KEY,
  title text NOT NULL,
  description text NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS room_seats (
  room_id text NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  seat_index smallint NOT NULL CHECK (seat_index BETWEEN 0 AND 29),
  user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  display_name text,
  is_muted boolean NOT NULL DEFAULT false,
  is_locked boolean NOT NULL DEFAULT false,
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (room_id, seat_index)
);

CREATE INDEX IF NOT EXISTS room_seats_user_id_idx ON room_seats (user_id);

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name)
  VALUES (
    NEW.id,
    COALESCE(NULLIF(TRIM(NEW.raw_user_meta_data->>'display_name'), ''), split_part(NEW.email, '@', 1))
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM PUBLIC, anon, authenticated;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE room_seats ENABLE ROW LEVEL SECURITY;

GRANT SELECT ON profiles TO authenticated;
GRANT UPDATE (display_name) ON profiles TO authenticated;
GRANT SELECT ON rooms TO authenticated;
GRANT SELECT ON room_seats TO authenticated;
GRANT UPDATE (user_id, display_name, is_muted) ON room_seats TO authenticated;

DROP POLICY IF EXISTS "select_own_profile" ON profiles;
CREATE POLICY "select_own_profile" ON profiles FOR SELECT
  TO authenticated USING (auth.uid() = id);

DROP POLICY IF EXISTS "update_own_profile_name" ON profiles;
CREATE POLICY "update_own_profile_name" ON profiles FOR UPDATE
  TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "select_rooms" ON rooms;
CREATE POLICY "select_rooms" ON rooms FOR SELECT
  TO authenticated USING (true);

DROP POLICY IF EXISTS "select_room_seats" ON room_seats;
CREATE POLICY "select_room_seats" ON room_seats FOR SELECT
  TO authenticated USING (true);

DROP POLICY IF EXISTS "take_or_leave_seat" ON room_seats;
CREATE POLICY "take_or_leave_seat" ON room_seats FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid() OR (user_id IS NULL AND is_locked = false))
  WITH CHECK (user_id = auth.uid() OR user_id IS NULL);

INSERT INTO rooms (id, title, description) VALUES
  ('customer_service_room', 'غرفة خدمة العملاء الرسمية', 'الدعم الفني والشكاوى والمساعدة المباشرة'),
  ('management_room', 'روم الإدارة', 'مجلس الإدارة العليا وتفويض الوكالات والمشرفين')
ON CONFLICT (id) DO NOTHING;

INSERT INTO room_seats (room_id, seat_index)
SELECT r.id, s.i
FROM rooms r
CROSS JOIN generate_series(0, 29) AS s(i)
ON CONFLICT (room_id, seat_index) DO NOTHING;
