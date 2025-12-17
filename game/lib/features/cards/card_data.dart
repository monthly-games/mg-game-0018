/// Card rarity
enum CardRarity {
  common,
  rare,
  epic,
  legendary,
}

/// Card type/ability
enum CardType {
  boost,      // Speed boost
  shield,     // Temporary invincibility
  missile,    // Attack opponent
  slowdown,   // Slow opponents
  magnet,     // Attract coins
  jump,       // Jump over obstacles
  repair,     // Restore health/durability
}

/// Ability card definition
class AbilityCard {
  final String id;
  final String name;
  final String nameKo;
  final String description;
  final CardType type;
  final CardRarity rarity;
  final int baseCooldown; // Seconds
  final double basePower;  // Effect strength

  const AbilityCard({
    required this.id,
    required this.name,
    required this.nameKo,
    required this.description,
    required this.type,
    required this.rarity,
    required this.baseCooldown,
    required this.basePower,
  });
}

/// All ability cards
class AbilityCards {
  static const boost = AbilityCard(
    id: 'boost',
    name: 'Nitro Boost',
    nameKo: '니트로 부스트',
    description: '짧은 시간 동안 최고 속도 증가',
    type: CardType.boost,
    rarity: CardRarity.common,
    baseCooldown: 8,
    basePower: 1.5, // Speed multiplier
  );

  static const shield = AbilityCard(
    id: 'shield',
    name: 'Energy Shield',
    nameKo: '에너지 실드',
    description: '5초간 무적 상태',
    type: CardType.shield,
    rarity: CardRarity.rare,
    baseCooldown: 15,
    basePower: 5.0, // Duration
  );

  static const missile = AbilityCard(
    id: 'missile',
    name: 'Homing Missile',
    nameKo: '유도 미사일',
    description: '앞 차량을 공격',
    type: CardType.missile,
    rarity: CardRarity.rare,
    baseCooldown: 12,
    basePower: 2.0, // Slowdown duration
  );

  static const slowdown = AbilityCard(
    id: 'slowdown',
    name: 'Oil Slick',
    nameKo: '오일 슬릭',
    description: '뒤 차량을 느리게 만듦',
    type: CardType.slowdown,
    rarity: CardRarity.common,
    baseCooldown: 10,
    basePower: 0.5, // Speed multiplier
  );

  static const magnet = AbilityCard(
    id: 'magnet',
    name: 'Coin Magnet',
    nameKo: '코인 자석',
    description: '주변 코인을 끌어당김',
    type: CardType.magnet,
    rarity: CardRarity.epic,
    baseCooldown: 20,
    basePower: 3.0, // Radius
  );

  static const jump = AbilityCard(
    id: 'jump',
    name: 'Super Jump',
    nameKo: '슈퍼 점프',
    description: '장애물을 뛰어넘음',
    type: CardType.jump,
    rarity: CardRarity.rare,
    baseCooldown: 8,
    basePower: 1.0,
  );

  static const repair = AbilityCard(
    id: 'repair',
    name: 'Quick Repair',
    nameKo: '긴급 수리',
    description: '차량 내구도 회복',
    type: CardType.repair,
    rarity: CardRarity.legendary,
    baseCooldown: 25,
    basePower: 0.5, // Heal percentage
  );

  static const teleport = AbilityCard(
    id: 'teleport',
    name: 'Teleport',
    nameKo: '텔레포트',
    description: '짧은 거리를 순간이동',
    type: CardType.jump,
    rarity: CardRarity.epic,
    baseCooldown: 15,
    basePower: 200.0, // Distance in pixels
  );

  static const freeze = AbilityCard(
    id: 'freeze',
    name: 'Ice Blast',
    nameKo: '아이스 블라스트',
    description: '모든 상대를 3초간 빙결',
    type: CardType.slowdown,
    rarity: CardRarity.legendary,
    baseCooldown: 30,
    basePower: 0.0, // Complete stop
  );

  static const ghost = AbilityCard(
    id: 'ghost',
    name: 'Ghost Mode',
    nameKo: '고스트 모드',
    description: '10초간 벽 통과 가능',
    type: CardType.shield,
    rarity: CardRarity.legendary,
    baseCooldown: 35,
    basePower: 10.0, // Duration
  );

  static const List<AbilityCard> all = [
    boost,
    shield,
    missile,
    slowdown,
    magnet,
    jump,
    repair,
    teleport,
    freeze,
    ghost,
  ];

  static AbilityCard? getById(String id) {
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
