import 'package:flutter/material.dart';

class FloatingLuckyBoxBar extends StatelessWidget {
  final String? globalRocketBroadcast;
  final int activeBoxesCount;
  final VoidCallback onClaimBox;
  final VoidCallback onJumpToRocketRoom;

  const FloatingLuckyBoxBar({
    super.key,
    this.globalRocketBroadcast,
    this.activeBoxesCount = 0,
    required this.onClaimBox,
    required this.onJumpToRocketRoom,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (globalRocketBroadcast != null)
          GestureDetector(
            onTap: onJumpToRocketRoom,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFDC2626), Color(0xFF9333EA), Color(0xFFF59E0B)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFFF0055), blurRadius: 12, spreadRadius: 1),
                ],
                border: Border.all(color: Colors.white, width: 1.2),
              ),
              child: Row(
                children: [
                  const Text('🚀💥', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      globalRocketBroadcast!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'انتقال سريع ⚡',
                      style: TextStyle(color: Color(0xFFDC2626), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (activeBoxesCount > 0)
          GestureDetector(
            onTap: onClaimBox,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF854D0E), Color(0xFFB45309), Color(0xFFD97706)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFDE047), width: 1),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFFFB800), blurRadius: 8),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🧧', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    'هناك $activeBoxesCount ظروف كوينز عائمة في الغرفة!',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE047),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'التقاط 🪙',
                      style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
