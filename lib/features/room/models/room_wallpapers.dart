class RoomWallpaperItem {
  final String id;
  final String name;
  final String category;
  final String previewGradient;
  final int coinPrice;
  final bool isDefaultFree;

  const RoomWallpaperItem({
    required this.id,
    required this.name,
    required this.category,
    required this.previewGradient,
    this.coinPrice = 0,
    this.isDefaultFree = false,
  });
}

const List<RoomWallpaperItem> ROOM_WALLPAPERS = [
  RoomWallpaperItem(id: 'royal_amethyst', name: 'عرش البنفسج الإمبراطوري', category: 'royal', previewGradient: 'radial-gradient(circle, #2E1065 0%, #0F051D 100%)', isDefaultFree: true),
  RoomWallpaperItem(id: 'royal_gold', name: 'قصر الذهب والياقوت', category: 'royal', previewGradient: 'radial-gradient(circle, #451A03 0%, #090200 100%)', isDefaultFree: true),
  RoomWallpaperItem(id: 'royal_emerald', name: 'واحة الزمرد الملكية', category: 'royal', previewGradient: 'radial-gradient(circle, #064E3B 0%, #022016 100%)', isDefaultFree: true),
  RoomWallpaperItem(id: 'royal_sapphire', name: 'ديوان الأزرق العميق', category: 'royal', previewGradient: 'radial-gradient(circle, #0C4A6E 0%, #031726 100%)', isDefaultFree: true),
  RoomWallpaperItem(id: 'royal_velvet', name: 'المخمل الأسود والذهب', category: 'royal', previewGradient: 'radial-gradient(circle, #1F1724 0%, #0A080C 100%)', isDefaultFree: true),
  RoomWallpaperItem(id: 'romantic_sunset', name: 'غروب الشوق الوردي', category: 'romantic', previewGradient: 'linear-gradient(135deg, #4C0519 0%, #1A0208 100%)', isDefaultFree: true),
  RoomWallpaperItem(id: 'romantic_cherry', name: 'أزهار الكرز الليلي', category: 'romantic', previewGradient: 'linear-gradient(135deg, #701A75 0%, #200424 100%)', isDefaultFree: true),
  RoomWallpaperItem(id: 'romantic_candle', name: 'شموع الأمسيات الدافئة', category: 'romantic', previewGradient: 'linear-gradient(135deg, #7C2D12 0%, #1D0602 100%)', isDefaultFree: true),
  RoomWallpaperItem(id: 'romantic_starlight', name: 'شرفة العشاق الهادئة', category: 'romantic', previewGradient: 'linear-gradient(135deg, #431407 0%, #0F0301 100%)', isDefaultFree: true),
  RoomWallpaperItem(id: 'calm_midnight_ocean', name: 'أمواج المحيط الليلي', category: 'calm', previewGradient: 'linear-gradient(180deg, #082F49 0%, #02131F 100%)', isDefaultFree: true),
  RoomWallpaperItem(id: 'calm_nebula', name: 'سديم النجوم الهادئ', category: 'calm', previewGradient: 'radial-gradient(circle, #3B0764 0%, #0D0117 100%)', isDefaultFree: true),
  RoomWallpaperItem(id: 'calm_bamboo_mist', name: 'ضباب الخيزران الفضي', category: 'calm', previewGradient: 'linear-gradient(180deg, #134E4A 0%, #041B19 100%)', isDefaultFree: true),
  RoomWallpaperItem(id: 'calm_desert_night', name: 'سكينة الصحراء المقمرة', category: 'calm', previewGradient: 'linear-gradient(180deg, #1E1B4B 0%, #09081E 100%)', isDefaultFree: true),
  RoomWallpaperItem(id: 'mythic_dragon_lair', name: 'عرين التنين الأسطوري 🔥', category: 'mythic_coins', previewGradient: 'radial-gradient(circle, #7F1D1D 0%, #240505 100%)', coinPrice: 5000, isDefaultFree: false),
  RoomWallpaperItem(id: 'mythic_celestial_temple', name: 'معبد النجوم السماوي 🌌', category: 'mythic_coins', previewGradient: 'radial-gradient(circle, #311042 0%, #0C0212 100%)', coinPrice: 10000, isDefaultFree: false),
  RoomWallpaperItem(id: 'mythic_phoenix_rebirth', name: 'لهيب طائر الفينيق 🪶', category: 'mythic_coins', previewGradient: 'radial-gradient(circle, #78350F 0%, #1F0B02 100%)', coinPrice: 15000, isDefaultFree: false),
  RoomWallpaperItem(id: 'mythic_cyber_sultan', name: 'عرش السلطان النيوني ⚡', category: 'mythic_coins', previewGradient: 'radial-gradient(circle, #0F766E 0%, #031D1B 100%)', coinPrice: 20000, isDefaultFree: false),
  RoomWallpaperItem(id: 'mythic_black_diamond', name: 'ألماس الملوك الأسود 💎', category: 'mythic_coins', previewGradient: 'radial-gradient(circle, #18181B 0%, #050506 100%)', coinPrice: 30000, isDefaultFree: false),
];
