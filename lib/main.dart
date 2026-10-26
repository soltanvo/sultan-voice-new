import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'core/services/livekit_service.dart';
import 'features/room/screens/royal_30_room_screen.dart';

/// رقم الإصدار الحالي المثبت على هذا الجهاز
const String kCurrentAppVersion = '1.0.0';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تثبيت الاتجاه الرأسي للغرف الصوتية
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // تهيئة Supabase
  await Supabase.initialize(
    url: 'https://YOUR_SUPABASE_PROJECT_ID.supabase.co',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LiveKitService()),
      ],
      child: const SultanVoicApp(),
    ),
  );
}

class SultanVoicApp extends StatelessWidget {
  const SultanVoicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sultan Voic - غرف 30 مقعد ملكية',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [
        Locale('ar', 'SA'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A071A),
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFB800), // ذهبي ملكي
          secondary: Color(0xFF9D4EDD), // بنفسجي ملكي
          surface: Color(0xFF140E2D),
        ),
      ),
      home: const SplashVersionCheckScreen(),
    );
  }
}

/// شاشة البداية الذكية: تفحص قاعدة بيانات Supabase للتحقق من وجود تحديث إجباري
class SplashVersionCheckScreen extends StatefulWidget {
  const SplashVersionCheckScreen({super.key});

  @override
  State<SplashVersionCheckScreen> createState() => _SplashVersionCheckScreenState();
}

