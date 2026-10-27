/// إعدادات الاتصال المركزية لتطبيق Sultan Voic الملكي
/// يمكنك إدخال بيانات مشروع Supabase الخاص بك هنا.
/// إذا بقيت القيم افتراضية أو فارغة، سيعمل التطبيق بسلاسة تامة في الوضع المستقل التلقائي.
class AppConfig {
  /// رابط مشروع Supabase الخاص بك (من إعدادات المشروع في Supabase > API)
  /// مثال: https://xyzcompany.supabase.co
  static const String supabaseUrl = 'https://YOUR_SUPABASE_PROJECT_ID.supabase.co';

  /// المفتاح المجهول (anon public key) لمشروعك في Supabase
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  /// رابط خادم LiveKit للغرف الصوتية WebRTC
  /// مثال: wss://sultan-voice-livekit.livekit.cloud
  static const String liveKitUrl = 'wss://YOUR_LIVEKIT_SERVER_URL.livekit.cloud';

  /// التحقق البرمجي مما إذا كانت بيانات Supabase حقيقية وليست قيماً افتراضية
  static bool get isSupabaseConfigured {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) return false;
    if (supabaseUrl.contains('YOUR_SUPABASE_PROJECT_ID')) return false;
    if (supabaseAnonKey.contains('YOUR_SUPABASE_ANON_KEY')) return false;
    if (!supabaseUrl.startsWith('https://')) return false;
    return true;
  }
}
