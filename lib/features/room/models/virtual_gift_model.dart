class VirtualGiftItem {
  final String id;
  final String name;
  final String icon;
  final int coins;
  final int durationSeconds;
  final String? videoUrl;
  final String themeColor;
  final String description;

  const VirtualGiftItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.coins,
    required this.durationSeconds,
    this.videoUrl,
    required this.themeColor,
    required this.description,
  });
}

class ActiveGiftEvent {
  final String id;
  final VirtualGiftItem gift;
  final String senderName;
  final String senderAvatar;
  final int targetSeatIndex;
  final String targetSeatName;
  final DateTime timestamp;

  ActiveGiftEvent({
    required this.id,
    required this.gift,
    required this.senderName,
    required this.senderAvatar,
    required this.targetSeatIndex,
    required this.targetSeatName,
    required this.timestamp,
  });
}

const List<VirtualGiftItem> OFFICIAL_VIRTUAL_GIFTS = [
  VirtualGiftItem(
    id: 'sultan_dragon',
    name: 'تنين الإمبراطور الأسطوري 🐉',
    icon: '🐉',
    coins: 50000,
    durationSeconds: 12,
    videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-fire-breathing-dragon-sculpture-at-night-42416-large.mp4',
    themeColor: '#FF4500',
    description: 'تنين أسطوري ينفث ألسنة اللهب في أرجاء الغرفة ويهز الشاشة',
  ),
  VirtualGiftItem(
    id: 'galaxy_rocket',
    name: 'صاروخ المجرة الملكي 🚀',
    icon: '🚀',
    coins: 75000,
    durationSeconds: 14,
    videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-flying-through-a-starry-galaxy-space-background-30510-large.mp4',
    themeColor: '#9333EA',
    description: 'انفجار كوني مذهل يجوب المجرة مع مؤثرات صوتية وبصرية خارقة',
  ),
  VirtualGiftItem(
    id: 'sultan_castle',
    name: 'قصر السلطان الذهبي 🏰',
    icon: '🏰',
    coins: 100000,
    durationSeconds: 14,
    videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-golden-particles-sparkling-in-the-air-42352-large.mp4',
    themeColor: '#F59E0B',
    description: 'أفخم هدية ملكية تعتلي عرش الغرفة مع أمطار من الذهب',
  ),
  VirtualGiftItem(
    id: 'royal_supercar',
    name: 'سيارة بوجاتي رويال 🏎️',
    icon: '🏎️',
    coins: 40000,
    durationSeconds: 8,
    videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-luxury-sports-car-driving-at-night-43285-large.mp4',
    themeColor: '#00F5D4',
    description: 'سيارة سوبركار فاخرة تدور في ساحة الغرفة بصوت محرك جبار',
  ),
  VirtualGiftItem(
    id: 'golden_pegasus',
    name: 'بيجاسوس الأجنحة الملكية 🦄',
    icon: '🦄',
    coins: 30000,
    durationSeconds: 8,
    videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-glowing-magic-dust-floating-in-dark-space-42371-large.mp4',
    themeColor: '#EC4899',
    description: 'حصان مجنح سحري يحلق بين المقاعد وينثر غبار الماس',
  ),
  VirtualGiftItem(
    id: 'imperial_crown',
    name: 'تاج الملوك المرصع 👑',
    icon: '👑',
    coins: 20000,
    durationSeconds: 8,
    videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-diamonds-falling-and-rotating-42408-large.mp4',
    themeColor: '#EAB308',
    description: 'تاج إمبراطوري يهبط على رأس المستهدف مع ألعاب نارية',
  ),
];
