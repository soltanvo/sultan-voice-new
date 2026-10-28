import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/supabase_games_service.dart';
import 'official_games_hub.dart';

class PremiumGamingHubSheet extends StatefulWidget {
  const PremiumGamingHubSheet({super.key});

  @override
  State<PremiumGamingHubSheet> createState() => _PremiumGamingHubSheetState();
}

class _PremiumGamingHubSheetState extends State<PremiumGamingHubSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 1. ألعاب التسلية المجانية (CASUAL GAMES)
  final List<Map<String, dynamic>> _casualGames = [
    {
      'id': 'ludo',
      'title': 'لودو الملكية',
      'tag': 'Ludo',
      'icon': '🎲',
      'color': const Color(0xFFEF4444),
      'asset': 'assets/images/ic_game_ludo.png',
      'desc': 'منافسة لودو طاولة 4 لاعبين',
    },
    {
      'id': 'domino',
      'title': 'دومينو المحترفين',
      'tag': 'Domino',
      'icon': '🀄',
      'color': const Color(0xFF3B82F6),
      'asset': 'assets/images/ic_game_domino.png',
      'desc': 'تحدي أحجار الدومينو الكلاسيكية',
    },
    {
      'id': 'chess',
      'title': 'شطرنج السلاطين',
      'tag': 'Chess',
      'icon': '♟️',
      'color': const Color(0xFF8B5CF6),
      'asset': 'assets/images/ic_game_chess.png',
      'desc': 'معركة العقول الملكية الإستراتيجية',
    },
    {
      'id': 'bombs',
      'title': 'صائد القنابل',
      'tag': 'Bombs',
      'icon': '💣',
      'color': const Color(0xFFF59E0B),
      'asset': 'assets/images/ic_game_bombs.png',
      'desc': 'تفادي القنابل وحصد الجوائز المخبأة',
    },
  ];

  // 2. ألعاب التحدي والحظ (PREMIUM CHALLENGE SLOTS - 6 Games in 3x2 Grid)
  final List<Map<String, dynamic>> _premiumSlots = [
    {
      'id': 'greedy_lion',
      'title': 'الأسد والنمر الجشع',
      'tag': 'Greedy Lion',
      'icon': '🦁',
      'color': const Color(0xFFEA580C),
      'asset': 'assets/images/slot_tiger.png',
      'targetGame': OfficialGameType.slotTiger,
    },
    {
      'id': 'greedy_cat',
      'title': 'القط الجشع',
      'tag': 'Greedy Cat',
      'icon': '🐱',
      'color': const Color(0xFF9333EA),
      'asset': 'assets/images/greedy_box.png',
      'targetGame': OfficialGameType.greedyBox,
    },
    {
      'id': 'farm',
      'title': 'مزرعة الثروة',
      'tag': 'Farm Fortune',
      'icon': '🚜',
      'color': const Color(0xFF10B981),
      'asset': 'assets/images/fortune_dragon.png',
      'targetGame': OfficialGameType.fortuneDragon,
    },
    {
      'id': 'amazon',
      'title': 'مغامرة الأمازون',
      'tag': 'Amazon Jungle',
      'icon': '🌴',
      'color': const Color(0xFF059669),
      'asset': 'assets/images/queen_of_bounty.png',
      'targetGame': OfficialGameType.queenOfBounty,
    },
    {
      'id': '777',
      'title': 'ثلاث سبعيات',
      'tag': 'Lucky 777',
      'icon': '🎰',
      'color': const Color(0xFFEAB308),
      'asset': 'assets/images/luck_77.png',
      'targetGame': OfficialGameType.luck77,
    },
    {
      'id': 'headsets',
      'title': 'الثلاث سماعات',
      'tag': 'Groove Headsets',
      'icon': '🎧',
      'color': const Color(0xFF2563EB),
      'asset': 'assets/images/gates_of_olympus.png',
      'targetGame': OfficialGameType.zeus,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openCasualGameDialog(Map<String, dynamic> game) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF150A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
        ),
        title: Row(
          children: [
            Text(game['icon'], style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                game['title'],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(game['desc'], style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.people_outline, color: Color(0xFFFFD700), size: 20),
                  SizedBox(width: 8),
                  Text('غرفة مجانية مفتوحة لجميع رواد المجلس', style: TextStyle(color: Colors.white60, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم إنشاء طاولة ${game['title']} في المجلس الملكي! 🎲')),
              );
            },
            child: const Text('بدء اللعب الآن', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openSlotGame(OfficialGameType targetGame) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => OfficialGamesHubDialog(initialGame: targetGame),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gamesService = context.watch<SupabaseGamesService>();

    return Container(
      height: 520,
      decoration: BoxDecoration(
        color: const Color(0xFF0D061F),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: const Color(0x44FFD700), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // شريط السحب العلوي
          Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // رأس اللوحة مع رصيد الكوينز المتصل بالسيرفر
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.sports_esports_rounded, color: Colors.black, size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'صالة الألعاب الملكية (Gaming Hub)',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'معالجة ذرية آمنة للرهانات عبر خادم Supabase 🛡️',
                        style: TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ],
                  ),
                ),

                // كبسولة الرصيد
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D0E38),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        gamesService.userCoins.toString().replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},',
                            ),
                        style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // شريط التبويب: ألعاب التحدي والحظ vs العاب التسلية المجانية
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF160A30),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFEAB308)]),
                borderRadius: BorderRadius.circular(16),
              ),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              tabs: const [
                Tab(
                  icon: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.casino_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('ألعاب التحدي والحظ (6 ألعاب) 🎰'),
                    ],
                  ),
                ),
                Tab(
                  icon: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.extension_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('العاب التسلية المجانية (4 ألعاب) 🎲'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // محتوى التبويبات
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. ألعاب التحدي والحظ (شبكة 3x2 متوازنة تماماً)
                _buildSlots3x2Grid(),

                // 2. ألعاب التسلية المجانية (CardViews 56dp)
                _buildCasualGamesGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ألعاب التحدي والحظ في شبكة 3x2 متوازنة (Balanced 3x2 rounded CardViews with 56dp centered icons)
  Widget _buildSlots3x2Grid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.88,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _premiumSlots.length,
        itemBuilder: (context, index) {
          final slot = _premiumSlots[index];
          return _buildGameCard(
            title: slot['title'],
            tag: slot['tag'],
            icon: slot['icon'],
            color: slot['color'],
            assetPath: slot['asset'],
            onTap: () => _openSlotGame(slot['targetGame']),
          );
        },
      ),
    );
  }

  /// ألعاب التسلية المجانية (Casual Games 3-columns / 2x2 grid)
  Widget _buildCasualGamesGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.15,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _casualGames.length,
        itemBuilder: (context, index) {
          final game = _casualGames[index];
          return _buildGameCard(
            title: game['title'],
            tag: game['tag'],
            icon: game['icon'],
            color: game['color'],
            assetPath: game['asset'],
            onTap: () => _openCasualGameDialog(game),
          );
        },
      ),
    );
  }

  /// بطاقة اللعبة الفاخرة CardView مع أيقونة 56dp في المركز ونص أبيض عريض
  Widget _buildGameCard({
    required String title,
    required String tag,
    required String icon,
    required Color color,
    required String assetPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withOpacity(0.28),
              const Color(0xFF140828),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.55), width: 1.4),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.18),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // الأيقونة المركزية 56dp
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF0F061E),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: ClipOval(
                  child: Image.asset(
                    assetPath,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Text(icon, style: const TextStyle(fontSize: 28)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // العنوان الأبيض العريض
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),

            // التسمية التوضيحية
            Text(
              tag,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.amber.shade200,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
