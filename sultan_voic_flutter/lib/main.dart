import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/app_config.dart';
import 'core/services/supabase_games_service.dart';
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
  
  // تهيئة Supabase مباشرة بالسيرفر الفعلي
  try {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    debugPrint('[Supabase] تم الاتصال بنجاح بسيرفر Supabase');
  } catch (e) {
    debugPrint('[Supabase Init Notice]: $e');
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
      home: const RoyalSplashScreen(),
    );
  }
}

/// شاشة البداية الملكية الفاخرة: انتقال سلس وفوري للغرفة بدون أي حجب أو قيود
class RoyalSplashScreen extends StatefulWidget {
  const RoyalSplashScreen({super.key});

  @override
  State<RoyalSplashScreen> createState() => _RoyalSplashScreenState();
}

class _RoyalSplashScreenState extends State<RoyalSplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // انتظار ثانية واحدة لعرض الشعار الملكي الأنيق ثم الانتقال المباشر
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => const Royal30RoomScreen(
            roomId: 'sultan_royal_room_1',
            roomTitle: 'مجلس Sultan Voic الملكي 👑',
          ),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070314),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.3,
            colors: [
              Color(0xFF261047), // بنفسجي ملكي عميق
              Color(0xFF100624),
              Color(0xFF05020C), // أسود أوبسيديان
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الشعار الملكي المتحرك
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: const RadialGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFB8860B), Color(0xFF140E2D)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFB800).withOpacity(0.4),
                        blurRadius: 36,
                        spreadRadius: 6,
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFFFD700), width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.workspace_premium_rounded, size: 60, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // العنوان الملكي
              const Text(
                'Sultan Voic',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFFD700),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),

              // النص الترحيبي
              const Text(
                'مرحباً بك في المجالس الملكية 👑',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 36),

              // مؤشر التحميل الأنيق
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFFFFB800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
