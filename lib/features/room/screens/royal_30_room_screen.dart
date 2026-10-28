import 'dart:math';
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

class ChatMessage {
  final String sender;
  final String text;
  final int svipLevel;
  final DateTime time;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.svipLevel,
    required this.time,
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

class _Royal30RoomScreenState extends State<Royal30RoomScreen> with TickerProviderStateMixin {
  late String _activeRoomId;
  late String _activeRoomTitle;
  int _activeMicCount = 30; // 2, 4, 6, 8, 10, 15, 20, 30
  final List<int> _supportedMicCounts = [2, 4, 6, 8, 10, 15, 20, 30];

  late List<SeatData> seats;
  int? mySeatIndex = 0;
  bool _isCinemaMode = false;

  // صاروخ الإطلاق الملكي (Rocket Launch Animation)
  bool _isRocketLaunching = false;
  late AnimationController _rocketController;
  late Animation<double> _rocketYAnimation;
  late Animation<double> _rocketScaleAnimation;

  // المحادثة العامة
  final List<ChatMessage> _messages = [
    ChatMessage(sender: 'سلطان العرب 👑', text: 'أهلاً وسهلاً بجميع الأمراء في مجلس Sultan Voic الملكي! ✨', svipLevel: 9, time: DateTime.now().subtract(const Duration(minutes: 5))),
    ChatMessage(sender: 'مدير المجلس 🛡️', text: 'تم تفعيل نظام حماية المايكات وتخطي الاتصالات العالمية بنجاح.', svipLevel: 6, time: DateTime.now().subtract(const Duration(minutes: 2))),
    ChatMessage(sender: 'الأميرة نور 🌸', text: 'مساء الورد والياسمين لجميع الحضور الكرام 🌹', svipLevel: 5, time: DateTime.now().subtract(const Duration(minutes: 1))),
  ];

