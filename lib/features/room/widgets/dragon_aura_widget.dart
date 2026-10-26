import 'dart:math' as math;
import 'package:flutter/material.dart';

class DragonAuraWidget extends StatefulWidget {
  final Widget child;
  final double radius;
  final bool isEnabled;

  const DragonAuraWidget({
    super.key,
    required this.child,
    this.radius = 48.0,
    this.isEnabled = true,
  });

  @override
  State<DragonAuraWidget> createState() => _DragonAuraWidgetState();
}

class _DragonAuraWidgetState extends State<DragonAuraWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _controller.value * 2 * math.pi;

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: widget.radius * 2 + 24,
              height: widget.radius * 2 + 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF5E00).withOpacity(0.4),
                    blurRadius: 18,
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: const Color(0xFFFFB800).withOpacity(0.3),
                    blurRadius: 28,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
            CustomPaint(
              size: Size(widget.radius * 2 + 20, widget.radius * 2 + 20),
              painter: _DragonFlamesRingPainter(rotationAngle: angle),
            ),
            widget.child,
            Positioned(
              left: widget.radius + math.cos(angle) * (widget.radius + 6) - 10,
              top: widget.radius + math.sin(angle) * (widget.radius + 6) - 10,
              child: Transform.rotate(
                angle: angle + math.pi / 2,
                child: const Text('🐉', style: TextStyle(fontSize: 20)),
              ),
            ),
            Positioned(
              bottom: -10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF0055), Color(0xFFFF8800), Color(0xFFFFD700)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFFFF4500), blurRadius: 10),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🔥', style: TextStyle(fontSize: 10)),
                    SizedBox(width: 2),
                    Text(
                      'وهج التنين',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DragonFlamesRingPainter extends CustomPainter {
  final double rotationAngle;

  _DragonFlamesRingPainter({required this.rotationAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..shader = SweepGradient(
        startAngle: 0.0,
        endAngle: 2 * math.pi,
        transform: GradientRotation(rotationAngle),
        colors: const [
          Color(0x00FF4500),
          Color(0x80FF7700),
          Color(0xFFFFB800),
          Color(0xFFFF1E00),
          Color(0x00FF4500),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _DragonFlamesRingPainter oldDelegate) =>
      oldDelegate.rotationAngle != rotationAngle;
}
