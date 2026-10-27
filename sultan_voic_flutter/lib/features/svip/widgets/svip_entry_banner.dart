import 'package:flutter/material.dart';

class SvipEntryBanner extends StatelessWidget {
  final String userName;
  final int svipLevel; // 1: تنين برونزي, 2: بيغاسوس فضي, 3: فينيكس ملكي إمبراطوري
  final String avatarUrl;

  const SvipEntryBanner({
    super.key,
    required this.userName,
    required this.svipLevel,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    Color primaryColor;
    Color secondaryColor;
    String title;
    bool isHighTier = svipLevel >= 7;

    switch (svipLevel) {
      case 9:
        primaryColor = const Color(0xFFFFB800);
        secondaryColor = const Color(0xFF000000);
        title = '🦅 الصقر الأسود الملكي SVIP 9 (أشعة مظلمة وتوهج ناري أسود وذهبي)';
        break;
      case 8:
        primaryColor = const Color(0xFFFF9100);
        secondaryColor = const Color(0xFFFFD700);
        title = '🦅 عنقاء الشمس الإمبراطورية SVIP 8';
        break;
      case 7:
        primaryColor = const Color(0xFFFFD700);
        secondaryColor = const Color(0xFF6A0DAD);
        title = '🐉 التنين الذهبي الكوني SVIP 7';
        break;
      case 6:
        primaryColor = const Color(0xFF9D4EDD);
        secondaryColor = const Color(0xFF100720);
        title = '🖤 الألماس الأسود الفخم SVIP 6';
        break;
      case 5:
        primaryColor = const Color(0xFFFF0055);
        secondaryColor = const Color(0xFFFF8800);
        title = '🔥 الروبي الناري SVIP 5';
        break;
      case 4:
        primaryColor = const Color(0xFF00E676);
        secondaryColor = const Color(0xFF00B0FF);
        title = '❇️ الزمرد الإمبراطوري SVIP 4';
        break;
      case 3:
        primaryColor = const Color(0xFF2979FF);
        secondaryColor = const Color(0xFF651FFF);
        title = '💎 الياقوت الأزرق الملكي SVIP 3';
        break;
      case 2:
        primaryColor = const Color(0xFFE0E0E0);
        secondaryColor = const Color(0xFF7B2CBF);
        title = '⚔️ الفارس الفضي SVIP 2';
        break;
      default:
        primaryColor = const Color(0xFFCD7F32);
        secondaryColor = const Color(0xFFD4A373);
        title = '🛡️ النبيل البرونزي SVIP 1';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(isHighTier ? 16 : 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            secondaryColor.withOpacity(0.95),
            primaryColor.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(isHighTier ? 0.7 : 0.4),
            blurRadius: isHighTier ? 24 : 16,
            spreadRadius: isHighTier ? 4 : 2,
          ),
        ],
        border: Border.all(
          color: isHighTier ? Colors.amberAccent : Colors.white,
          width: isHighTier ? 2.5 : 1.5,
        ),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: isHighTier ? 26 : 22,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              if (isHighTier)
                Positioned(
                  top: -8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
                    ),
                    child: Text(
                      'SVIP $svipLevel',
                      style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isHighTier ? 14 : 12,
                  ),
                ),
                Text(
                  isHighTier
                    ? '⚡ اعتلى العرش الملكي لـ Sultan Voic بكل هيبة وفخامة!'
                    : 'وصل العضو الفخم $userName إلى مجلس Sultan Voic!',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