  @override
  void initState() {
    super.initState();
    _activeRoomId = widget.roomId;
    _activeRoomTitle = widget.roomTitle;
    _initSeats();

    _rocketController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _rocketYAnimation = Tween<double>(begin: 1.2, end: -1.3).animate(
      CurvedAnimation(parent: _rocketController, curve: Curves.easeInOutCubic),
    );

    _rocketScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.6, end: 1.3), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 1.3, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.8), weight: 30),
    ]).animate(_rocketController);
  }

  @override
  void dispose() {
    _rocketController.dispose();
    super.dispose();
  }

  void _initSeats() {
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

  void _triggerRocketLaunch() {
    if (_isRocketLaunching) return;
    setState(() => _isRocketLaunching = true);
    _rocketController.forward(from: 0.0).then((_) {
      if (mounted) setState(() => _isRocketLaunching = false);
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

  void _switchOfficialRoom(String roomId, String title) {
    setState(() {
      _activeRoomId = roomId;
      _activeRoomTitle = title;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم الانتقال إلى: $title'),
        backgroundColor: const Color(0xFF7C3AED),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final liveKit = context.watch<LiveKitService>();
    final gamesService = context.watch<SupabaseGamesService>();

    return Scaffold(
      backgroundColor: const Color(0xFF090414),
      body: Stack(
        children: [
          // 1. الخلفية المتدرجة مع الأطراف الجانبية الملكية المضيئة (VIP Aura Side Borders)
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.4),
                radius: 1.4,
                colors: [
                  Color(0xFF28114B), // بنفسجي ملكي
                  Color(0xFF120726),
                  Color(0xFF06020D), // أسود أوبسيديان
                ],
              ),
            ),
          ),

          // الحواف الجانبية المتوهجة الملكية (Side VIP Borders)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFFD700).withOpacity(0.8),
                    const Color(0xFF9D4EDD).withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFFD700).withOpacity(0.8),
                    const Color(0xFF9D4EDD).withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // المحتوى الرئيسي
          SafeArea(
            child: Column(
              children: [
                // الشريط العلوي مع اختيار الرومين الرسميين
                _buildTopHeader(gamesService),

                // شريط معلومات المايكات الحالية ونمط السينما
                _buildRoomStatusSubBar(),

                // شبكة المايكات الديناميكية (2 إلى 30 مقعداً) أو وضع السينما
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Column(
                      children: [
                        if (_isCinemaMode) _buildCinemaPlayer(),
                        _buildDynamicMicGrid(),
                        const SizedBox(height: 100), // مساحة للشريط السفلي
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. حاوية صاروخ الإطلاق الملكي (Rocket Launch Animation Container)
          if (_isRocketLaunching)
            AnimatedBuilder(
              animation: _rocketController,
              builder: (context, child) {
                return Positioned.fill(
                  child: IgnorePointer(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // وميض الشاشة الخلفي
                        Container(
                          color: const Color(0xFFFFD700).withOpacity((1.0 - _rocketController.value) * 0.18),
                        ),
                        // الصاروخ المتحرك لأعلى
                        Align(
                          alignment: Alignment(0, _rocketYAnimation.value),
                          child: Transform.scale(
                            scale: _rocketScaleAnimation.value,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🚀', style: TextStyle(fontSize: 90)),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8800)]),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
                                  ),
                                  child: const Text(
                                    'صاروخ الدعم الملكي انطلق! 🚀🔥',
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      // الشريط السفلي الأفقي المرتب تماماً من اليسار إلى اليمين
      bottomSheet: _buildStrictHorizontalBottomBar(liveKit),
    );
  }

  /// الشريط العلوي مع اختيار الرومين الرسميين: خدمة العملاء vs روم الإدارة
  Widget _buildTopHeader(SupabaseGamesService gamesService) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF12082B).withOpacity(0.92),
        border: const Border(bottom: BorderSide(color: Color(0x33FFD700), width: 1)),
      ),
      child: Row(
        children: [
          // زر تبديل الرومين الرسميين
          GestureDetector(
            onTap: _showOfficialRoomsPicker,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFB8860B)]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 8)],
              ),
              child: const Icon(Icons.workspace_premium_rounded, color: Colors.black, size: 20),
            ),
          ),
          const SizedBox(width: 8),

          Expanded(
            child: GestureDetector(
              onTap: _showOfficialRoomsPicker,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _activeRoomTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, color: Color(0xFFFFD700), size: 18),
                    ],
                  ),
                  Text(
                    '$_activeMicCount مقاعد • LiveKit Token 200 نقي 🎙️',
                    style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 10),
                  ),
                ],
              ),
            ),
          ),

          // رصيد الكوينز المتصل بـ Supabase
          GestureDetector(
            onTap: () {
              gamesService.addBonusCoins(5000);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تمت إضافة +5,000 كوين ملكية لحسابك 🪙'),
                  backgroundColor: Color(0xFF7C3AED),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF28114B), Color(0xFF170933)]),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    gamesService.userCoins.toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        ),
                    style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),

          // زر الوكالات
          IconButton(
            icon: const Icon(Icons.shield_outlined, color: Color(0xFFFFD700), size: 21),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
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

  /// شريط حالة الروم: اختيار عدد المايكات وتفعيل وضع السينما
  Widget _buildRoomStatusSubBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF140A30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          // زر عدد المايكات
          GestureDetector(
            onTap: _showMicCountSelector,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.mic, color: Color(0xFFFFD700), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$_activeMicCount مايكات',
                    style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Color(0xFFFFD700), size: 14),
                ],
              ),
            ),
          ),
          const Spacer(),

          // زر وضع السينما
          GestureDetector(
            onTap: () => setState(() => _isCinemaMode = !_isCinemaMode),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: _isCinemaMode ? Colors.purple.withOpacity(0.3) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _isCinemaMode ? Colors.purpleAccent : Colors.white24),
              ),
              child: Row(
                children: [
                  Icon(
                    _isCinemaMode ? Icons.movie : Icons.movie_outlined,
                    color: _isCinemaMode ? Colors.purpleAccent : Colors.white70,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isCinemaMode ? 'وضع السينما نشط 🎬' : 'شاشة السينما',
                    style: TextStyle(
                      color: _isCinemaMode ? Colors.purpleAccent : Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// شاشة عرض السينما العلوية
  Widget _buildCinemaPlayer() {
    return Container(
      width: double.infinity,
      height: 160,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
        gradient: const RadialGradient(
          colors: [Color(0xFF331661), Color(0xFF0F061F)],
          radius: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 18,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.live_tv_rounded, size: 44, color: Color(0xFFFFD700)),
            const SizedBox(height: 6),
            const Text(
              'شاشة البث والسينما الملكية 🎬',
              style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              'مشاهدة المقاطع والأفلام مع المايكات بالأسفل',
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء شبكة المايكات الديناميكية المتكيفة بدقة (2 إلى 30 مقعداً)
  Widget _buildDynamicMicGrid() {
    final activeSeats = seats.take(_activeMicCount).toList();

    // 1. وضع مايكين (2 Mics Dueling / CP Battle)
    if (_activeMicCount == 2) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SeatItemWidget(
              seat: activeSeats[0],
              isThrone: true,
              customSize: 80,
              onTap: () => _handleMicSlotClick(activeSeats[0]),
            ),
            const Text('VS', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.w900, fontSize: 24)),
            SeatItemWidget(
              seat: activeSeats[1],
              isThrone: false,
              customSize: 80,
              onTap: () => _handleMicSlotClick(activeSeats[1]),
            ),
          ],
        ),
      );
    }

    // 2. وضع 4 أو 6 مايكات
    if (_activeMicCount <= 6) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _activeMicCount == 4 ? 2 : 3,
          childAspectRatio: 0.9,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: activeSeats.length,
        itemBuilder: (context, i) {
          return SeatItemWidget(
            seat: activeSeats[i],
            isThrone: i == 0,
            customSize: 62,
            onTap: () => _handleMicSlotClick(activeSeats[i]),
          );
        },
      );
    }

    // 3. وضع 8 أو 10 مايكات
    if (_activeMicCount <= 10) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          childAspectRatio: 0.82,
          crossAxisSpacing: 8,
          mainAxisSpacing: 10,
        ),
        itemCount: activeSeats.length,
        itemBuilder: (context, i) {
          return SeatItemWidget(
            seat: activeSeats[i],
            isThrone: i == 0,
            customSize: 48,
            onTap: () => _handleMicSlotClick(activeSeats[i]),
          );
        },
      );
    }

    // 4. وضع 15 أو 20 مايكاً
    if (_activeMicCount <= 20) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          childAspectRatio: 0.8,
          crossAxisSpacing: 6,
          mainAxisSpacing: 8,
        ),
        itemCount: activeSeats.length,
        itemBuilder: (context, i) {
          return SeatItemWidget(
            seat: activeSeats[i],
            isThrone: i == 0,
            customSize: 42,
            onTap: () => _handleMicSlotClick(activeSeats[i]),
          );
        },
      );
    }

    // 5. وضع الـ 30 مقعداً الإمبراطوري (عرش + 5 نواب + 24 ضيفاً)
    return Column(
      children: [
        // عرش مالك الغرفة الملكي (#1)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF2E1756).withOpacity(0.8), const Color(0xFF170933).withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFEAB308)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('عرش صاحب المجلس الإمبراطوري 👑', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 10)),
              ),
              const SizedBox(height: 8),
              SeatItemWidget(
                seat: activeSeats[0],
                isThrone: true,
                onTap: () => _handleMicSlotClick(activeSeats[0]),
              ),
            ],
          ),
        ),

        // مقاعد كبار الشخصيات والنواب (المقاعد 2 إلى 6)
        Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF140A30).withOpacity(0.6),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF9333EA).withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (i) {
              final seat = activeSeats[i + 1];
              return Expanded(
                child: SeatItemWidget(
                  seat: seat,
                  customSize: 42,
                  onTap: () => _handleMicSlotClick(seat),
                ),
              );
            }),
          ),
        ),

        // مقاعد الضيوف الـ 24 (المقاعد 7 إلى 30)
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0724).withOpacity(0.5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white12),
          ),
          child: GridView.builder(
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
              final seat = activeSeats[i + 6];
              return SeatItemWidget(
                seat: seat,
                customSize: 36,
                onTap: () => _handleMicSlotClick(seat),
              );
            },
          ),
        ),
      ],
    );
  }

  /// الشريط السفلي الأفقي المرتب تماماً بالترتيب الإلزامي من اليسار إلى اليمين:
  /// 1. Room Settings (4-squares)
  /// 2. Games Panel (Gamepad)
  /// 3. Gift Box Shop (Center, slightly larger)
  /// 4. Room Public Text Chat (Bubble)
  /// 5. Private Inbox DMs (Envelope)
  Widget _buildStrictHorizontalBottomBar(LiveKitService liveKit) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0621),
        border: const Border(
          top: BorderSide(color: Color(0x33FFD700), width: 1.2),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 16),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Room Settings (أربعة مربعات 🎛️)
          _buildBottomActionItem(
            icon: Icons.grid_view_rounded,
            label: 'الإعدادات',
            color: const Color(0xFFFFD700),
            onTap: _showRoomSettingsSheet,
          ),

          // 2. Games Panel (ذراع تحكم الألعاب 🎮)
          _buildBottomActionItem(
            icon: Icons.sports_esports_rounded,
            label: 'الألعاب',
            color: Colors.amberAccent,
            onTap: () => showDialog(
              context: context,
              builder: (_) => const OfficialGamesHubDialog(),
            ),
          ),

          // 3. Gift Box Shop (في المنتصف وأكبر حجماً مع تأثير الذهب 🎁)
          GestureDetector(
            onTap: _showGiftShopModal,
            child: Container(
              width: 58,
              height: 58,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFF7C3AED)],
                  radius: 0.9,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFD700), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.45),
                    blurRadius: 14,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.card_giftcard_rounded, color: Colors.black, size: 28),
            ),
          ),

          // 4. Room Public Text Chat (فقاعة الدردشة العامة 💬)
          _buildBottomActionItem(
            icon: Icons.chat_bubble_rounded,
            label: 'الدردشة',
            color: Colors.lightBlueAccent,
            onTap: _showPublicChatSheet,
          ),

          // 5. Private Inbox DMs (الرسائل الخاصة ✉️)
          _buildBottomActionItem(
            icon: Icons.mark_email_unread_rounded,
            label: 'الخاص',
            color: Colors.pinkAccent,
            onTap: _showPrivateDmsSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.35)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// القائمة السفلية للتحكم بالمايك عند النقر عليه (Mute, Kick Out, Invite, Lock)
  void _handleMicSlotClick(SeatData seat) {
    final liveKit = Provider.of<LiveKitService>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF170B36),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'تحكم المايك رقم ${seat.seatIndex + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFFFD700)),
              ),
              const SizedBox(height: 14),

              if (seat.isOccupied) ...[
                // 1. كتم / إلغاء كتم الصوت (Mute)
                ListTile(
                  leading: Icon(seat.isMuted ? Icons.mic : Icons.mic_off, color: seat.isMuted ? Colors.greenAccent : Colors.redAccent),
                  title: Text(seat.isMuted ? 'إلغاء كتم الصوت (Unmute)' : 'كتم المايك (Mute)', style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    setState(() => seat.isMuted = !seat.isMuted);
                    if (seat.seatIndex == mySeatIndex) {
                      liveKit.toggleMicrophone();
                    }
                    Navigator.pop(context);
                  },
                ),
                // 2. إنزال العضو من المقعد (Kick Out)
                ListTile(
                  leading: const Icon(Icons.person_remove_rounded, color: Colors.orangeAccent),
                  title: const Text('إنزال العضو من المقعد (Kick Out)', style: TextStyle(color: Colors.white)),
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
                // الجلوس على المايك
                ListTile(
                  leading: const Icon(Icons.mic, color: Colors.greenAccent),
                  title: const Text('الجلوس والصعود على هذا المايك', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    setState(() {
                      seat.isOccupied = true;
                      seat.userName = 'سلطان العرب 👑';
                      seat.avatarUrl = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150';
                      seat.isMuted = false;
                      mySeatIndex = seat.seatIndex;
                    });
                    liveKit.toggleMicrophone();
                    Navigator.pop(context);
                  },
                ),
              ],

              // 3. دعوة عضو للمقعد (Invite)
              ListTile(
                leading: const Icon(Icons.person_add_alt_1_rounded, color: Colors.lightBlueAccent),
                title: const Text('دعوة عضو للمقعد (Invite)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تم إرسال دعوة ملكية للصعود إلى المايك ${seat.seatIndex + 1} 📩')),
                  );
                },
              ),

              // 4. قفل / فتح المقعد (Lock)
              ListTile(
                leading: Icon(seat.isLocked ? Icons.lock_open_rounded : Icons.lock_rounded, color: Colors.amber),
                title: Text(seat.isLocked ? 'فتح قفل المقعد (Unlock)' : 'قفل المقعد (Lock)', style: const TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() => seat.isLocked = !seat.isLocked);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// نافذة إعدادات الغرفة واختيار سعة المايكات (Room Settings)
  void _showRoomSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF14082E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.grid_view_rounded, color: Color(0xFFFFD700)),
                  SizedBox(width: 8),
                  Text('إعدادات المجلس الملكي وسعة المايكات', style: TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),

              const Text('اختر عدد المايكات المتاحة للروم:', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _supportedMicCounts.map((count) {
                  final isSelected = _activeMicCount == count;
                  return ChoiceChip(
                    label: Text('$count مايكات'),
                    selected: isSelected,
                    selectedColor: const Color(0xFFFFD700),
                    backgroundColor: const Color(0xFF261247),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() => _activeMicCount = count);
                        Navigator.pop(context);
                      }
                    },
                  );
                }).toList(),
              ),
              const Divider(color: Colors.white12, height: 28),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.movie_filter_rounded, color: Colors.purpleAccent),
                title: const Text('تفعيل / إيقاف وضع السينما', style: TextStyle(color: Colors.white)),
                trailing: Switch(
                  value: _isCinemaMode,
                  activeColor: const Color(0xFFFFD700),
                  onChanged: (val) {
                    setState(() => _isCinemaMode = val);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// نافذة اختيار عدد المايكات السريعة
  void _showMicCountSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF14082E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('تغيير سعة المايكات الفورية 🎙️', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _supportedMicCounts.map((count) {
                  final isSel = _activeMicCount == count;
                  return ChoiceChip(
                    label: Text('$count'),
                    selected: isSel,
                    selectedColor: const Color(0xFFFFD700),
                    backgroundColor: const Color(0xFF200F3E),
                    labelStyle: TextStyle(color: isSel ? Colors.black : Colors.white, fontWeight: FontWeight.w900),
                    onSelected: (val) {
                      if (val) {
                        setState(() => _activeMicCount = count);
                        Navigator.pop(context);
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  /// اختيار الرومين الرسميين: غرفة خدمة العملاء الرسمية vs روم الإدارة
  void _showOfficialRoomsPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF14082E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('الغرفتان الرسميتان المعتمدتان 👑', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 14),

              // 1. غرفة خدمة العملاء الرسمية
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: _activeRoomId == 'customer_service_room' ? const Color(0xFFFFD700).withOpacity(0.15) : const Color(0xFF221040),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _activeRoomId == 'customer_service_room' ? const Color(0xFFFFD700) : Colors.white12),
                ),
                child: ListTile(
                  leading: const Text('🎧', style: TextStyle(fontSize: 26)),
                  title: const Text('غرفة خدمة العملاء الرسمية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: const Text('الدعم الفني، الشكاوى، والمساعدة المباشرة', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  trailing: _activeRoomId == 'customer_service_room' ? const Icon(Icons.check_circle, color: Color(0xFFFFD700)) : null,
                  onTap: () {
                    Navigator.pop(context);
                    _switchOfficialRoom('customer_service_room', 'غرفة خدمة العملاء الرسمية 👑');
                  },
                ),
              ),

              // 2. روم الإدارة
              Container(
                decoration: BoxDecoration(
                  color: _activeRoomId == 'management_room' ? const Color(0xFFFFD700).withOpacity(0.15) : const Color(0xFF221040),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _activeRoomId == 'management_room' ? const Color(0xFFFFD700) : Colors.white12),
                ),
                child: ListTile(
                  leading: const Text('🛡️', style: TextStyle(fontSize: 26)),
                  title: const Text('روم الإدارة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: const Text('مجلس الإدارة العليا، تفويض الوكالات والمشرفين', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  trailing: _activeRoomId == 'management_room' ? const Icon(Icons.check_circle, color: Color(0xFFFFD700)) : null,
                  onTap: () {
                    Navigator.pop(context);
                    _switchOfficialRoom('management_room', 'روم الإدارة 🛡️');
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// متجر وصندوق الهدايا الملكي مع زر إطلاق الصاروخ 🚀
  void _showGiftShopModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF14082E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                children: [
                  Icon(Icons.card_giftcard_rounded, color: Color(0xFFFFD700)),
                  SizedBox(width: 8),
                  Text('صندوق الهدايا الإمبراطوري 🎁', style: TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // صاروخ الإطلاق الملكي
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _triggerRocketLaunch();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF3B1578), Color(0xFF1F0945)]),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                      ),
                      child: const Column(
                        children: [
                          Text('🚀', style: TextStyle(fontSize: 34)),
                          SizedBox(height: 4),
                          Text('صاروخ الإطلاق', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 11)),
                          Text('1,000 كوين', style: TextStyle(color: Colors.white54, fontSize: 9)),
                        ],
                      ),
                    ),
                  ),

                  // الصقر الأسود SVIP 9
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _triggerSvipBanner(9);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF3B1578), Color(0xFF1F0945)]),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.amber, width: 1),
                      ),
                      child: const Column(
                        children: [
                          Text('🦅', style: TextStyle(fontSize: 34)),
                          SizedBox(height: 4),
                          Text('صقر SVIP 9', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 11)),
                          Text('5,000 كوين', style: TextStyle(color: Colors.white54, fontSize: 9)),
                        ],
                      ),
                    ),
                  ),

                  // التنين الكوني
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _triggerSvipBanner(7);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF3B1578), Color(0xFF1F0945)]),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.purpleAccent, width: 1),
                      ),
                      child: const Column(
                        children: [
                          Text('🐉', style: TextStyle(fontSize: 34)),
                          SizedBox(height: 4),
                          Text('تنين الحظ', style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                          Text('2,500 كوين', style: TextStyle(color: Colors.white54, fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// نافذة المحادثة العامة (Room Public Text Chat)
  void _showPublicChatSheet() {
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF14082E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                children: [
                  Icon(Icons.chat_bubble_rounded, color: Colors.lightBlueAccent),
                  SizedBox(width: 8),
                  Text('دردشة المجلس العامة 💬', style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              const SizedBox(height: 12),

              // قائمة الرسائل
              SizedBox(
                height: 180,
                child: ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, i) {
                    final msg = _messages[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${msg.sender}: ', style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 12)),
                          Expanded(
                            child: Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // حقل الإرسال
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF221142),
                        hintText: 'اكتب رسالة عامة للمجلس...',
                        hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: Color(0xFFFFD700)),
                    onPressed: () {
                      final txt = textController.text.trim();
                      if (txt.isNotEmpty) {
                        setState(() {
                          _messages.add(ChatMessage(
                            sender: 'سلطان العرب 👑',
                            text: txt,
                            svipLevel: 9,
                            time: DateTime.now(),
                          ));
                        });
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// نافذة الرسائل الخاصة (Private Inbox DMs)
  void _showPrivateDmsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF14082E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                children: [
                  Icon(Icons.mark_email_unread_rounded, color: Colors.pinkAccent),
                  SizedBox(width: 8),
                  Text('صندوق الرسائل الخاصة (Inbox DMs) ✉️', style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              const SizedBox(height: 16),

              ListTile(
                leading: const CircleAvatar(
                  backgroundImage: NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150'),
                ),
                title: const Text('الأميرة نور 🌸', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text('شكراً جزيلاً لك على دعمك الكريم في المجلس! ❤️', style: TextStyle(color: Colors.white54, fontSize: 11)),
                trailing: const Text('منذ 10 د', style: TextStyle(color: Colors.white38, fontSize: 10)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150'),
                ),
                title: const Text('مدير المجلس 🛡️', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text('تم توثيق رتبة وكالتك في نظام Supabase بنجاح.', style: TextStyle(color: Colors.white54, fontSize: 11)),
                trailing: const Text('منذ 25 د', style: TextStyle(color: Colors.white38, fontSize: 10)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
