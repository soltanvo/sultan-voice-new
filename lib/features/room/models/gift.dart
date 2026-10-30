class Gift {
  final String id;
  final String name;
  final int priceCoins;
  final String iconKey;

  const Gift({
    required this.id,
    required this.name,
    required this.priceCoins,
    required this.iconKey,
  });

  factory Gift.fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'] as String,
      name: map['name'] as String,
      priceCoins: map['price_coins'] as int,
      iconKey: map['icon_key'] as String,
    );
  }
}
