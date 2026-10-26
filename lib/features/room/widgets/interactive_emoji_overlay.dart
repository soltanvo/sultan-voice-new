import 'package:flutter/material.dart';

enum InteractiveEmojiType {
  kiss('kiss', 'بوسة طائرة مزدوجة', '💋', 'تطير وتطبع القبلة ثم تقفز للمقعد المجاور'),
  laugh('laugh', 'ضحك هستيري', '🤣', 'انفجار ضحك مع دموع متناثرة'),
  cry('cry', 'شلال دموع', '😭', 'شلال دموع يفيض من المقعد'),
  danceBride('dance_bride', 'رقص العروسة باللباس الأحمر', '💃', 'رقص احتفالي مع زينة ملونة'),
  shisha('shisha', 'شيشة فاخرة', '💨', 'سحب دخان ملكية متتابعة'),
  toddler('toddler', 'ولد صغير بامبرز', '👶', 'حركات طريفة ولطيفة');

  final String id;
  final String title;
  final String emoji;
  final String description;

  const InteractiveEmojiType(this.id, this.title, this.emoji, this.description);
}

class InteractiveEmojiEvent {
  final String id;
  final InteractiveEmojiType type;
  final int senderSeatIndex;
  final int targetSeatIndex;
  final int? secondaryTargetSeatIndex;

  InteractiveEmojiEvent({
    required this.id,
    required this.type,
    required this.senderSeatIndex,
    required this.targetSeatIndex,
    this.secondaryTargetSeatIndex,
  });
}

class InteractiveEmojiOverlay extends StatelessWidget {
  final List<InteractiveEmojiEvent> activeEvents;
  final VoidCallback onDismiss;

  const InteractiveEmojiOverlay({
    super.key,
    required this.activeEvents,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (activeEvents.isEmpty) return const SizedBox.shrink();

    return IgnorePointer(
      child: Stack(
        children: activeEvents.map((event) {
          return Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 2500),
              onEnd: onDismiss,
              builder: (context, val, child) {
                if (event.type == InteractiveEmojiType.kiss) {
                  final phase = val < 0.5 ? val * 2 : (val - 0.5) * 2;
                  final isPrimary = val < 0.5;

                  return Transform.translate(
                    offset: Offset(
                      isPrimary ? (1 - phase) * 80 : -(1 - phase) * 80,
                      -phase * 60,
                    ),
                    child: Transform.scale(
                      scale: 1.0 + (phase < 0.5 ? phase * 0.8 : (1 - phase) * 0.8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('💋', style: TextStyle(fontSize: 54)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.pinkAccent.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isPrimary ? 'قبلة ملكية إلى مقعد ${event.targetSeatIndex + 1} 💖' : 'قفزة القبلة للمقعد المجاور! 😘',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Transform.scale(
                  scale: (1.0 + val * 0.4).clamp(0.0, 1.4),
                  child: Opacity(
                    opacity: (1.0 - (val - 0.6).clamp(0.0, 0.4) / 0.4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(event.type.emoji, style: const TextStyle(fontSize: 60)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F123A).withOpacity(0.95),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFFB800), width: 1),
                          ),
                          child: Text(
                            '${event.type.title} على مقعد ${event.targetSeatIndex + 1}',
                            style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
