import 'package:flutter/material.dart';
import '../models/room_seat.dart';

class SeatItemWidget extends StatelessWidget {
  final RoomSeat seat;
  final bool isMine;
  final VoidCallback onTap;

  const SeatItemWidget({
    super.key,
    required this.seat,
    required this.isMine,
    required this.onTap,
  });

  static const double _avatarSize = 60;
  static const double _ringWidth = 2.5;

  static const LinearGradient _neonRing = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFF3B82F6), Color(0xFF22D3EE)],
  );

  static const LinearGradient _goldRing = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
  );

  @override
  Widget build(BuildContext context) {
    final ring = isMine ? _goldRing : (seat.isOccupied ? _neonRing : null);
    final labelColor = isMine
        ? const Color(0xFFFFD700)
        : (seat.isOccupied ? Colors.white : Colors.white54);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: _avatarSize + _ringWidth * 2,
                height: _avatarSize + _ringWidth * 2,
                padding: const EdgeInsets.all(_ringWidth),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: ring,
                  color: ring == null ? const Color(0xFF1A1433) : null,
                  boxShadow: seat.isOccupied && !seat.isMuted
                      ? [
                          BoxShadow(
                            color: (isMine ? const Color(0xFFFFD700) : const Color(0xFF3B82F6))
                                .withOpacity(0.55),
                            blurRadius: 14,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Container(
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF0E0A1F),
                  ),
                  child: Icon(
                    seat.isLocked
                        ? Icons.lock_rounded
                        : (seat.isOccupied ? Icons.person_rounded : Icons.add_rounded),
                    color: seat.isOccupied ? Colors.white : Colors.white38,
                    size: 26,
                  ),
                ),
              ),
              if (seat.isOccupied && seat.isMuted)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF0E0A1F), width: 2),
                    ),
                    child: const Icon(Icons.mic_off, size: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: _avatarSize + 16,
            child: Text(
              seat.isOccupied ? (seat.displayName ?? 'عضو') : '${seat.seatIndex + 1}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
