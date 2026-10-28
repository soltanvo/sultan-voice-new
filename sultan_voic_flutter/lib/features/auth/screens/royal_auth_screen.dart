import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/app_config.dart';
import '../../room/screens/royal_30_room_screen.dart';

class RoyalAuthScreen extends StatefulWidget {
  const RoyalAuthScreen({super.key});

  @override
  State<RoyalAuthScreen> createState() => _RoyalAuthScreenState();
}

class _RoyalAuthScreenState extends State<RoyalAuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToRoom() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const Royal30RoomScreen(
          roomId: 'customer_service_room',
          roomTitle: 'غرفة خدمة العملاء الرسمية 👑',
        ),
      ),
    );
  }

  Future<void> _submitAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'يرجى إدخال البريد الإلكتروني وكلمة المرور');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (AppConfig.isSupabaseConfigured) {
        final supabase = Supabase.instance.client;
        if (_isSignUp) {
          await supabase.auth.signUp(
            email: email,
            password: password,
          );
        } else {
          await supabase.auth.signInWithPassword(
            email: email,
            password: password,
          );
        }
      }
      _navigateToRoom();
    } catch (e) {
      debugPrint('[Auth Notice]: $e');
      setState(() {
        _errorMessage = 'تعذر تسجيل الدخول بالسيرفر. يمكنك استخدام الدخول السريع كضيف.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _guestLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (AppConfig.isSupabaseConfigured) {
        final supabase = Supabase.instance.client;
        try {
          await supabase.auth.signInAnonymously();
        } catch (_) {
          // استمرار فوري كضيف ملكي
        }
      }
    } catch (_) {
      // استمرار فوري
    } finally {
      if (mounted) {
        _navigateToRoom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070314),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.4),
            radius: 1.3,
            colors: [
              Color(0xFF28114B),
              Color(0xFF100624),
              Color(0xFF05020C),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // الشعار الملكي
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFB8860B), Color(0xFF140E2D)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFB800).withOpacity(0.35),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFFFD700), width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.workspace_premium_rounded, size: 48, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    'Sultan Voic',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFFD700),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isSignUp ? 'إنشاء حساب ملكي جديد 👑' : 'تسجيل الدخول إلى المجالس الملكية 👑',
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(height: 24),

                  // رسالة الخطأ
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.6)),
                      ),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // حقل البريد
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF140B30),
                      hintText: 'البريد الإلكتروني',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFFFD700)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0x33FFD700)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // حقل كلمة المرور
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF140B30),
                      hintText: 'كلمة المرور',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFFD700)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0x33FFD700)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // زر تسجيل الدخول الأساسي
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 6,
                      ),
                      onPressed: _isLoading ? null : _submitAuth,
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.black),
                            )
                          : Text(
                              _isSignUp ? 'إنشاء حساب جديد' : 'دخول المجلس',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // زر الدخول السريع كزائر
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFFD700),
                        side: const BorderSide(color: Color(0xFFFFD700), width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.flash_on_rounded, size: 20),
                      label: const Text(
                        'دخول فوري كضيف ملكي ⚡',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      onPressed: _isLoading ? null : _guestLogin,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // التبديل بين تسجيل ودخول
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isSignUp = !_isSignUp;
                        _errorMessage = null;
                      });
                    },
                    child: Text(
                      _isSignUp ? 'لديك حساب بالفعل؟ تسجيل الدخول' : 'ليس لديك حساب؟ إنشاء حساب ملكي',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
