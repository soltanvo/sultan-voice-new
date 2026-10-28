import 'package:flutter/material.dart';
import '../screens/royal_30_room_screen.dart';

class SeatItemWidget extends StatelessWidget {
  final SeatData seat;
  final bool isThrone;
  final double? customSize;
  final VoidCallback onTap;

  const SeatItemWidget({
    super.key,
    required this.seat,
    this.isThrone = false,
    this.customSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double avatarSize = customSize ?? (isThrone ? 68.0 : 44.0);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // حلقة التحدث النشطة (Speaking Pulse Aura)
              if (seat.isOccupied && !seat.isMuted)
                Container(
                  width: avatarSize + 10,
                  height: avatarSize + 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFD700).withOpacity(0.6),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),

              // إطار المقعد (ذهبي إمبراطوري للعرش، متدرج للـ SVIP، أو رمادي أنيق للمتاح)
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isThrone
                      ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)])
                      : (seat.isOccupied
                          ? _getSvipGradient(seat.svipLevel)
                          : null),
                  color: seat.isOccupied ? null : const Color(0xFF160E30),
                  border: Border.all(
                    color: isThrone
                        ? const Color(0xFFFFD700)
                        : (seat.isOccupied ? _getSvipBorderColor(seat.svipLevel) : Colors.white24),
                    width: isThrone ? 2.5 : (seat.isOccupied ? 2.0 : 1.2),
                  ),
                  boxShadow: seat.isOccupied
                      ? [
                          BoxShadow(
                            color: _getSvipBorderColor(seat.svipLevel).withOpacity(0.35),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: seat.isOccupied
                    ? ClipOval(
                        child: seat.avatarUrl != null && seat.avatarUrl!.isNotEmpty
                            ? Image.network(
                                seat.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white70),
                              )
                            : const Icon(Icons.person, color: Colors.white70),
                      )
                    : Icon(
                        seat.isLocked ? Icons.lock : Icons.mic_none,
                        color: Colors.white38,
                        size: avatarSize * 0.42,
                      ),
              ),

              // تاج الـ SVIP الملكي
              if (seat.isOccupied && seat.svipLevel > 0)
                Positioned(
                  top: -10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8800)]),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars, color: Colors.black, size: 8),
                        const SizedBox(width: 2),
                        Text(
                          'SVIP${seat.svipLevel}',
                          style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),

              // مؤشر المايك المكتوم
              if (seat.isOccupied && seat.isMuted)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 4)],
                    ),
                    child: const Icon(Icons.mic_off, size: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),

          // اسم المستخدم أو رقم المقعد
          SizedBox(
            width: avatarSize + 16,
            child: Text(
              seat.isOccupied ? (seat.userName ?? 'عضو') : 'مايك ${seat.seatIndex + 1}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isThrone ? 11 : 9.5,
                fontWeight: isThrone ? FontWeight.bold : FontWeight.w600,
                color: isThrone ? const Color(0xFFFFD700) : (seat.isOccupied ? Colors.white : Colors.white54),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getSvipGradient(int level) {
    if (level >= 9) {
      return const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFF1A1A1A)]);
    } else if (level >= 7) {
      return const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFF7B2CBF)]);
    } else if (level >= 4) {
      return const LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00B0FF)]);
    }
    return const LinearGradient(colors: [Color(0xFF9D4EDD), Color(0xFF5A189A)]);
  }

  Color _getSvipBorderColor(int level) {
    if (level >= 9) return const Color(0xFFFFD700);
    if (level >= 7) return const Color(0xFFFFB800);
    if (level >= 4) return const Color(0xFF00E676);
    return const Color(0xFFC77DFF);
  }
}
