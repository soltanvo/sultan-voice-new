import 'dart:math';
import 'package:flutter/material.dart';

enum OfficialGameType {
  slotTiger,
  fortuneDragon,
  greedyBox,
  zeus,
  luck77,
  mahjongWays2,
  queenOfBounty,
}

class OfficialGamesHubDialog extends StatefulWidget {
  final OfficialGameType initialGame;
  const OfficialGamesHubDialog({
    super.key,
    this.initialGame = OfficialGameType.slotTiger,
  });

  @override
  State<OfficialGamesHubDialog> createState() => _OfficialGamesHubDialogState();
}

class _OfficialGamesHubDialogState extends State<OfficialGamesHubDialog> {
  late OfficialGameType _selectedGame;
  int _userCoins = 25000;
  int _bet = 200;
  bool _isSpinning = false;
  String? _winMessage;

  // Games definitions with exact English names, real assets paths & strict descriptions
  final Map<OfficialGameType, Map<String, dynamic>> _gamesMeta = {
    OfficialGameType.slotTiger: {
      'order': 1,
      'name': 'Slot Tiger',
      'arabicName': 'تايغر سلوت',
      'icon': '🐯',
      'asset': 'assets/images/slot_tiger.png',
      'tag': 'نمر كرتوني يرتدي زي صيني أحمر ويمسك ظرفاً أحمراً وتحته كود/نص Slot Tiger',
      'symbols': ['🐯', '🧧', '🪙', '🏮', '👑', '💎'],
      'color': const Color(0xFFEA580C),
    },
    OfficialGameType.fortuneDragon: {
      'order': 2,
      'name': 'Fortune Dragon',
      'arabicName': 'كنوز التنين',
      'icon': '🐉',
      'asset': 'assets/images/fortune_dragon.png',
      'tag': 'تنين صيني أخضر ضاحك وتحته نص Fortune Dragon',
      'symbols': ['🐉', '🥚', '💎', '🪙', '👑', '🔥'],
      'color': const Color(0xFFDC2626),
    },
    OfficialGameType.greedyBox: {
      'order': 3,
      'name': 'Greedy Box',
      'arabicName': 'صندوق الجشع',
      'icon': '🎁',
      'asset': 'assets/images/greedy_box.png',
      'tag': 'محارب صيني أسطوري بأسلحة ذهبية وصندوق كنز خلفه مع نص GREEDY BOX',
      'symbols': ['🎁', '🗝️', '💎', '⚔️', '🪙', '👑'],
      'color': const Color(0xFF9333EA),
    },
    OfficialGameType.zeus: {
      'order': 4,
      'name': 'Zeus',
      'arabicName': 'لعبة زيوس / آلهة الأولمب',
      'icon': '⚡',
      'asset': 'assets/images/gates_of_olympus.png',
      'tag': 'شخصية زيوس بشعر ودقن بيضاء مع صاعقة وبكرات اللعبة بها مجوهرات وكؤوس ذهبية',
      'symbols': ['⚡', '🔮', '👑', '🏺', '💍', '⏳'],
      'color': const Color(0xFF2563EB),
    },
    OfficialGameType.luck77: {
      'order': 5,
      'name': 'Luck 77',
      'arabicName': 'حظ 77',
      'icon': '🎰',
      'asset': 'assets/images/luck_77.png',
      'tag': 'واجهة العرض بنجم وردي وكتابة LUCK 77 أو عجلة الفواكه الملونة بالرقم 77',
      'symbols': ['7️⃣', '💎', '🔔', '🍒', '🍀', '👑'],
      'color': const Color(0xFFFBBF24),
    },
    OfficialGameType.mahjongWays2: {
      'order': 6,
      'name': 'Mahjong Ways 2',
      'arabicName': 'ماجونغ وايز 2',
      'icon': '🀄',
      'asset': 'assets/images/mahjong_ways_2.png',
      'tag': 'قطع أحجار لعبة الماجونغ الصينية مع تنين ذهبي ونص MAHJONG WAYS 2',
      'symbols': ['🀄', '🀅', '🀆', '🪙', '🐉', '🏮'],
      'color': const Color(0xFF10B981),
    },
    OfficialGameType.queenOfBounty: {
      'order': 7,
      'name': 'Queen of Bounty',
      'arabicName': 'ملكة المكافآت',
      'icon': '🏴‍☠️',
      'asset': 'assets/images/queen_of_bounty.png',
      'tag': 'فتاة قرصانة بشعر أحمر وتضع غطاءً على عينها مع سفينة ومدافع بحرية',
      'symbols': ['🏴‍☠️', '👑', '💎', '⚔️', '🗺️', '🪙'],
      'color': const Color(0xFFD97706),
    },
  };

  @override
  void initState() {
    super.initState();
    _selectedGame = widget.initialGame;
  }

  void _spin() async {
    if (_userCoins < _bet || _isSpinning) return;
    setState(() {
      _isSpinning = true;
      _userCoins -= _bet;
      _winMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 950));
    final random = Random();
    final roll = random.nextDouble();
    int winMult = 0;
    String msg = '';

    if (roll < 0.28) {
      winMult = 0;
      msg = 'حظ أوفر في الجولة القادمة!';
    } else if (roll < 0.70) {
      winMult = 2;
      msg = 'فوز رائع بمضاعف x2! (+ ${_bet * winMult} كوين)';
    } else if (roll < 0.92) {
      winMult = 6;
      msg = 'مكافأة كبرى بمضاعف x6! (+ ${_bet * winMult} كوين)';
    } else {
      winMult = 25;
      msg = '🔥 جاكبوت أسطوري في ${_gamesMeta[_selectedGame]!['name']} بمضاعف x25 كامل!';
    }

    setState(() {
      _userCoins += (_bet * winMult);
      _isSpinning = false;
      _winMessage = msg;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentMeta = _gamesMeta[_selectedGame]!;

    return Dialog(
      backgroundColor: const Color(0xFF0F0A20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFFFB800), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // العنوان والرصيد
            Row(
              children: [
                const Text('👑', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                const Text(
                  'ألعاب Sultan Voic الرسمية (7 ألعاب)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.amber),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Text(
              'الرصيد: $_userCoins كوين 🪙',
              style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 12),

            // شريط اختيار الألعاب الـ 5 بأسماءها الإنجليزية
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: OfficialGameType.values.map((type) {
                  final meta = _gamesMeta[type]!;
                  final isSel = _selectedGame == type;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: ChoiceChip(
                      label: Text(meta['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: isSel ? Colors.black : Colors.white)),
                      selected: isSel,
                      selectedColor: Colors.amber,
                      backgroundColor: const Color(0xFF1B1238),
                      avatar: Text(meta['icon']),
                      onSelected: (val) {
                        if (val) setState(() => _selectedGame = type);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // شاشة اللعبة الحالية
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: currentMeta['color'], width: 1.5),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          currentMeta['asset'] ?? '',
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Text(currentMeta['icon'], style: const TextStyle(fontSize: 28)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        currentMeta['name'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.black, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentMeta['tag'],
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  // شبكة الرموز
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: (currentMeta['symbols'] as List<String>)
                        .take(3)
                        .map((sym) => Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF140D2B),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.amber.withOpacity(0.3)),
                              ),
                              child: Text(sym, style: const TextStyle(fontSize: 32)),
                            ))
                        .toList(),
                  ),
                  if (_winMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _winMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // زر التدوير
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB800),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  _isSpinning ? 'جاري اللعب...' : 'تشغيل ${currentMeta['name']} ($_bet كوين)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: _isSpinning ? null : _spin,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
