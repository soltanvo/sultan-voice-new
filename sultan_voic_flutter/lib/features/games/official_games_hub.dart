import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/supabase_games_service.dart';

enum OfficialGameType {
  slotTiger,
  fortuneDragon,
  greedyBox,
  zeus,
  luck77,
  mahjongWays2,
  queenOfBounty,
  fortuneTiger,
  yummy,
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

class _OfficialGamesHubDialogState extends State<OfficialGamesHubDialog> with SingleTickerProviderStateMixin {
  late OfficialGameType _selectedGame;
  int _bet = 500;
  bool _isSpinning = false;
  String? _winMessage;
  int _lastWinAmount = 0;
  List<String> _currentReels = ['👑', '💎', '7️⃣'];
  late AnimationController _pulseController;

  final Map<OfficialGameType, Map<String, dynamic>> _gamesMeta = {
    OfficialGameType.slotTiger: {
      'name': 'Slot Tiger',
      'arabicName': 'تايغر سلوت الملكي',
      'icon': '🐯',
      'asset': 'assets/images/slot_tiger.png',
      'tag': 'نمر الحظ الصيني مع أظرف الذهب والمضاعفات الفورية',
      'symbols': ['🐯', '🧧', '🪙', '🏮', '👑', '💎'],
      'color': const Color(0xFFEA580C),
      'maxMult': 50,
    },
    OfficialGameType.fortuneDragon: {
      'name': 'Fortune Dragon',
      'arabicName': 'كنوز تنين الحظ',
      'icon': '🐉',
      'asset': 'assets/images/fortune_dragon.png',
      'tag': 'تنين الشرق الأسطوري وحبات اللؤلؤ الإمبراطورية',
      'symbols': ['🐉', '🥚', '💎', '🪙', '👑', '🔥'],
      'color': const Color(0xFFDC2626),
      'maxMult': 100,
    },
    OfficialGameType.greedyBox: {
      'name': 'Greedy Box',
      'arabicName': 'صندوق الجشع الذهبي',
      'icon': '🎁',
      'asset': 'assets/images/greedy_box.png',
      'tag': 'صناديق الكنوز الملكية مع جوائز الحظ المضاعفة',
      'symbols': ['🎁', '🗝️', '💎', '⚔️', '🪙', '👑'],
      'color': const Color(0xFF9333EA),
      'maxMult': 40,
    },
    OfficialGameType.zeus: {
      'name': 'Gates of Olympus',
      'arabicName': 'زيوس قاهر الأولمب',
      'icon': '⚡',
      'asset': 'assets/images/gates_of_olympus.png',
      'tag': 'صواعق زيوس الخارقة مع كؤوس الذهب والمجوهرات الملكية',
      'symbols': ['⚡', '🔮', '👑', '🏺', '💍', '⏳'],
      'color': const Color(0xFF2563EB),
      'maxMult': 250,
    },
    OfficialGameType.luck77: {
      'name': 'Luck 77',
      'arabicName': 'سلوت حظ 777 الملكي',
      'icon': '🎰',
      'asset': 'assets/images/luck_77.png',
      'tag': 'عجلة الحظ الكلاسيكية مع الرقم 7 الذهبي الثلاثي',
      'symbols': ['7️⃣', '💎', '🔔', '🍒', '🍀', '👑'],
      'color': const Color(0xFFFBBF24),
      'maxMult': 77,
    },
    OfficialGameType.mahjongWays2: {
      'name': 'Mahjong Ways 2',
      'arabicName': 'ماجونغ وايز 2',
      'icon': '🀄',
      'asset': 'assets/images/mahjong_ways_2.png',
      'tag': 'أحجار الماجونغ الإمبراطورية مع التنين الذهبي',
      'symbols': ['🀄', '🀅', '🀆', '🪙', '🐉', '🏮'],
      'color': const Color(0xFF10B981),
      'maxMult': 88,
    },
    OfficialGameType.queenOfBounty: {
      'name': 'Queen of Bounty',
      'arabicName': 'ملكة القراصنة والمكافآت',
      'icon': '🏴‍☠️',
      'asset': 'assets/images/queen_of_bounty.png',
      'tag': 'كنوز البحار السبعة مع مضاعفات المدافع الملكية',
      'symbols': ['🏴‍☠️', '👑', '💎', '⚔️', '🗺️', '🪙'],
      'color': const Color(0xFFD97706),
      'maxMult': 60,
    },
    OfficialGameType.fortuneTiger: {
      'name': 'Fortune Tiger',
      'arabicName': 'نمر الثروة الذهبية',
      'icon': '🐅',
      'asset': 'assets/images/fortune_tiger.png',
      'tag': 'ضربات النمر الذهبي ومضاعفات الجاكبوت الإمبراطوري',
      'symbols': ['🐅', '💰', '🧧', '✨', '👑', '💎'],
      'color': const Color(0xFFF59E0B),
      'maxMult': 120,
    },
    OfficialGameType.yummy: {
      'name': 'Yummy Sweet',
      'arabicName': 'يامي بونانزا السكرية',
      'icon': '🍬',
      'asset': 'assets/images/yummy.png',
      'tag': 'حلوى الحظ اللذيذة ومضاعفات الفواكه السحرية',
      'symbols': ['🍬', '🍭', '🍇', '🍉', '⭐', '💣'],
      'color': const Color(0xFFEC4899),
      'maxMult': 50,
    },
  };

