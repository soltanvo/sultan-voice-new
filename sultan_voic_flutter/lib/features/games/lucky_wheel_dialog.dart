import 'dart:math';
import 'package:flutter/material.dart';

class LuckyWheelDialog extends StatefulWidget {
  const LuckyWheelDialog({super.key});

  @override
  State<LuckyWheelDialog> createState() => _LuckyWheelDialogState();
}

class _LuckyWheelDialogState extends State<LuckyWheelDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentAngle = 0;
  int _userCoins = 10000;
  bool _isSpinning = false;
  String? _winMessage;

  final List<String> _rewards = [
    '500 كوين 🪙',
    'تاج الملوك 👑',
    '200 كوين 🪙',
    'تجربة SVIP 🌟',
    '1,000 كوين 🪙',
    'سيارة خارقة 🏎️',
    '100 كوين 🪙',
    'جاكبوت 10K 🔥',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spin() {
    if (_userCoins < 100 || _isSpinning) return;
    setState(() {
      _isSpinning = true;
      _userCoins -= 100;
      _winMessage = null;
    });

    final random = Random();
    final winningIndex = random.nextInt(_rewards.length);
    final turns = 5 + random.nextDouble();
    final targetAngle = _currentAngle + (turns * 2 * pi);

    _animation = Tween<double>(begin: _currentAngle, end: targetAngle).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCirc),
    )..addListener(() {
        setState(() {});
      })..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _currentAngle = targetAngle % (2 * pi);
          setState(() {
            _isSpinning = false;
            _winMessage = 'مبروك! فزت بـ ${_rewards[winningIndex]} 🎉';
          });
        }
      });

    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF140D2B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFFFB800), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🎡', style: TextStyle(fontSize: 24)),
                SizedBox(width: 8),
                Text(
                  'عجلة الحظ الملكية (Sultan Voic)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFFFB800)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('الرصيد: $_userCoins كوين 🪙', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: _animation.value,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const SweepGradient(
                        colors: [
                          Colors.amber,
                          Colors.purple,
                          Colors.blue,
                          Colors.deepOrange,
                          Colors.amber,
                        ],
                      ),
                      border: Border.all(color: const Color(0xFFFFB800), width: 3),
                    ),
                    child: const Center(
                      child: Text('👑', style: TextStyle(fontSize: 32)),
                    ),
                  ),
                ),
                const Positioned(
                  top: 0,
                  child: Icon(Icons.arrow_drop_down, color: Colors.white, size: 36),
                ),
              ],
            ),
            if (_winMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _winMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFFFB800), fontWeight: FontWeight.bold),
              ),
            ],
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB800),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: _isSpinning ? null : _spin,
              child: Text(
                _isSpinning ? 'جاري التدوير...' : 'تدوير العجلة (100 كوين)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
