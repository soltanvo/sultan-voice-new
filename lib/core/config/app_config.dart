/// إعدادات الاتصال المركزية لتطبيق Sultan Voic الملكي
class AppConfig {
  /// رابط مشروع Supabase الفعلي أو رابط البروكسي (Cloudflare Worker Proxy)
  static const String supabaseUrl = 'https://iplbbyghcdftdctkwjyi.supabase.co';

  /// المفتاح المعلن (Publishable / Anon key) لمشروعك في Supabase
  static const String supabaseAnonKey = 'sb_publishable_Fhk48BtMgv322a-_zFH4vw_XVT1Q_4w';

  /// رابط خادم LiveKit للغرف الصوتية WebRTC
  static const String liveKitUrl = 'wss://soltan1-7mmq7vfh.livekit.cloud';

  /// التحقق البرمجي الآمن من صلاحية الرابط لتفادي أي انهيار للتطبيق
  static bool get isSupabaseConfigured {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) return false;
    if (supabaseUrl == 'https://supabase.co') return false;
    if (supabaseUrl.contains('YOUR_SUPABASE_PROJECT_ID')) return false;
    if (supabaseUrl.contains('[') || supabaseUrl.contains('ضع_رابط')) return false;
    if (!supabaseUrl.startsWith('https://')) return false;
    return true;
  }
}
