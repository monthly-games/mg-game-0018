enum VehicleRarity { common, rare, epic, legendary }

class Vehicle {
  final String id;
  final String name;
  final VehicleRarity rarity;

  // Base Stats
  final double baseSpeed;
  final double baseAcceleration;
  final double baseHandling;

  // Upgrades
  int speedLevel;
  int accelerationLevel;
  int handlingLevel;

  Vehicle({
    required this.id,
    required this.name,
    required this.rarity,
    required this.baseSpeed,
    required this.baseAcceleration,
    required this.baseHandling,
    this.speedLevel = 0,
    this.accelerationLevel = 0,
    this.handlingLevel = 0,
  });

  // Calculate annual speed based on levels
  double get effectiveSpeed => baseSpeed * (1 + speedLevel * 0.02);
  double get effectiveAcceleration =>
      baseAcceleration * (1 + accelerationLevel * 0.02);
  double get effectiveHandling => baseHandling * (1 + handlingLevel * 0.02);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'speedLevel': speedLevel,
      'accelerationLevel': accelerationLevel,
      'handlingLevel': handlingLevel,
    };
  }

  factory Vehicle.fromJson(Map<String, dynamic> json, Vehicle baseData) {
    // We revive state from JSON but keep base stats from predefined data
    final v = Vehicle(
      id: baseData.id,
      name: baseData.name,
      rarity: baseData.rarity,
      baseSpeed: baseData.baseSpeed,
      baseAcceleration: baseData.baseAcceleration,
      baseHandling: baseData.baseHandling,
    );
    v.speedLevel = json['speedLevel'] ?? 0;
    v.accelerationLevel = json['accelerationLevel'] ?? 0;
    v.handlingLevel = json['handlingLevel'] ?? 0;
    return v;
  }
}
