import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/livekit_service.dart';
import '../../../core/services/supabase_games_service.dart';
import '../widgets/seat_item_widget.dart';
import '../../svip/widgets/svip_entry_banner.dart';
import '../../agency/screens/agency_management_sheet.dart';
import '../../games/official_games_hub.dart';

class SeatData {
  final int seatIndex;
  String? userName;
  String? avatarUrl;
  String role;
  int svipLevel;
  bool isLocked;
  bool isMuted;
  bool isOccupied;

  SeatData({
    required this.seatIndex,
    this.userName,
    this.avatarUrl,
    required this.role,
    required this.svipLevel,
    required this.isLocked,
    required this.isMuted,
    required this.isOccupied,
  });
}

class Royal30RoomScreen extends StatefulWidget {
  final String roomId;
  final String roomTitle;

  const Royal30RoomScreen({
    super.key,
    required this.roomId,
    required this.roomTitle,
  });

  @override
  State<Royal30RoomScreen> createState() => _Royal30RoomScreenState();
}

class _Royal30RoomScreenState extends State<Royal30RoomScreen> {
  late List<SeatData> seats;
  int? mySeatIndex = 0;
  bool _isCinemaMode = false;

  @override
  void initState() {
    super.initState();
    _init30Seats();
  }

  void _init30Seats() {
    seats = List.generate(30, (index) {
      if (index == 0) {
        return SeatData(
          seatIndex: 0,
          userName: 'سلطان العرب 👑',
          avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
          role: 'super_admin',
          svipLevel: 9,
          isLocked: false,
          isMuted: false,
          isOccupied: true,
        );
      } else if (index == 1) {
        return SeatData(
          seatIndex: 1,
          userName: 'مدير المجلس 🛡️',
          avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
          role: 'manager',
          svipLevel: 6,
          isLocked: false,
          isMuted: false,
          isOccupied: true,
        );
      } else if (index == 2) {
        return SeatData(
          seatIndex: 2,
          userName: 'الأميرة نور 🌸',
          avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
          role: 'supervisor',
          svipLevel: 5,
          isLocked: false,
          isMuted: false,
          isOccupied: true,
        );
      }
      return SeatData(
        seatIndex: index,
        userName: null,
        avatarUrl: null,
        role: 'user',
        svipLevel: 0,
        isLocked: false,
        isMuted: false,
        isOccupied: false,
      );
    });
  }

