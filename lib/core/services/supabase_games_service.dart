import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

/// خدمة الألعاب الملكية وإدارة رصيد الكوينز المتصلة مباشرة بـ Supabase
class SupabaseGamesService extends ChangeNotifier {
  static final SupabaseGamesService _instance = SupabaseGamesService._internal();
  factory SupabaseGamesService() => _instance;
  SupabaseGamesService._internal();

  int _userCoins = 150000;
  bool _isLoading = false;
  String? _userId;

  int get userCoins => _userCoins;
  bool get isLoading => _isLoading;
  String? get userId => _userId;

  /// تهيئة رصيد المستخدم ومحاولة جلبه من Supabase
  Future<void> initUserBalance() async {
    if (!AppConfig.isSupabaseConfigured) return;

    try {
      _isLoading = true;
      notifyListeners();

      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      _userId = currentUser?.id ?? 'sultan_guest_1';

      // جلب رصيد الكوينز من جدول profiles إن وجد
      final response = await supabase
          .from('profiles')
          .select('coins')
          .eq('id', _userId!)
          .maybeSingle()
          .timeout(const Duration(seconds: 3));

      if (response != null && response['coins'] != null) {
        _userCoins = (response['coins'] as num).toInt();
        debugPrint('[SupabaseGamesService] تم تحميل الرصيد من Supabase: $_userCoins كوين');
      }
    } catch (e) {
      debugPrint('[SupabaseGamesService] ملاحظة: جاري استخدام الرصيد الملكي المحلي: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تنفيذ جولة رهان وفوز في أي لعبة وحفظ التغيير مباشرة في Supabase
  Future<bool> processGameBetAndWin({
    required String gameName,
    required int bet,
    required int winAmount,
    required int multiplier,
  }) async {
    if (_userCoins < bet) return false;

    // 1. تحديث الرصيد محلياً فوراً لمنح تجربة لعب سلسة وفورية 60 FPS
    _userCoins = _userCoins - bet + winAmount;
    notifyListeners();

    // 2. مزامنة التغيير مع قاعدة بيانات Supabase في الخلفية
    if (AppConfig.isSupabaseConfigured) {
      try {
        final supabase = Supabase.instance.client;
        final targetId = _userId ?? 'sultan_guest_1';

        await supabase.from('profiles').upsert({
          'id': targetId,
          'coins': _userCoins,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }).timeout(const Duration(seconds: 3));

        debugPrint('[SupabaseGamesService] تم تحديث الرصيد في Supabase إلى: $_userCoins');
      } catch (e) {
        debugPrint('[SupabaseGamesService] تعذر حفظ الجولة في Supabase: $e');
      }
    }

    return true;
  }

  /// إضافة كوينز يدوي / مكافأة يومية
  void addBonusCoins(int amount) {
    _userCoins += amount;
    notifyListeners();
  }
}
