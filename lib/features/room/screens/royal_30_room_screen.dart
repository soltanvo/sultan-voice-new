import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/app_config.dart';
import '../../../core/services/livekit_service.dart';
import '../../../core/services/gift_service.dart';
import '../../../features/auth/screens/royal_auth_screen.dart';
import '../models/room_seat.dart';
import '../widgets/gift_sheet.dart';
import '../widgets/seat_item_widget.dart';

class Royal30RoomScreen extends StatefulWidget {
  final String roomId;

  const Royal30RoomScreen({super.key, required this.roomId});

  @override
  State<Royal30RoomScreen> createState() => _Royal30RoomScreenState();
}

class _Royal30RoomScreenState extends State<Royal30RoomScreen> {
  static const int _seatCount = 30;

  final _client = Supabase.instance.client;
  late final GiftService _giftService = GiftService(_client);

  String _roomTitle = '';
  List<RoomSeat> _seats = const [];
  int _coins = 0;
  bool _loading = true;
  bool _busy = false;
  String? _error;

  String? get _uid => _client.auth.currentUser?.id;

  RoomSeat? get _mySeat {
    final uid = _uid;
    if (uid == null) return null;
    for (final seat in _seats) {
      if (seat.userId == uid) return seat;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final room = await _client.from('rooms').select('title').eq('id', widget.roomId).maybeSingle();
      if (room == null) {
        setState(() {
          _error = 'هذه الغرفة غير متاحة حالياً';
          _loading = false;
        });
        return;
      }

      final rows = await _client
          .from('room_seats')
          .select('seat_index, user_id, display_name, is_muted, is_locked')
          .eq('room_id', widget.roomId)
          .order('seat_index');

      final seats = rows.map((r) => RoomSeat.fromMap(r)).toList();
      if (seats.length != _seatCount) {
        setState(() {
          _error = 'بيانات المايكات غير مكتملة، يرجى المحاولة لاحقاً';
          _loading = false;
        });
        return;
      }

      final coins = await _giftService.fetchCoins(_uid!);

      if (!mounted) return;
      setState(() {
        _roomTitle = room['title'] as String;
        _seats = seats;
        _coins = coins;
        _loading = false;
      });
    } catch (e) {
      debugPrint('[Room load] $e');
      if (!mounted) return;
      setState(() {
        _error = 'تعذر تحميل الغرفة، تحقق من اتصالك وحاول مجدداً';
        _loading = false;
      });
    }
  }

