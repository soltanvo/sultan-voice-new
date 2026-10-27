import 'dart:math';
import 'package:flutter/material.dart';

class DragonTreasureDialog extends StatefulWidget {
  final int userCoins;
  final Function(int) onCoinsUpdated;

  const DragonTreasureDialog({
    super.key,
    required this.userCoins,
    required this.onCoinsUpdated,
  });

  @override
  State<DragonTreasureDialog> createState() => _DragonTreasureDialogState();
}

class _DragonTreasureDialogState extends State<DragonTreasureDialog> {
  final List<int> _multipliers = [2, 5, 10, 20, 50, 100, 3, 8, 15];
  List<bool> _opened = List.filled(9, false);
  final int _cost = 300;

  void _openChest(int index) {
    if (_opened[index] || widget.userCoins < _cost) return;

    final mult = _multipliers[index];
    final win = _cost * mult;

    setState(() {
      _opened[index] = true;
    });

    widget.onCoinsUpdated(widget.userCoins - _cost + win);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1B002B),
        title: const Text('🐉 كنز التنين الأسطوري!', style: TextStyle(color: Colors.amber)),
        content: Text(
          'مبروك! حصلت على مضاعف x$mult وفزت بـ $win كوينز!',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('استلام', style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A0E17), Color(0xFF1A0B2E)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.orange, width: 2),
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
                        'assets/images/fortune_dragon.png',
                        width: 28,
                        height: 28,
                        errorBuilder: (_, __, ___) => const Text('🐉', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'كنوز التنين Dragon Treasure',
                      style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 9,
              itemBuilder: (ctx, i) {
                return InkWell(
                  onTap: () => _openChest(i),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _opened[i] ? Colors.amber.withOpacity(0.2) : Colors.black45,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _opened[i] ? Colors.amber : Colors.orange.shade700,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _opened[i] ? 'x${_multipliers[i]}' : '📦',
                      style: TextStyle(
                        fontSize: _opened[i] ? 18 : 28,
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              'اختر صندوقاً لكشف كنز التنين (تكلفة الفتح: $_cost كوين)',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
