import 'package:flutter/material.dart';
import '../screens/royal_30_room_screen.dart';

class SeatItemWidget extends StatelessWidget {
  final SeatData seat;
  final bool isThrone;
  final VoidCallback onTap;

  const SeatItemWidget({
    super.key,
    required this.seat,
    this.isThrone = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double avatarSize = isThrone ? 68.0 : 42.0;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // إطار المقعد (ذهبي للعرش، برونزي/بنفسجي للبقية)
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isThrone
                      ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)])
                      : (seat.isOccupied
                          ? const LinearGradient(colors: [Color(0xFF9D4EDD), Color(0xFF5A189A)])
                          : null),
                  color: seat.isOccupied ? null : const Color(0xFF1D1438),
                  border: Border.all(
                    color: isThrone
                        ? const Color(0xFFFFD700)
                        : (seat.isOccupied ? const Color(0xFFC77DFF) : Colors.white24),
                    width: isThrone ? 2.5 : 1.2,
                  ),
                ),
                child: seat.isOccupied
                    ? ClipOval(
                        child: seat.avatarUrl != null
                            ? Image.network(seat.avatarUrl!, fit: BoxFit.cover)
                            : const Icon(Icons.person, color: Colors.white70),
                      )
                    : Icon(
                        seat.isLocked ? Icons.lock : Icons.mic_none,
                        color: Colors.white38,
                        size: isThrone ? 26 : 18,
                      ),
              ),

              // تاج الـ SVIP إذا كان للمستخدم مستوى
              if (seat.isOccupied && seat.svipLevel > 0)
                Positioned(
                  top: isThrone ? -14 : -10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8800)]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'SVIP${seat.svipLevel}',
                      style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

              // شارة المايك المكتوم
              if (seat.isOccupied && seat.isMuted)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                    child: const Icon(Icons.mic_off, size: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          // اسم المستخدم أو رقم المقعد
          Text(
            seat.isOccupied ? (seat.userName ?? 'عضو') : '${seat.seatIndex + 1}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isThrone ? 12 : 10,
              fontWeight: isThrone ? FontWeight.bold : FontWeight.normal,
              color: isThrone ? const Color(0xFFFFD700) : (seat.isOccupied ? Colors.white : Colors.white38),
            ),
          ),
        ],
      ),
    );
  }
}