  @override
  void initState() {
    super.initState();
    _selectedGame = widget.initialGame;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    final symbols = _gamesMeta[_selectedGame]!['symbols'] as List<String>;
    _currentReels = [symbols[0], symbols[1], symbols[2]];
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _spin() async {
    final gamesService = Provider.of<SupabaseGamesService>(context, listen: false);
    if (gamesService.userCoins < _bet || _isSpinning) return;

    setState(() {
      _isSpinning = true;
      _winMessage = null;
      _lastWinAmount = 0;
    });

    final meta = _gamesMeta[_selectedGame]!;
    final List<String> symbols = List<String>.from(meta['symbols']);

    // تأثير حركة البكرات
    for (int i = 0; i < 6; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() {
          _currentReels = [
            symbols[Random().nextInt(symbols.length)],
            symbols[Random().nextInt(symbols.length)],
            symbols[Random().nextInt(symbols.length)],
          ];
        });
      }
    }

    final random = Random();
    final roll = random.nextDouble();
    int multiplier = 0;
    String message = '';

    if (roll < 0.35) {
      // خسارة
      multiplier = 0;
      message = 'حظ أوفر في الجولة القادمة! 🍀';
      _currentReels = [
        symbols[0],
        symbols[1],
        symbols[2],
      ];
    } else if (roll < 0.70) {
      // فوز عادي x2
      multiplier = 2;
      _currentReels = [symbols[1], symbols[1], symbols[0]];
      message = '🎉 فوز رائع بمضاعف x2!';
    } else if (roll < 0.90) {
      // فوز كبير x5
      multiplier = 5;
      _currentReels = [symbols[2], symbols[2], symbols[2]];
      message = '🔥 فوز مميز ثلاثي بمضاعف x5!';
    } else {
      // جاكبوت أسطوري
      multiplier = 15;
      _currentReels = [symbols[0], symbols[0], symbols[0]];
      message = '👑 جاكبوت ملكي أسطوري بمضاعف x15 كامل!';
    }

    final winAmount = _bet * multiplier;

    // المزامنة الفورية مع خدمة Supabase
    await gamesService.processGameBetAndWin(
      gameName: meta['name'],
      bet: _bet,
      winAmount: winAmount,
      multiplier: multiplier,
    );

    if (mounted) {
      setState(() {
        _isSpinning = false;
        _winMessage = message;
        _lastWinAmount = winAmount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gamesService = context.watch<SupabaseGamesService>();
    final currentMeta = _gamesMeta[_selectedGame]!;

    return Dialog(
      backgroundColor: const Color(0xFF0D0822),
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const RadialGradient(
            center: Alignment(0, -0.6),
            radius: 1.2,
            colors: [
              Color(0xFF231145),
              Color(0xFF0D0822),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // الشريط العلوي مع الرصيد المتصل بـ Supabase
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.amber, width: 1.5),
                  ),
                  child: const Text('👑', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'صالة ألعاب Sultan Voic الرسمية',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.cloud_done, color: Colors.greenAccent, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            'متصل بـ Supabase • ${gamesService.userCoins.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} كوين',
                            style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // شريط اختيار الألعاب الأفقي مع الصور الأصلية
            SizedBox(
              height: 74,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: OfficialGameType.values.length,
                itemBuilder: (context, index) {
                  final type = OfficialGameType.values[index];
                  final meta = _gamesMeta[type]!;
                  final isSelected = _selectedGame == type;

                  return GestureDetector(
                    onTap: () {
                      if (_isSpinning) return;
                      setState(() {
                        _selectedGame = type;
                        _winMessage = null;
                        _lastWinAmount = 0;
                        final syms = meta['symbols'] as List<String>;
                        _currentReels = [syms[0], syms[1], syms[2]];
                      });
                    },
                    child: Container(
                      width: 68,
                      margin: const EdgeInsets.only(left: 6, right: 6),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isSelected ? meta['color'].withOpacity(0.3) : const Color(0xFF160E33),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFFD700) : Colors.white12,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: (meta['color'] as Color).withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              meta['asset'],
                              width: 34,
                              height: 34,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Text(meta['icon'], style: const TextStyle(fontSize: 24)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            meta['name'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.amber : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // صندوق اللعبة النشطة
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF090518),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: currentMeta['color'], width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: (currentMeta['color'] as Color).withOpacity(0.2),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          currentMeta['asset'],
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Text(currentMeta['icon'], style: const TextStyle(fontSize: 26)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentMeta['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            currentMeta['arabicName'],
                            style: TextStyle(
                              color: Colors.amber.shade300,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.withOpacity(0.4)),
                        ),
                        child: Text(
                          'أقصى مضاعف x${currentMeta['maxMult']}',
                          style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // بكرات اللعبة الثلاثية
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _currentReels.map((sym) {
                      return Container(
                        width: 72,
                        height: 72,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF281452), Color(0xFF13092B)],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            sym,
                            style: TextStyle(
                              fontSize: _isSpinning ? 30 : 38,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // رسالة النتيجة والفوز
                  if (_winMessage != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _lastWinAmount > 0 ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _lastWinAmount > 0 ? Colors.greenAccent : Colors.redAccent,
                        ),
                      ),
                      child: Text(
                        '$_winMessage ${_lastWinAmount > 0 ? "(+ $_lastWinAmount كوين)" : ""}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _lastWinAmount > 0 ? Colors.greenAccent : Colors.amber.shade200,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // أزرار اختيار قيمة الرهان
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [100, 500, 1000, 5000].map((b) {
                final isSelected = _bet == b;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(
                      '$b كوين',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.black : Colors.white,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFFFFD700),
                    backgroundColor: const Color(0xFF1B1038),
                    onSelected: (val) {
                      if (val && !_isSpinning) setState(() => _bet = b);
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),

            // زر التدوير الملكي
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  elevation: 6,
                  shadowColor: Colors.amber.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isSpinning ? null : _spin,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isSpinning ? 'جاري اللعب...' : 'تشغيل ${currentMeta['name']} ($_bet كوين)',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.play_circle_fill_rounded, size: 22),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
