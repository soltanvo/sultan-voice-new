import { AccessToken } from "npm:livekit-server-sdk@2.9.0";
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

const jsonResponse = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 200, headers: corsHeaders });
  }

  try {
    const apiKey = Deno.env.get("LIVEKIT_API_KEY");
    const apiSecret = Deno.env.get("LIVEKIT_API_SECRET");
    if (!apiKey || !apiSecret) {
      return jsonResponse({ error: "voice_not_configured" }, 503);
    }

    const authHeader = req.headers.get("Authorization") ?? "";
    const { roomId } = await req.json();
    if (typeof roomId !== "string" || roomId.length === 0) {
      return jsonResponse({ error: "invalid_room" }, 400);
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } },
    );

    const { data: userData, error: userError } = await supabase.auth.getUser();
    if (userError || !userData.user) {
      return jsonResponse({ error: "unauthorized" }, 401);
    }
    const uid = userData.user.id;

    const { data: seat, error: seatError } = await supabase
      .from("room_seats")
      .select("seat_index")
      .eq("room_id", roomId)
      .eq("user_id", uid)
      .maybeSingle();
    if (seatError) {
      return jsonResponse({ error: "seat_lookup_failed" }, 500);
    }
    if (!seat) {
      return jsonResponse({ error: "not_seated" }, 403);
    }

    const { data: profile } = await supabase
      .from("profiles")
      .select("display_name")
      .eq("id", uid)
      .maybeSingle();

    const token = new AccessToken(apiKey, apiSecret, {
      identity: uid,
      name: profile?.display_name ?? "عضو",
      ttl: "1h",
    });
    token.addGrant({
      roomJoin: true,
      room: roomId,
      canPublish: true,
      canSubscribe: true,
    });

    return jsonResponse({ token: await token.toJwt() });
  } catch (err) {
    console.error("[livekit-token]", err);
    return jsonResponse({ error: "internal_error" }, 500);
  }
});
