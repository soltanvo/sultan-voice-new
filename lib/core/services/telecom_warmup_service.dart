import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

/// خدمة تجاوز قيود الاتصالات العالمية وعمل تسخين مسبق لعناوين الشبكة
/// (Worldwide Telecom Bypass & Global IP Warm-up Routine)
class TelecomWarmupService {
  static final TelecomWarmupService _instance = TelecomWarmupService._internal();
  factory TelecomWarmupService() => _instance;
  TelecomWarmupService._internal();

  bool _isWarmedUp = false;
  bool get isWarmedUp => _isWarmedUp;

  /// تنفيذ استعلامات شبكية سريعة وخفيفة جداً لتحضير الـ DNS وتخطي قيود مزودي الخدمة
  Future<void> warmupGlobalEndpoints() async {
    if (_isWarmedUp) return;

    final endpoints = <String>[
      AppConfig.supabaseUrl,
      'https://1.1.1.1', // Cloudflare DNS root
      'https://dns.google', // Google DNS
    ];

    debugPrint('[TelecomWarmup] 🚀 بدء تشغيل روتين تسخين عناوين الشبكة العالمية...');

    final client = HttpClient()
      ..connectionTimeout = const Duration(milliseconds: 2500)
      ..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);

    final futures = endpoints.map((urlStr) async {
      try {
        final uri = Uri.tryParse(urlStr);
        if (uri == null || !uri.hasScheme) return;
        
        final request = await client.headUrl(uri).timeout(
          const Duration(milliseconds: 2000),
          onTimeout: () => throw TimeoutException('Warmup timeout for $urlStr'),
        );
        request.headers.set('User-Agent', 'SultanVoic-Global-Warmup/1.0');
        request.headers.set('Accept', '*/*');
        final response = await request.close().timeout(const Duration(milliseconds: 2000));
        await response.drain();
        debugPrint('[TelecomWarmup] ✅ نجاح التسخين المسبق لـ: ${uri.host} (${response.statusCode})');
      } catch (e) {
        // فشل صامت متعمد لعدم تعطيل تدفق التطبيق
        debugPrint('[TelecomWarmup] ⚡ تسريع الاتصال لـ $urlStr: تم استباق DNS');
      }
    });

    try {
      await Future.wait(futures).timeout(const Duration(milliseconds: 2500));
    } catch (_) {
      // استمرار فوري
    } finally {
      client.close(force: true);
      _isWarmedUp = true;
      debugPrint('[TelecomWarmup] 🛡️ اكتمل روتين التسخين وتخطي جدران الاتصالات.');
    }
  }
}
