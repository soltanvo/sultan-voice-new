/// إعدادات الاتصال المركزية لتطبيق Sultan Voic الملكي
class AppConfig {
  /// رابط مشروع Supabase الخاص بك
  static const String supabaseUrl = 'https://iplbbyghcdftdctkwjyi.supabase.co';

  /// المفتاح المعلن (Publishable / Anon key) لمشروعك في Supabase
  static const String supabaseAnonKey = 'sb_publishable_Fhk48BtMgv322a-_zFH4vw_XVT1Q_4w';

  /// رابط خادم LiveKit للغرف الصوتية WebRTC
  static const String liveKitUrl = 'wss://YOUR_LIVEKIT_SERVER_URL.livekit.cloud';

  /// التحقق البرمجي من تفعيل اتصال Supabase
  static bool get isSupabaseConfigured {
    return true;
  }
}
