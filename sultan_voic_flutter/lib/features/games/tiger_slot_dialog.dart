import 'dart:math';
import 'package:flutter/material.dart';

class TigerSlotDialog extends StatefulWidget {
  final int userCoins;
  final Function(int) onCoinsUpdated;

  const TigerSlotDialog({
    super.key,
    required this.userCoins,
    required this.onCoinsUpdated,
  });

  @override
  State<TigerSlotDialog> createState() => _TigerSlotDialogState();
}

class _TigerSlotDialogState extends State<TigerSlotDialog>
    with SingleTickerProviderStateMixin {
  final List<String> _symbols = ['🐯', '🧧', '🍊', '🪙', '💎', '🔥'];
  late List<List<String>> _grid;
  bool _isSpinning = false;
  int _bet = 200;
  String _message = "اضغط على زر تدوير لبدء مغامرة نمر الحظ!";
  int _lastWin = 0;

  @override
  void initState() {
    super.initState();
    _grid = List.generate(3, (_) => List.generate(3, (_) => '🐯'));
  }

  void _spin() {
    if (widget.userCoins < _bet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رصيد الكوينز غير كافٍ!')),
      );
      return;
    }

    setState(() {
      _isSpinning = true;
      _lastWin = 0;
      _message = "النمر الثائر يركض ويدور البكرات...";
    });
    widget.onCoinsUpdated(widget.userCoins - _bet);

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      final rnd = Random();
      final newGrid = List.generate(
        3,
        (_) => List.generate(3, (_) => _symbols[rnd.nextInt(_symbols.length)]),
      );

      // Check win on middle row
      int win = 0;
      if (newGrid[1][0] == newGrid[1][1] && newGrid[1][1] == newGrid[1][2]) {
        final sym = newGrid[1][0];
        final mult = sym == '🐯' ? 50 : (sym == '🔥' ? 20 : 10);
        win = _bet * mult;
      }

      setState(() {
        _grid = newGrid;
        _isSpinning = false;
        _lastWin = win;
        _message = win > 0
            ? "مبروك! فوز أسطوري بقيمة ${win} كوينز! 🎉"
            : "حظ أوفر في الجولة القادمة مع نمر الحظ!";
      });

      if (win > 0) {
        widget.onCoinsUpdated(widget.userCoins - _bet + win);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A0845), Color(0xFF6441A5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.amber, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/slot_tiger.png',
                        width: 28,
                        height: 28,
                        errorBuilder: (_, __, ___) => const Text('🐯', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'تايغر سلوت Fortune Tiger',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade700),
              ),
              child: Column(
                children: _grid.map((row) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: row.map((sym) {
                      return AnimatedScale(
                        duration: const Duration(milliseconds: 300),
                        scale: _isSpinning ? 0.8 : 1.0,
                        child: Text(
                          _isSpinning ? '🌀' : sym,
                          style: const TextStyle(fontSize: 36),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isSpinning ? null : _spin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _isSpinning ? 'جارٍ التدوير...' : 'تدوير الرهان ($_bet كوين)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
