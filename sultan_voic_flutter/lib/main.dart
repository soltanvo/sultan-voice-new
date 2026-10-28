import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/app_config.dart';
import 'core/services/telecom_warmup_service.dart';
import 'core/services/supabase_games_service.dart';
import 'core/services/livekit_service.dart';
import 'features/auth/screens/royal_auth_screen.dart';
import 'features/room/screens/royal_30_room_screen.dart';

/// رقم الإصدار الحالي المثبت على هذا الجهاز
const String kCurrentAppVersion = '1.0.0';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تثبيت الاتجاه الرأسي للغرف الصوتية
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // تشغيل روتين تسخين عناوين الشبكة لتجاوز قيود الاتصالات العالمية (Telecom Warmup)
  unawaited(TelecomWarmupService().warmupGlobalEndpoints());
  
  // تهيئة Supabase بأمان تام
  if (AppConfig.isSupabaseConfigured) {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      );
      debugPrint('[Supabase] تم الاتصال بنجاح بسيرفر Supabase');
    } catch (e) {
      debugPrint('[Supabase Init Notice]: $e');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LiveKitService()),
        ChangeNotifierProvider(create: (_) => SupabaseGamesService()..initUserBalance()),
      ],
      child: const SultanVoicApp(),
    ),
  );
}

void unawaited(Future<void> future) {}

class SultanVoicApp extends StatelessWidget {
  const SultanVoicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sultan Voic - غرف صوتية ملكية',
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
        scaffoldBackgroundColor: const Color(0xFF070314),
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFB800), // ذهبي ملكي
          secondary: Color(0xFF9D4EDD), // بنفسجي ملكي
          surface: Color(0xFF140E2D),
        ),
      ),
      home: const RoyalSplashScreen(),
    );
  }
}

/// شاشة البداية الملكية الفاخرة الكاملة (Full Screen Splash)
/// تسخين شبكة الاتصالات العالمية + التحقق الآمن من جلسة الدخول
class RoyalSplashScreen extends StatefulWidget {
  const RoyalSplashScreen({super.key});

  @override
  State<RoyalSplashScreen> createState() => _RoyalSplashScreenState();
}

class _RoyalSplashScreenState extends State<RoyalSplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fadeAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );
    _fadeController.forward();
    _startSecureFlow();
  }

  Future<void> _startSecureFlow() async {
    // 1. تشغيل روتين تسخين عناوين الاتصالات العالمية وتفادي الحجب
    await TelecomWarmupService().warmupGlobalEndpoints();

    // 2. عرض شاشة البداية الفخمة لمدة ثانيتين
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    // 3. التحقق من وجود جلسة دخول نشطة في Supabase
    bool hasActiveSession = false;
    try {
      if (AppConfig.isSupabaseConfigured) {
        final session = Supabase.instance.client.auth.currentSession;
        hasActiveSession = session != null;
      }
    } catch (_) {
      hasActiveSession = false;
    }

    if (!mounted) return;

    // 4. إذا كانت الجلسة موجودة -> الانتقال المباشر لغرفة خدمة العملاء الرسمية
    // إذا لم تكن موجودة -> الانتقال لشاشة تسجيل الدخول الملكية
    final Widget targetScreen = hasActiveSession
        ? const Royal30RoomScreen(
            roomId: 'customer_service_room',
            roomTitle: 'غرفة خدمة العملاء الرسمية 👑',
          )
        : const RoyalAuthScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (_, __, ___) => targetScreen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070314),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // الصورة الملكية الكاملة لشعار سلطان الذهبي المتوهج
          FadeTransition(
            opacity: _fadeAnimation,
            child: Image.asset(
              'assets/images/sultan_splash_bg.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0, -0.2),
                      radius: 1.3,
                      colors: [
                        Color(0xFF261047),
                        Color(0xFF100624),
                        Color(0xFF05020C),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'سلطان 👑',
                      style: TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // مؤشر التحميل الذهبي وتسخين الشبكة العالمية
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.5),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'تسريع الاتصال والتحقق الملكي...',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
