/*
# Create gift catalog, gift transactions and send_gift function

1. New Tables
- gifts: catalog of gift items.
  - id (uuid, primary key)
  - name (text, not null)
  - price_coins (integer, > 0)
  - icon_key (text, key the app uses to pick the icon)
  - created_at (timestamptz)
- gift_transactions: log of every gift sent.
  - id, sender_id, recipient_id, room_id, seat_index, gift_id, coins_spent, created_at

2. Functions
- send_gift(room_id, seat_index, gift_id): checks the seat is occupied by another user, checks the sender has enough coins, deducts the price from the sender's balance, writes a gift_transactions row and returns the sender's new balance. Runs in a single step so coins can never go negative or be double-spent.

3. Security
- gifts: RLS on; authenticated can read the catalog (intentionally shared). No client writes.
- gift_transactions: RLS on; authenticated can read only rows where they are sender or recipient. No client insert/update/delete; rows are only written by send_gift.
- send_gift: executable by authenticated only.

4. Seed data
- Six starter gifts are inserted only if the catalog is empty.
*/

CREATE TABLE IF NOT EXISTS gifts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  price_coins integer NOT NULL CHECK (price_coins > 0),
  icon_key text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS gift_transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  recipient_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  room_id text NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  seat_index integer NOT NULL CHECK (seat_index BETWEEN 0 AND 29),
  gift_id uuid NOT NULL REFERENCES gifts(id),
  coins_spent integer NOT NULL CHECK (coins_spent > 0),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS gift_transactions_sender_idx ON gift_transactions (sender_id);
CREATE INDEX IF NOT EXISTS gift_transactions_recipient_idx ON gift_transactions (recipient_id);

ALTER TABLE gifts ENABLE ROW LEVEL SECURITY;
ALTER TABLE gift_transactions ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON gifts FROM anon, authenticated;
REVOKE ALL ON gift_transactions FROM anon, authenticated;
GRANT SELECT ON gifts TO authenticated;
GRANT SELECT ON gift_transactions TO authenticated;

DROP POLICY IF EXISTS "select_gift_catalog" ON gifts;
CREATE POLICY "select_gift_catalog" ON gifts FOR SELECT
  TO authenticated USING (true);

DROP POLICY IF EXISTS "select_own_gift_transactions" ON gift_transactions;
CREATE POLICY "select_own_gift_transactions" ON gift_transactions FOR SELECT
  TO authenticated USING (auth.uid() = sender_id OR auth.uid() = recipient_id);

INSERT INTO gifts (name, price_coins, icon_key)
SELECT v.name, v.price_coins, v.icon_key
FROM (VALUES
  ('Rose', 10, 'rose'),
  ('Heart', 50, 'heart'),
  ('Star', 100, 'star'),
  ('Crown', 500, 'crown'),
  ('Diamond', 1000, 'diamond'),
  ('Rocket', 5000, 'rocket')
) AS v(name, price_coins, icon_key)
WHERE NOT EXISTS (SELECT 1 FROM gifts);

CREATE OR REPLACE FUNCTION public.send_gift(p_room_id text, p_seat_index integer, p_gift_id uuid)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_sender uuid := auth.uid();
  v_recipient uuid;
  v_price integer;
  v_balance integer;
BEGIN
  IF v_sender IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  SELECT price_coins INTO v_price FROM gifts WHERE id = p_gift_id;
  IF v_price IS NULL THEN
    RAISE EXCEPTION 'gift_not_found';
  END IF;

  SELECT user_id INTO v_recipient
  FROM room_seats
  WHERE room_id = p_room_id AND seat_index = p_seat_index;
  IF v_recipient IS NULL THEN
    RAISE EXCEPTION 'seat_empty';
  END IF;
  IF v_recipient = v_sender THEN
    RAISE EXCEPTION 'self_gift';
  END IF;

  UPDATE profiles
  SET coins = coins - v_price
  WHERE id = v_sender AND coins >= v_price
  RETURNING coins INTO v_balance;
  IF v_balance IS NULL THEN
    RAISE EXCEPTION 'insufficient_coins';
  END IF;

  INSERT INTO gift_transactions (sender_id, recipient_id, room_id, seat_index, gift_id, coins_spent)
  VALUES (v_sender, v_recipient, p_room_id, p_seat_index, p_gift_id, v_price);

  RETURN v_balance;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.send_gift(text, integer, uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.send_gift(text, integer, uuid) TO authenticated;
