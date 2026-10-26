import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/livekit_service.dart';
import '../widgets/seat_item_widget.dart';
import '../../svip/widgets/svip_entry_banner.dart';
import '../../agency/screens/agency_management_sheet.dart';
import '../../games/slot_machine_dialog.dart';
import '../../games/greedy_cat_dialog.dart';

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
  // تمثيل حالة الـ 30 مقعداً (0: المالك، 1-5: النواب، 6-29: الضيوف)
  late List<SeatData> seats;
  int? mySeatIndex;

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
          userName: 'المالك الإمبراطور',
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
          role: 'super_admin',
          svipLevel: 3,
          isLocked: false,
          isMuted: false,
          isOccupied: true,
        );
      } else if (index == 1) {
        return SeatData(
          seatIndex: 1,
          userName: 'مدير العمليات',
          avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
          role: 'manager',
          svipLevel: 2,
          isLocked: false,
          isMuted: false,
          isOccupied: true,
        );
      } else if (index == 2) {
        return SeatData(
          seatIndex: 2,
          userName: 'مشرف الوكالة',
          avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
          role: 'supervisor',
          svipLevel: 1,
          isLocked: false,
          isMuted: true,
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

  @override
  Widget build(BuildContext context) {
    final liveKit = context.watch<LiveKitService>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.4),
            radius: 1.3,
            colors: [
              Color(0xFF261245), // بنفسجي ملكي عميق
              Color(0xFF100720),
              Color(0xFF06030C), // أسود مخملي
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              const SizedBox(height: 6),
              
              // الـ 30 مقعداً في حاوية قابلة للتمرير مع تقسيم ملكي
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      // صف العرش: المقعد رقم 1 (صاحب الغرفة)
                      _buildThroneSection(),
                      const SizedBox(height: 12),
                      
                      // صف النواب: المقاعد 2 إلى 6 (5 مقاعد كبار الشخصيات)
                      _buildVipRow(),
                      const SizedBox(height: 14),
                      
                      // شبكة الضيوف: المقاعد 7 إلى 30 (24 مقعداً بنظام 6x4)
                      _buildGuestGrid(),
                      const SizedBox(height: 80), // مساحة للشريط السفلي
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: _buildBottomControls(liveKit),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.amber, width: 1.5),
            ),
            child: const Icon(Icons.workspace_premium, color: Colors.amber, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.roomTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'ID: ${widget.roomId} • 30 مقعداً نشطاً',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                ),
              ],
            ),
          ),
          // زر تفويض الوكالة
          IconButton(
            icon: const Icon(Icons.groups_outlined, color: Colors.amber),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const AgencyManagementSheet(),
            ),
          ),
          // خروج
          IconButton(
            icon: const Icon(Icons.power_settings_new, color: Colors.redAccent),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildThroneSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.withOpacity(0.4)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.military_tech, color: Colors.amber, size: 16),
              SizedBox(width: 4),
              Text('عرش مالك الغرفة الملكي', style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SeatItemWidget(
          seat: seats[0],
          isThrone: true,
          onTap: () => _handleSeatClick(0),
        ),
      ],
    );
  }

  Widget _buildVipRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Text(
            'مقاعد النواب ومجلس الإدارة (#2 - #6)',
            style: TextStyle(color: Color(0xFFC084FC), fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
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
    );
  }

  Widget _buildGuestGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Text(
            'مقاعد الضيوف الملكية (#7 - #30)',
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            childAspectRatio: 0.75,
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
    );
  }

  Widget _buildBottomControls(LiveKitService liveKit) {
    return Container(
      color: const Color(0xFF0F0924),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // زر المايك
          InkWell(
            onTap: () => liveKit.toggleMicrophone(),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: liveKit.isMicMuted ? Colors.redAccent.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                border: Border.all(color: liveKit.isMicMuted ? Colors.redAccent : Colors.green),
              ),
              child: Icon(
                liveKit.isMicMuted ? Icons.mic_off : Icons.mic,
                color: liveKit.isMicMuted ? Colors.redAccent : Colors.green,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // زر لعبة السلوت
          IconButton(
            icon: const Icon(Icons.casino, color: Colors.amber),
            onPressed: () => showDialog(context: context, builder: (_) => const SlotMachineDialog()),
          ),
          
          // زر لعبة القط الجشع
          IconButton(
            icon: const Icon(Icons.pets, color: Colors.orangeAccent),
            onPressed: () => showDialog(context: context, builder: (_) => const GreedyCatDialog()),
          ),
          
          const Spacer(),
          
          // زر إرسال هدية
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB800),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            icon: const Icon(Icons.card_giftcard, size: 18),
            label: const Text('إرسال هدية', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم فتح صندوق الهدايا الملكية ✨')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleSeatClick(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF191036),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        final seat = seats[index];
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'إدارة المقعد رقم ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber),
              ),
              const Divider(color: Colors.white24),
              ListTile(
                leading: const Icon(Icons.airline_seat_recline_normal, color: Colors.amber),
                title: Text(seat.isOccupied ? 'إنزال العضو' : 'الصعود على المقعد'),
                onTap: () {
                  setState(() {
                    if (seat.isOccupied) {
                      seat.isOccupied = false;
                      seat.userName = null;
                    } else {
                      seat.isOccupied = true;
                      seat.userName = 'أنا الملك';
                    }
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(seat.isLocked ? Icons.lock_open : Icons.lock, color: Colors.orange),
                title: Text(seat.isLocked ? 'فتح المقعد' : 'قفل المقعد'),
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
}

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
