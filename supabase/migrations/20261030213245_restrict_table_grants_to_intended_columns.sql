/*
# Restrict table grants to intended columns

1. Summary
- Removes broad table-level write privileges that Supabase default permissions granted to the anon and authenticated roles on profiles, rooms and room_seats.
- Restores column-only write access that the app actually needs.

2. Security changes
- profiles: authenticated may read rows (RLS limits to own row) and update display_name only. Coins can no longer be edited from the client.
- room_seats: authenticated may read; may update user_id, display_name and is_muted only (is_locked can no longer be changed by users).
- rooms: authenticated may read only.
- anon has no privileges on these tables.

3. Notes
- Coin changes go through SECURITY DEFINER functions, which run with owner rights and are not affected by these grants.
*/

REVOKE ALL ON profiles FROM anon, authenticated;
REVOKE ALL ON rooms FROM anon, authenticated;
REVOKE ALL ON room_seats FROM anon, authenticated;

GRANT SELECT ON profiles TO authenticated;
GRANT UPDATE (display_name) ON profiles TO authenticated;
GRANT SELECT ON rooms TO authenticated;
GRANT SELECT ON room_seats TO authenticated;
GRANT UPDATE (user_id, display_name, is_muted) ON room_seats TO authenticated;
