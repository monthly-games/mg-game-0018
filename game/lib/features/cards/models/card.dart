enum CardType { boost, attack, defense }

enum CardRarity { common, rare, epic, legendary }

class RacingCard {
  final String id;
  final String name;
  final String description;
  final CardType type;
  final CardRarity rarity;

  final double effectValue; // Multiplier (e.g., 1.2 for 20% boost)
  final int level;

  const RacingCard({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.rarity,
    required this.effectValue,
    this.level = 1,
  });

  double get effectiveValue => effectValue * (1 + (level - 1) * 0.1);

  Map<String, dynamic> toJson() {
    return {'id': id, 'level': level};
  }

  factory RacingCard.fromJson(Map<String, dynamic> json, RacingCard baseData) {
    return RacingCard(
      id: baseData.id,
      name: baseData.name,
      description: baseData.description,
      type: baseData.type,
      rarity: baseData.rarity,
      effectValue: baseData.effectValue,
      level: json['level'] ?? 1,
    );
  }
}
