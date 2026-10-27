import 'dart:math';
import 'package:flutter/material.dart';

class GreedyCatDialog extends StatefulWidget {
  const GreedyCatDialog({super.key});

  @override
  State<GreedyCatDialog> createState() => _GreedyCatDialogState();
}

class _GreedyCatDialogState extends State<GreedyCatDialog> {
  int _score = 5000;
  String _catMood = '🐱 إطعام القط الجشع سمكة ذهبية للحصول على مضاعفات!';
  int _lastMultiplier = 1;

  void _feedCat() {
    if (_score < 200) return;
    final random = Random();
    final multipliers = [0, 1, 2, 5, 10, 50];
    final mult = multipliers[random.nextInt(multipliers.length)];
    final won = 200 * mult;

    setState(() {
      _score = _score - 200 + won;
      _lastMultiplier = mult;
      if (mult == 0) {
        _catMood = '🙀 القط الجشع هرب بالسمكة! حظ أوفر!';
      } else if (mult >= 10) {
        _catMood = '😻 القط شبعان جداً وأعطاك كنز مضاعف x$mult!';
      } else {
        _catMood = '😸 القط مسرور! ربحت مضاعف x$mult!';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1B0F2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.orangeAccent)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/fortune_tiger.png',
                    width: 26,
                    height: 26,
                    errorBuilder: (_, __, ___) => const Text('🐱', style: TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'لعبة القط الجشع (Fortune Tiger)',
                  style: TextStyle(color: Colors.orangeAccent, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('الرصيد: $_score كوين 🐟', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            Text(_lastMultiplier > 5 ? '😻' : (_lastMultiplier == 0 ? '🙀' : '🐱'), style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 10),
            Text(_catMood, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.white)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.black),
              onPressed: _feedCat,
              child: const Text('أطعم القط (200 كوين)', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
