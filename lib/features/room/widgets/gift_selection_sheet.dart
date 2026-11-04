import 'package:flutter/material.dart';
import '../models/virtual_gift_model.dart';
import '../screens/royal_30_room_screen.dart';

class GiftSelectionSheet extends StatefulWidget {
  final List<SeatData> seats;
  final Function(VirtualGiftItem gift, int targetSeatIndex, String targetSeatName) onSendGift;

  const GiftSelectionSheet({
    super.key,
    required this.seats,
    required this.onSendGift,
  });

  @override
  State<GiftSelectionSheet> createState() => _GiftSelectionSheetState();
}

class _GiftSelectionSheetState extends State<GiftSelectionSheet> {
  VirtualGiftItem selectedGift = OFFICIAL_VIRTUAL_GIFTS[0];
  int selectedSeatIndex = 0;

  @override
  Widget build(BuildContext context) {
    final targetSeat = widget.seats[selectedSeatIndex];
    final targetName = targetSeat.isOccupied
        ? (targetSeat.userName ?? 'المقعد ${selectedSeatIndex + 1}')
        : 'المقعد ${selectedSeatIndex + 1} (فارغ)';

    return Container(
      height: 480,
      decoration: const BoxDecoration(
        color: Color(0xFF140A26),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFFFFB800), width: 1.5)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.card_giftcard, color: Color(0xFFFFB800)),
                const SizedBox(width: 8),
                const Text(
                  'متجر الهدايا السينمائية الفاخرة (Full Screen HD)',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF261848),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFB800), width: 0.8),
                  ),
                  child: const Row(
                    children: [
                      Text('🪙', style: TextStyle(fontSize: 12)),
                      SizedBox(width: 4),
                      Text('2,450,000', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.seats.length,
              itemBuilder: (context, i) {
                final isSelected = selectedSeatIndex == i;
                final seat = widget.seats[i];
                final label = i == 0 ? '👑 العرش' : '${i + 1}';

                return GestureDetector(
                  onTap: () => setState(() => selectedSeatIndex = i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(colors: [Color(0xFFFFB800), Color(0xFFFF8800)])
                          : null,
                      color: isSelected ? null : const Color(0xFF20133D),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? Colors.white : (seat.isOccupied ? const Color(0xFFC084FC) : Colors.white24),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: OFFICIAL_VIRTUAL_GIFTS.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final gift = OFFICIAL_VIRTUAL_GIFTS[index];
                final isSelected = selectedGift.id == gift.id;

                return GestureDetector(
                  onTap: () => setState(() => selectedGift = gift),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF381A64) : const Color(0xFF1E1238),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFFFB800) : Colors.white12,
                        width: isSelected ? 2.0 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [const BoxShadow(color: Color(0xFFFFB800), blurRadius: 10)]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(gift.icon, style: const TextStyle(fontSize: 34)),
                        const SizedBox(height: 4),
                        Text(
                          gift.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🪙', style: TextStyle(fontSize: 10)),
                            const SizedBox(width: 2),
                            Text(
                              '${gift.coins}',
                              style: const TextStyle(color: Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${gift.durationSeconds}ث)',
                              style: const TextStyle(color: Colors.white54, fontSize: 9),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF0F061E),
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'إرسال ${selectedGift.name}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        'إلى: $targetName',
                        style: const TextStyle(color: Color(0xFF00F5D4), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB800),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: Text('إرسال (${selectedGift.coins} كوينز)', style: const TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onSendGift(selectedGift, selectedSeatIndex, targetName);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
