import 'package:flutter/material.dart';

enum MagicKravatTier {
  amethyst(1, 'كرافتة الجمشت الملكي', Color(0xFFC084FC), Color(0xFF7E22CE), '💎'),
  sapphire(2, 'كرافتة الياقوت الأزرق', Color(0xFF38BDF8), Color(0xFF0369A1), '💠'),
  emerald(3, 'كرافتة الزمرد الساحر', Color(0xFF34D399), Color(0xFF047857), '❇️'),
  imperialGold(4, 'كرافتة الذهب الإمبراطوري', Color(0xFFFDE047), Color(0xFFB45309), '👑'),
  cosmicSultan(5, 'كرافتة السلطان الكونية', Color(0xFFF43F5E), Color(0xFF7C3AED), '🔥');

  final int tier;
  final String title;
  final Color primaryColor;
  final Color secondaryColor;
  final String icon;

  const MagicKravatTier(this.tier, this.title, this.primaryColor, this.secondaryColor, this.icon);
}

class MagicKravatWidget extends StatelessWidget {
  final int tier;
  final double size;
  final bool showBadgeLabel;
  final String? adminBadge;

  const MagicKravatWidget({
    super.key,
    required this.tier,
    this.size = 28.0,
    this.showBadgeLabel = false,
    this.adminBadge,
  });

  @override
  Widget build(BuildContext context) {
    final activeTier = MagicKravatTier.values.firstWhere(
      (t) => t.tier == tier.clamp(1, 5),
      orElse: () => MagicKravatTier.amethyst,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size * 1.3,
              height: size * 1.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: activeTier.primaryColor.withOpacity(0.55),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            CustomPaint(
              size: Size(size, size * 1.35),
              painter: _MagicKravatPainter(
                primaryColor: activeTier.primaryColor,
                secondaryColor: activeTier.secondaryColor,
              ),
            ),
            Positioned(
              top: size * 0.1,
              child: Container(
                width: size * 0.32,
                height: size * 0.32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.white, activeTier.primaryColor, activeTier.secondaryColor],
                  ),
                  boxShadow: [
                    BoxShadow(color: activeTier.primaryColor, blurRadius: 6),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (showBadgeLabel) ...[
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [activeTier.secondaryColor.withOpacity(0.85), activeTier.primaryColor.withOpacity(0.85)],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white38, width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(activeTier.icon, style: const TextStyle(fontSize: 10)),
                const SizedBox(width: 3),
                Text(
                  activeTier.title,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
        if (adminBadge != null) ...[
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF0369A1)]),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF38BDF8), width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, size: 10, color: Color(0xFF38BDF8)),
                const SizedBox(width: 2),
                Text(
                  adminBadge == 'agent'
                      ? 'وكيل شحن معتمد ⚡'
                      : adminBadge == 'super_admin'
                          ? 'سوبر أدمن 👑'
                          : 'مشرف عام 🛡️',
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _MagicKravatPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  _MagicKravatPainter({required this.primaryColor, required this.secondaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final knotPath = Path();
    knotPath.moveTo(w * 0.25, 0);
    knotPath.lineTo(w * 0.75, 0);
    knotPath.lineTo(w * 0.65, h * 0.28);
    knotPath.lineTo(w * 0.35, h * 0.28);
    knotPath.close();

    final knotPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withOpacity(0.8), primaryColor, secondaryColor],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.3));

    canvas.drawPath(knotPath, knotPaint);

    final bodyPath = Path();
    bodyPath.moveTo(w * 0.38, h * 0.27);
    bodyPath.lineTo(w * 0.62, h * 0.27);
    bodyPath.lineTo(w * 0.82, h * 0.78);
    bodyPath.lineTo(w * 0.50, h);
    bodyPath.lineTo(w * 0.18, h * 0.78);
    bodyPath.close();

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [primaryColor, secondaryColor, const Color(0xFF0B041A)],
      ).createShader(Rect.fromLTWH(0, h * 0.27, w, h * 0.73));

    canvas.drawPath(bodyPath, bodyPaint);

    final sheenPath = Path();
    sheenPath.moveTo(w * 0.50, h * 0.28);
    sheenPath.lineTo(w * 0.50, h * 0.95);
    final sheenPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    canvas.drawPath(sheenPath, sheenPaint);
  }

  @override
  bool shouldRepaint(covariant _MagicKravatPainter oldDelegate) =>
      oldDelegate.primaryColor != primaryColor || oldDelegate.secondaryColor != secondaryColor;
}