  Future<String> _currentDisplayName() async {
    final uid = _uid;
    if (uid == null) return 'عضو';
    final profile = await _client.from('profiles').select('display_name').eq('id', uid).maybeSingle();
    return (profile?['display_name'] as String?) ?? 'عضو';
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _runAction(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      await _load();
    } catch (e) {
      debugPrint('[Room action] $e');
      _showMessage('تعذر تنفيذ العملية، حاول مجدداً');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _takeSeat(RoomSeat seat) async {
    final uid = _uid;
    if (uid == null) return;
    if (seat.isLocked) {
      _showMessage('هذا المايك مقفل من المشرف');
      return;
    }
    if (seat.isOccupied) {
      _showMessage('هذا المايك مشغول');
      return;
    }
    await _runAction(() async {
      final name = await _currentDisplayName();
      await _client
          .from('room_seats')
          .update({'user_id': null, 'display_name': null, 'is_muted': false})
          .eq('user_id', uid);
      final taken = await _client
          .from('room_seats')
          .update({'user_id': uid, 'display_name': name, 'is_muted': false})
          .eq('room_id', widget.roomId)
          .eq('seat_index', seat.seatIndex)
          .filter('user_id', 'is', null)
          .select();
      if (taken.isEmpty) {
        _showMessage('تم أخذ هذا المايك قبل لحظات');
        return;
      }
      await _connectVoice();
    });
  }

  Future<void> _connectVoice() async {
    final liveKit = context.read<LiveKitService>();
    try {
      final res = await _client.functions.invoke('livekit-token', body: {'roomId': widget.roomId});
      final data = res.data;
      final token = data is Map ? data['token'] as String? : null;
      if (token == null) {
        _showMessage('الصوت غير مفعّل بعد، المايك متاح للاستماع فقط');
        return;
      }
      final connected = await liveKit.connectToRoyalRoom(
        liveKitUrl: AppConfig.liveKitUrl,
        token200: token,
      );
      if (!connected) _showMessage('تعذر تشغيل المايك، تحقق من إذن الميكروفون');
    } catch (e) {
      debugPrint('[Room voice] $e');
      _showMessage('تعذر الاتصال بالصوت حالياً');
    }
  }

  Future<void> _leaveSeat() async {
    final uid = _uid;
    final mine = _mySeat;
    if (uid == null || mine == null) return;
    await _runAction(() async {
      await _client
          .from('room_seats')
          .update({'user_id': null, 'display_name': null, 'is_muted': false})
          .eq('room_id', widget.roomId)
          .eq('seat_index', mine.seatIndex)
          .eq('user_id', uid);
      if (mounted) context.read<LiveKitService>().disconnect();
    });
  }

  Future<void> _toggleMute() async {
    final uid = _uid;
    final mine = _mySeat;
    if (uid == null || mine == null) {
      _showMessage('اجلس على أحد المايكات أولاً');
      return;
    }
    final liveKit = context.read<LiveKitService>();
    final nextMuted = !mine.isMuted;
    await _runAction(() async {
      await _client
          .from('room_seats')
          .update({'is_muted': nextMuted})
          .eq('room_id', widget.roomId)
          .eq('seat_index', mine.seatIndex)
          .eq('user_id', uid);
      if (liveKit.isConnected && liveKit.isMicMuted != nextMuted) {
        await liveKit.toggleMicrophone();
      }
    });
  }

  Future<void> _openGiftSheet({int? seatIndex}) async {
    final uid = _uid;
    if (uid == null) return;
    final recipients = _seats.where((s) => s.isOccupied && s.userId != uid).toList();
    final balance = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF14082E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => GiftSheet(
        giftService: _giftService,
        roomId: widget.roomId,
        coins: _coins,
        recipients: recipients,
        initialSeatIndex: seatIndex,
      ),
    );
    if (balance == null || !mounted) return;
    setState(() => _coins = balance);
    _showMessage('تم إرسال الهدية');
  }

  Future<void> _signOut() async {
    await _client.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RoyalAuthScreen()),
      (_) => false,
    );
  }

  Future<void> _showRoomPicker() async {
    final rooms = await _client.from('rooms').select('id, title, description').order('created_at');
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF14082E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الغرف الرسمية',
                  style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                for (final room in rooms)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(room['title'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(room['description'] as String, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    trailing: room['id'] == widget.roomId
                        ? const Icon(Icons.check_circle, color: Color(0xFFFFD700))
                        : null,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      if (room['id'] == widget.roomId) return;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => Royal30RoomScreen(roomId: room['id'] as String)),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090414),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B0520), Color(0xFF070312)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _loading || _error != null ? null : _buildBottomBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF12082B),
        border: Border(bottom: BorderSide(color: Color(0x33FFD700))),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: _showRoomPicker,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _roomTitle.isEmpty ? 'جاري التحميل...' : _roomTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Color(0xFFFFD700)),
                      ],
                    ),
                    const Text(
                      '30 مايك',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'تسجيل الخروج',
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFFFD700)),
            onPressed: _signOut,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }
    final uid = _uid;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 20,
      ),
      itemCount: _seats.length,
      itemBuilder: (context, i) {
        final seat = _seats[i];
        return SeatItemWidget(
          seat: seat,
          isMine: seat.userId != null && seat.userId == uid,
          onTap: () {
            if (seat.userId != null && seat.userId == uid) {
              _showMySeatSheet(seat);
            } else if (!seat.isOccupied) {
              _takeSeat(seat);
            } else {
              _openGiftSheet(seatIndex: seat.seatIndex);
            }
          },
        );
      },
    );
  }

  void _showMySeatSheet(RoomSeat seat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF14082E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(seat.isMuted ? Icons.mic_rounded : Icons.mic_off_rounded,
                    color: seat.isMuted ? Colors.greenAccent : Colors.redAccent),
                title: Text(seat.isMuted ? 'تشغيل المايك' : 'كتم المايك',
                    style: const TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _toggleMute();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.orangeAccent),
                title: const Text('النزول من المايك', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _leaveSeat();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    final mine = _mySeat;
    final micOn = mine != null && !mine.isMuted;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF0D0621),
        border: Border(top: BorderSide(color: Color(0x1FFFFFFF))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _RoundControl(
            icon: micOn ? Icons.mic_rounded : Icons.mic_off_rounded,
            label: mine == null ? 'اجلس أولاً' : (micOn ? 'المايك مفتوح' : 'مكتوم'),
            active: micOn,
            onTap: _busy ? null : _toggleMute,
          ),
          _RoundControl(
            icon: Icons.card_giftcard_rounded,
            label: 'هدية',
            active: false,
            onTap: _busy ? null : () => _openGiftSheet(),
          ),
          _RoundControl(
            icon: Icons.logout_rounded,
            label: 'النزول',
            active: false,
            onTap: mine == null || _busy ? null : _leaveSeat,
          ),
        ],
      ),
    );
  }
}

class _RoundControl extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _RoundControl({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.4 : 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? const Color(0x2622D3EE) : const Color(0x14FFFFFF),
                border: Border.all(
                  color: active ? const Color(0xFF3B82F6) : const Color(0x33FFFFFF),
                  width: 1.5,
                ),
                boxShadow: active
                    ? const [BoxShadow(color: Color(0x663B82F6), blurRadius: 16, spreadRadius: 1)]
                    : null,
              ),
              child: Icon(
                icon,
                color: active ? const Color(0xFF22D3EE) : Colors.white70,
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
