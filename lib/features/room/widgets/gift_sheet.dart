import 'package:flutter/material.dart';
import '../../../core/services/gift_service.dart';
import '../models/gift.dart';
import '../models/room_seat.dart';

const Color _gold = Color(0xFFFFD700);

class GiftSheet extends StatefulWidget {
  final GiftService giftService;
  final String roomId;
  final int coins;
  final List<RoomSeat> recipients;
  final int? initialSeatIndex;

  const GiftSheet({
    super.key,
    required this.giftService,
    required this.roomId,
    required this.coins,
    required this.recipients,
    this.initialSeatIndex,
  });

  @override
  State<GiftSheet> createState() => _GiftSheetState();
}

class _GiftSheetState extends State<GiftSheet> {
  List<Gift> _gifts = const [];
  bool _loadingGifts = true;
  bool _sending = false;
  String? _loadError;
  String? _sendError;
  Gift? _selectedGift;
  int? _selectedSeat;

  @override
  void initState() {
    super.initState();
    _selectedSeat = widget.initialSeatIndex;
    _loadGifts();
  }

  Future<void> _loadGifts() async {
    setState(() {
      _loadingGifts = true;
      _loadError = null;
    });
    try {
      final gifts = await widget.giftService.fetchGifts();
      if (!mounted) return;
      setState(() {
        _gifts = gifts;
        _loadingGifts = false;
      });
    } catch (e) {
      debugPrint('[Gift load] $e');
      if (!mounted) return;
      setState(() {
        _loadError = 'تعذر تحميل الهدايا، تحقق من اتصالك';
        _loadingGifts = false;
      });
    }
  }

  Future<void> _send() async {
    final gift = _selectedGift;
    final seat = _selectedSeat;
    if (gift == null || seat == null) return;
    setState(() {
      _sending = true;
      _sendError = null;
    });
    try {
      final balance = await widget.giftService.sendGift(
        roomId: widget.roomId,
        seatIndex: seat,
        gift: gift,
      );
      if (!mounted) return;
      Navigator.of(context).pop(balance);
    } on GiftException catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _sendError = e.message;
      });
    } catch (e) {
      debugPrint('[Gift send] $e');
      if (!mounted) return;
      setState(() {
        _sending = false;
        _sendError = 'تعذر إرسال الهدية، حاول مجدداً';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildRecipients(),
              const SizedBox(height: 20),
              _buildGifts(),
              if (_sendError != null) ...[
                const SizedBox(height: 12),
                Text(
                  _sendError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ],
              const SizedBox(height: 16),
              _buildSendButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'إرسال هدية',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0x1AFFD700),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x66FFD700)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.monetization_on_rounded, color: _gold, size: 16),
              const SizedBox(width: 6),
              Text(
                '${widget.coins}',
                style: const TextStyle(color: _gold, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecipients() {
    final label = const Text(
      'اختر المستلم',
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
    );
    if (widget.recipients.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label,
          const SizedBox(height: 8),
          const Text(
            'لا يوجد أعضاء على المايكات الآن',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label,
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final seat in widget.recipients)
              ChoiceChip(
                label: Text(
                  '${seat.seatIndex + 1} · ${seat.displayName ?? 'عضو'}',
                  overflow: TextOverflow.ellipsis,
                ),
                selected: _selectedSeat == seat.seatIndex,
                onSelected: _sending ? null : (_) => setState(() => _selectedSeat = seat.seatIndex),
                selectedColor: _gold,
                backgroundColor: const Color(0x14FFFFFF),
                side: BorderSide.none,
                labelStyle: TextStyle(
                  color: _selectedSeat == seat.seatIndex ? Colors.black : Colors.white70,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildGifts() {
    if (_loadingGifts) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: _gold),
        ),
      );
    }
    if (_loadError != null) {
      return Column(
        children: [
          Text(_loadError!, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          TextButton(
            onPressed: _loadGifts,
            child: const Text('إعادة المحاولة', style: TextStyle(color: _gold)),
          ),
        ],
      );
    }
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 12,
      crossAxisSpacing: 10,
      childAspectRatio: 0.78,
      children: [
        for (final gift in _gifts)
          _GiftCard(
            gift: gift,
            selected: _selectedGift?.id == gift.id,
            onTap: _sending ? null : () => setState(() => _selectedGift = gift),
          ),
      ],
    );
  }

  Widget _buildSendButton() {
    final gift = _selectedGift;
    final seat = _selectedSeat;
    final affordable = gift != null && widget.coins >= gift.priceCoins;
    final ready = gift != null && seat != null && affordable && !_sending;

    final String label;
    if (gift == null) {
      label = 'اختر هدية';
    } else if (seat == null) {
      label = 'اختر المستلم';
    } else if (!affordable) {
      label = 'رصيدك غير كافٍ';
    } else {
      label = 'إرسال ${gift.name} · ${gift.priceCoins}';
    }

    return GestureDetector(
      onTap: ready ? _send : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: ready
              ? const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF3B82F6)])
              : null,
          color: ready ? null : const Color(0x14FFFFFF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: _sending
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Text(
                label,
                style: TextStyle(
                  color: ready ? Colors.white : Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
      ),
    );
  }
}

class _GiftCard extends StatelessWidget {
  final Gift gift;
  final bool selected;
  final VoidCallback? onTap;

  const _GiftCard({required this.gift, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selected ? const Color(0x26FFD700) : const Color(0x0FFFFFFF),
          border: Border.all(
            color: selected ? _gold : const Color(0x1FFFFFFF),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_iconFor(gift.iconKey), color: _gold, size: 30),
            const SizedBox(height: 6),
            Text(
              gift.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              '${gift.priceCoins}',
              style: const TextStyle(color: _gold, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _iconFor(String key) {
  switch (key) {
    case 'rose':
      return Icons.local_florist_rounded;
    case 'heart':
      return Icons.favorite_rounded;
    case 'star':
      return Icons.star_rounded;
    case 'crown':
      return Icons.workspace_premium_rounded;
    case 'diamond':
      return Icons.diamond_rounded;
    case 'rocket':
      return Icons.rocket_launch_rounded;
    default:
      return Icons.card_giftcard_rounded;
  }
}
