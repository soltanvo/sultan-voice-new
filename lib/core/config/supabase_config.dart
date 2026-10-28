import 'app_config.dart';

/// إعدادات الاتصال بـ Supabase (Supabase Configuration)
class SupabaseConfig {
  static String get url => AppConfig.supabaseUrl;
  static String get anonKey => AppConfig.supabaseAnonKey;
  static bool get isConfigured => AppConfig.isSupabaseConfigured;
}
