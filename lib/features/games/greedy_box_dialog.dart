import 'dart:math';
import 'package:flutter/material.dart';

class GreedyBoxDialog extends StatefulWidget {
  final int userCoins;
  final Function(int) onCoinsUpdated;

  const GreedyBoxDialog({
    super.key,
    required this.userCoins,
    required this.onCoinsUpdated,
  });

  @override
  State<GreedyBoxDialog> createState() => _GreedyBoxDialogState();
}

class _GreedyBoxDialogState extends State<GreedyBoxDialog> {
  final List<int> _boxValues = [100, 500, 2000, 5000, 10000];
  bool _opening = false;
  String _result = "اختر أحد الصناديق الثلاثة لتجربة حظك الملكي!";

  void _pickBox(int boxNumber) {
    const cost = 250;
    if (widget.userCoins < cost) return;

    setState(() {
      _opening = true;
      _result = "جارٍ فتح الصندوق رقم $boxNumber...";
    });

    widget.onCoinsUpdated(widget.userCoins - cost);

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      final win = _boxValues[Random().nextInt(_boxValues.length)];
      widget.onCoinsUpdated(widget.userCoins - cost + win);

      setState(() {
        _opening = false;
        _result = "مبروك! فتحت الصندوق وفزت بـ $win كوينز! 🎁";
      });
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
            colors: [Color(0xFF3B0066), Color(0xFF120024)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.purpleAccent, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/greedy_box.png',
                        width: 28,
                        height: 28,
                        errorBuilder: (_, __, ___) => const Text('🎁', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'جريدي بوكس Greedy Box',
                      style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [1, 2, 3].map((num) {
                return InkWell(
                  onTap: _opening ? null : () => _pickBox(num),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.purpleAccent),
                    ),
                    child: Column(
                      children: [
                        Text(_opening ? '⏳' : '🎁', style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 4),
                        Text('صندوق $num', style: const TextStyle(color: Colors.white, fontSize: 11)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              _result,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