  void _triggerSvipBanner(int level) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: GestureDetector(
          onTap: () => Navigator.of(context, rootNavigator: true).pop(),
          child: SvipEntryBanner(
            userName: 'سلطان العرب 👑',
            avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
            svipLevel: level,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final liveKit = context.watch<LiveKitService>();
    final gamesService = context.watch<SupabaseGamesService>();

    return Scaffold(
      backgroundColor: const Color(0xFF090414),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.5),
            radius: 1.4,
            colors: [
              Color(0xFF28114B), // بنفسجي ملكي فخم
              Color(0xFF120726),
              Color(0xFF06020D), // أسود أوبسيديان
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. الشريط العلوي الملكي المنظم
              _buildTopHeader(gamesService),

              // 2. شريط تحويل الأوضاع (مجلس 30 مقعداً vs سينما و CP)
              _buildModeSwitcher(),

              // 3. المحتوى الرئيسي (العرش والمقاعد)
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: _isCinemaMode
                      ? _buildCinemaSection()
                      : Column(
                          children: [
                            // عرش مالك الغرفة الملكي
                            _buildThroneCard(),
                            const SizedBox(height: 12),

                            // مقاعد كبار الشخصيات والنواب (المقاعد 2 إلى 6)
                            _buildVipRow(),
                            const SizedBox(height: 14),

                            // شبكة مقاعد الضيوف الـ 24 (المقاعد 7 إلى 30)
                            _buildGuestGrid(),
                            const SizedBox(height: 90), // مساحة للأزرار العائمة
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: _buildFloatingDock(liveKit, gamesService),
    );
  }

  /// الشريط العلوي الملكي بتنسيق منظم ومريح
  Widget _buildTopHeader(SupabaseGamesService gamesService) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF12082B).withOpacity(0.9),
        border: const Border(
          bottom: BorderSide(color: Color(0x33FFD700), width: 1),
        ),
      ),
      child: Row(
        children: [
          // الشعار والعنوان
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.workspace_premium_rounded, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.roomTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'LiveKit HD • 30 مقعداً',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // كبسولة رصيد الكوينز المتصلة بـ Supabase
          GestureDetector(
            onTap: () {
              gamesService.addBonusCoins(5000);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تمت إضافة هدية كوينز ملكية إلى حسابك (+5,000 كوين) 🪙'),
                  backgroundColor: Color(0xFF7C3AED),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF28114B), Color(0xFF1A0A33)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Text(
                    gamesService.userCoins.toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        ),
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // زر إدارة الوكالة
          IconButton(
            icon: const Icon(Icons.shield_outlined, color: Color(0xFFFFD700), size: 22),
            tooltip: 'إدارة الوكالة والمشرفين',
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const AgencyManagementSheet(),
            ),
          ),
        ],
      ),
    );
  }

  /// شريط التبديل بين وضع المجلس ووضع السينما
  Widget _buildModeSwitcher() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF140A30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isCinemaMode = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  gradient: !_isCinemaMode
                      ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFEAB308)])
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.groups_rounded, size: 16, color: !_isCinemaMode ? Colors.black : Colors.white60),
                    const SizedBox(width: 6),
                    Text(
                      'مجلس 30 مقعداً',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: !_isCinemaMode ? Colors.black : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isCinemaMode = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  gradient: _isCinemaMode
                      ? const LinearGradient(colors: [Color(0xFF9333EA), Color(0xFFC084FC)])
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.movie_filter_rounded, size: 16, color: _isCinemaMode ? Colors.white : Colors.white60),
                    const SizedBox(width: 6),
                    Text(
                      'سينما وعرش CP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _isCinemaMode ? Colors.white : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// عرش مالك الغرفة الملكي (#1)
  Widget _buildThroneCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2E1756).withOpacity(0.8),
            const Color(0xFF170933).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.2),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFEAB308)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.military_tech_rounded, size: 14, color: Colors.black),
                SizedBox(width: 4),
                Text(
                  'عرش مالك الغرفة الإمبراطوري',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SeatItemWidget(
            seat: seats[0],
            isThrone: true,
            onTap: () => _handleSeatClick(0),
          ),
        ],
      ),
    );
  }

  /// مقاعد النواب ومجلس الإدارة (#2 إلى #6)
  Widget _buildVipRow() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF140A30).withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF9333EA).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.star_rounded, color: Color(0xFFC084FC), size: 14),
                SizedBox(width: 4),
                Text(
                  'مقاعد النواب ومجلس الإدارة (#2 - #6)',
                  style: TextStyle(
                    color: Color(0xFFC084FC),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (i) {
              final seatIdx = i + 1;
              return Expanded(
                child: SeatItemWidget(
                  seat: seats[seatIdx],
                  onTap: () => _handleSeatClick(seatIdx),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// شبكة مقاعد الضيوف الـ 24 (#7 إلى #30) بتوزيع مريح ومثالي
  Widget _buildGuestGrid() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0724).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Text(
              'مقاعد الضيوف الملكية (#7 - #30)',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              childAspectRatio: 0.82,
              crossAxisSpacing: 6,
              mainAxisSpacing: 8,
            ),
            itemCount: 24,
            itemBuilder: (context, i) {
              final seatIdx = i + 6;
              return SeatItemWidget(
                seat: seats[seatIdx],
                onTap: () => _handleSeatClick(seatIdx),
              );
            },
          ),
        ],
      ),
    );
  }

  /// قسم السينما وعرش الحب CP
  Widget _buildCinemaSection() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.amber, width: 2),
            gradient: const LinearGradient(
              colors: [Color(0xFF28114B), Color(0xFF0D061A)],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.live_tv_rounded, size: 48, color: Colors.amber),
                SizedBox(height: 8),
                Text(
                  'شاشة العرض السينمائية 🎬',
                  style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'بث سينمائي نقي مع مكبرات صوت محيطية',
                  style: TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // مقاعد السينما العشرة
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 0.85,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 10,
          itemBuilder: (context, i) {
            return SeatItemWidget(
              seat: seats[i],
              onTap: () => _handleSeatClick(i),
            );
          },
        ),
      ],
    );
  }

  /// الشريط العائم السفلي المنسق باحترافية وبدون أي تداخل
  Widget _buildFloatingDock(LiveKitService liveKit, SupabaseGamesService gamesService) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0624),
        border: const Border(
          top: BorderSide(color: Color(0x33FFD700), width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. زر الميكروفون
          GestureDetector(
            onTap: () => liveKit.toggleMicrophone(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: liveKit.isMicMuted ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                border: Border.all(
                  color: liveKit.isMicMuted ? Colors.redAccent : Colors.greenAccent,
                  width: 1.5,
                ),
              ),
              child: Icon(
                liveKit.isMicMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                color: liveKit.isMicMuted ? Colors.redAccent : Colors.greenAccent,
                size: 22,
              ),
            ),
          ),

          // 2. زر صالة الألعاب الرسمية السبعة (المتصلة بـ Supabase)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 6,
            ),
            icon: const Icon(Icons.casino_rounded, size: 20),
            label: const Text(
              'صالة الألعاب (7 ألعاب) 🐯',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const OfficialGamesHubDialog(),
              );
            },
          ),

          // 3. زر تجربة دخول الـ SVIP
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Color(0xFFFFD700), size: 24),
            tooltip: 'دخول SVIP 9 الملكي',
            onPressed: () => _triggerSvipBanner(9),
          ),

          // 4. زر صندوق الهدايا
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9333EA), Color(0xFFC084FC)],
              ),
              shape: BoxShape.circle,
            ),
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('صندوق الهدايا الملكية: الأسد الذهبي، الصقر الأسود، وألسنة اللهب ✨'),
                    backgroundColor: Color(0xFF9333EA),
                  ),
                );
              },
              child: const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSeatClick(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF170B36),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final seat = seats[index];
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'إدارة المقعد رقم ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFFFD700)),
              ),
              const SizedBox(height: 12),
              if (seat.isOccupied) ...[
                ListTile(
                  leading: const Icon(Icons.mic_off, color: Colors.redAccent),
                  title: const Text('كتم صوت العضو', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    setState(() => seat.isMuted = !seat.isMuted);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.orangeAccent),
                  title: const Text('إنزال العضو من المقعد', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    setState(() {
                      seat.isOccupied = false;
                      seat.userName = null;
                      seat.avatarUrl = null;
                    });
                    Navigator.pop(context);
                  },
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.airline_seat_recline_normal, color: Colors.greenAccent),
                  title: const Text('الجلوس على هذا المقعد', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    setState(() {
                      seat.isOccupied = true;
                      seat.userName = 'سلطان العرب 👑';
                      seat.avatarUrl = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150';
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(seat.isLocked ? Icons.lock_open : Icons.lock, color: Colors.amber),
                  title: Text(seat.isLocked ? 'فتح قفل المقعد' : 'قفل المقعد', style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    setState(() => seat.isLocked = !seat.isLocked);
                    Navigator.pop(context);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
