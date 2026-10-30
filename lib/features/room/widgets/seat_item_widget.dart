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

  static const double _avatarSize = 56;

  @override
  Widget build(BuildContext context) {
    final borderColor = isMine
        ? const Color(0xFFFFD700)
        : (seat.isOccupied ? const Color(0xFF9D4EDD) : Colors.white24);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: _avatarSize,
                height: _avatarSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: seat.isOccupied ? const Color(0xFF2A1650) : const Color(0xFF160E30),
                  border: Border.all(color: borderColor, width: isMine ? 2.5 : 1.5),
                ),
                child: Icon(
                  seat.isLocked
                      ? Icons.lock_rounded
                      : (seat.isOccupied ? Icons.person_rounded : Icons.add_rounded),
                  color: seat.isOccupied ? Colors.white : Colors.white38,
                  size: 26,
                ),
              ),
              if (seat.isOccupied && seat.isMuted)
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.redAccent,
                    child: Icon(Icons.mic_off, size: 11, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: _avatarSize + 14,
            child: Text(
              seat.isOccupied ? (seat.displayName ?? 'عضو') : '${seat.seatIndex + 1}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: seat.isOccupied ? Colors.white : Colors.white54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
