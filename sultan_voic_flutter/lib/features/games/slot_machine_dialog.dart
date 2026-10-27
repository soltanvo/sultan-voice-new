import 'dart:math';
import 'package:flutter/material.dart';

class SlotMachineDialog extends StatefulWidget {
  const SlotMachineDialog({super.key});

  @override
  State<SlotMachineDialog> createState() => _SlotMachineDialogState();
}

class _SlotMachineDialogState extends State<SlotMachineDialog> {
  final List<String> _symbols = ['👑', '💎', '7️⃣', '🍒', '🔔', '⭐'];
  late List<String> _currentReels;
  bool _isSpinning = false;
  int _userCoins = 10000;
  String? _winMessage;

  @override
  void initState() {
    super.initState();
    _currentReels = ['👑', '💎', '7️⃣'];
  }

  void _spin() async {
    if (_userCoins < 100) return;
    setState(() {
      _isSpinning = true;
      _userCoins -= 100;
      _winMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 900));

    final random = Random();
    final r1 = _symbols[random.nextInt(_symbols.length)];
    final r2 = _symbols[random.nextInt(_symbols.length)];
    final r3 = _symbols[random.nextInt(_symbols.length)];

    int win = 0;
    if (r1 == r2 && r2 == r3) {
      win = 5000;
    } else if (r1 == r2 || r2 == r3 || r1 == r3) {
      win = 300;
    }

    setState(() {
      _currentReels = [r1, r2, r3];
      _userCoins += win;
      _isSpinning = false;
      if (win > 0) {
        _winMessage = 'مبروك! ربحت $win كوين ملكي 🎉';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF160B30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.amber, width: 2)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.casino, color: Colors.amber),
                SizedBox(width: 8),
                Text('سلوت Voic الملكي 777', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.amber)),
              ],
            ),
            const SizedBox(height: 12),
            Text('رصيدك: $_userCoins كوين 🪙', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _currentReels.map((s) => Text(s, style: const TextStyle(fontSize: 44))).toList(),
              ),
            ),
            if (_winMessage != null) ...[
              const SizedBox(height: 12),
              Text(_winMessage!, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            ],
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: _isSpinning ? null : _spin,
              child: Text(_isSpinning ? 'جاري اللف...' : 'تدوير (100 كوين)', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