class _SplashVersionCheckScreenState extends State<SplashVersionCheckScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAppVersion();
  }

  /// الاستعلام عن جدول app_versions من Supabase ومقارنة الإصدارات
  Future<void> _checkAppVersion() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('app_versions')
          .select()
          .order('id', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        final String minRequiredVersion = response['min_required_version'] ?? '1.0.0';
        final String latestVersion = response['latest_version'] ?? '1.0.0';
        final bool forceUpdate = response['force_update'] ?? false;
        final String downloadUrl = response['download_url'] ?? 'https://sultanvoic.com/download/latest.apk';
        final String updateTitle = response['update_title'] ?? 'تحديث إمبراطوري جديد متاح 👑';
        final List<dynamic> rawNotes = response['update_notes'] ?? [];
        final List<String> updateNotes = rawNotes.map((e) => e.toString()).toList();

        // هل الإصدار الحالي أقل من الأدنى المطلوب أم التحديث الإجباري مفعل للإصدارات الأقل؟
        final bool needsForcedUpdate = forceUpdate && _isVersionOlder(kCurrentAppVersion, minRequiredVersion);

        if (needsForcedUpdate && mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ForcedUpdateLockScreen(
                currentVersion: kCurrentAppVersion,
                latestVersion: latestVersion,
                minRequiredVersion: minRequiredVersion,
                downloadUrl: downloadUrl,
                updateTitle: updateTitle,
                updateNotes: updateNotes.isNotEmpty
                    ? updateNotes
                    : [
                        'إطلاق تأثير الصقر الأسود الملكي والأشعة المظلمة لـ SVIP 9',
                        'ترقية جودة الغرف الصوتية WebRTC Token 200 الفورية',
                        'إضافة عجلة الحظ الملكية (Lucky Wheel)',
                        'سد الثغرات وتحسين حماية واستقرار المجالس',
                      ],
              ),
            ),
          );
          return;
        }
      }

      // إذا كان الإصدار محدثاً، الانتقال المباشر للمجلس الملكي
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const Royal30RoomScreen(
              roomId: 'sultan_royal_room_1',
              roomTitle: 'مجلس Sultan Voic الملكي 👑',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('خطأ أثناء فحص إصدار التطبيق: $e');
      // في حالة تعذر الاتصال أو الخطأ، إعطاء الخيار للمستخدم بإعادة المحاولة
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'تعذر التحقق من ترخيص التحديث. تحقق من اتصال الإنترنت.';
        });
      }
    }
  }

  /// مقارنة إصدارين بصيغة SemVer بسيطة (مثال: 1.0.0 < 1.1.0)
  bool _isVersionOlder(String current, String required) {
    try {
      List<int> currentParts = current.split('.').map((e) => int.parse(e)).toList();
      List<int> requiredParts = required.split('.').map((e) => int.parse(e)).toList();

      for (int i = 0; i < 3; i++) {
        int c = i < currentParts.length ? currentParts[i] : 0;
        int r = i < requiredParts.length ? requiredParts[i] : 0;
        if (c < r) return true;
        if (c > r) return false;
      }
      return false;
    } catch (_) {
      return current != required;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A071A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // شعار التاج الإمبراطوري مع هالة الصقر الذهبي
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const RadialGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFB8860B), Color(0xFF140E2D)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFB800).withOpacity(0.35),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.shield_rounded, size: 52, color: Colors.black),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Sultan Voic',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'جاري التحقق من التحديثات الإمبراطورية...',
                style: TextStyle(fontSize: 13, color: Colors.white70),
              ),
              const SizedBox(height: 32),

              if (_isLoading)
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFFFFB800),
                  ),
                ),

              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _checkAppVersion,
                  icon: const Icon(Icons.refresh, color: Colors.black),
                  label: const Text(
                    'إعادة المحاولة',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB800),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // تجاوز في حالة عدم توفر إنترنت ومتابعة
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const Royal30RoomScreen(
                          roomId: 'sultan_royal_room_1',
                          roomTitle: 'مجلس Sultan Voic الملكي 👑',
                        ),
                      ),
                    );
                  },
                  child: const Text('المتابعة في وضع عدم الاتصال', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// شاشة القفل الملكية الإجبارية الفخمة (Forced Update Lock Screen)
/// تمنع المستخدم منعاً باتاً من الدخول وتمنع زر الرجوع في أندرويد
class ForcedUpdateLockScreen extends StatelessWidget {
  final String currentVersion;
  final String latestVersion;
  final String minRequiredVersion;
  final String downloadUrl;
  final String updateTitle;
  final List<String> updateNotes;

  const ForcedUpdateLockScreen({
    super.key,
    required this.currentVersion,
    required this.latestVersion,
    required this.minRequiredVersion,
    required this.downloadUrl,
    required this.updateTitle,
    required this.updateNotes,
  });

  Future<void> _launchDownloadUrl() async {
    final Uri uri = Uri.parse(downloadUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    // PopScope يمنع إغلاق الشاشة بالرجوع للخلف تماماً
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A071A),
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.4),
              radius: 1.1,
              colors: [
                Color(0xFF22133D), // بنفسجي ملكي مظلم
                Color(0xFF0F0B24),
                Color(0xFF060410),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const Spacer(),

                  // أيقونة درع الصقر الأسود والتحديث الملكي الفخم
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // هالة نارية ذهبية وسوداء متوهجة
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFB800).withOpacity(0.4),
                              blurRadius: 40,
                              spreadRadius: 8,
                            ),
                            BoxShadow(
                              color: const Color(0xFF9D4EDD).withOpacity(0.3),
                              blurRadius: 60,
                              spreadRadius: 12,
                            ),
                          ],
                        ),
                      ),
                      // الحاوية الأساسية للشعار الملكي
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFFD700), Color(0xFF8B6508), Color(0xFF140E2D)],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFFE57F), width: 2.5),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.system_update_alt_rounded,
                            size: 46,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      // شارة القفل الإجباري
                      Positioned(
                        bottom: 0,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFD90429),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black54, blurRadius: 4),
                            ],
                          ),
                          child: const Icon(Icons.lock_rounded, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // العنوان الرئيسي الملكي
                  Text(
                    updateTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(height: 8),

                  const Text(
                    'يتطلب الدخول إلى غرف Sultan Voic تثبيت أحدث ملف APK لضمان أمان الغرف ونقاء الصوت',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
                  ),
                  const SizedBox(height: 20),

                  // مقارنة أرقام الإصدارات
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1336),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFFB800).withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('إصدارك الحالي', style: TextStyle(color: Colors.white54, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text(
                              'v$currentVersion',
                              style: const TextStyle(
                                color: Color(0xFFEF233C),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_back_rounded, color: Color(0xFFFFB800), size: 18),
                        Column(
                          children: [
                            const Text('الإصدار الإجباري', style: TextStyle(color: Colors.white54, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text(
                              'v$latestVersion 👑',
                              style: const TextStyle(
                                color: Color(0xFF00F5D4),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // بطاقة مميزات التحديث الجديد
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF140E2D).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.stars_rounded, color: Color(0xFFFFB800), size: 18),
                              SizedBox(width: 8),
                              Text(
                                'مميزات التحديث الإمبراطوري الجديد:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...updateNotes.map(
                            (note) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('🦅 ', style: TextStyle(fontSize: 12)),
                                  Expanded(
                                    child: Text(
                                      note,
                                      style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // زر التحديث الإجباري الملكي الذهبي
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _launchDownloadUrl,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB800),
                        elevation: 8,
                        shadowColor: const Color(0xFFFFB800).withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.download_rounded, color: Colors.black, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'تحميل التحديث الجديد الآن (ملف APK)',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // زر إعادة التحقق بعد التثبيت
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const SplashVersionCheckScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white60),
                    label: const Text(
                      'أعد التحقق بعد تثبيت ملف الـ APK',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
