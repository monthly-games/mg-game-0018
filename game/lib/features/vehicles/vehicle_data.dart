/// Vehicle statistics
class VehicleStats {
  final double speed;       // Top speed (1-10)
  final double acceleration; // Acceleration (1-10)
  final double handling;     // Turn speed (1-10)
  final double boost;        // Boost power (1-10)

  const VehicleStats({
    required this.speed,
    required this.acceleration,
    required this.handling,
    required this.boost,
  });

  double get overall => (speed + acceleration + handling + boost) / 4;
}

/// Vehicle definition
class Vehicle {
  final String id;
  final String name;
  final String nameKo;
  final VehicleStats baseStats;
  final int unlockCost; // Coins
  final int unlockLevel; // League level (1-5)

  const Vehicle({
    required this.id,
    required this.name,
    required this.nameKo,
    required this.baseStats,
    required this.unlockCost,
    required this.unlockLevel,
  });
}

/// All vehicles
class Vehicles {
  static const starter = Vehicle(
    id: 'starter',
    name: 'Rookie Kart',
    nameKo: '루키 카트',
    baseStats: VehicleStats(
      speed: 4,
      acceleration: 5,
      handling: 6,
      boost: 4,
    ),
    unlockCost: 0,
    unlockLevel: 1,
  );

  static const speedster = Vehicle(
    id: 'speedster',
    name: 'Speedster',
    nameKo: '스피드스터',
    baseStats: VehicleStats(
      speed: 8,
      acceleration: 4,
      handling: 5,
      boost: 6,
    ),
    unlockCost: 5000,
    unlockLevel: 2,
  );

  static const drifter = Vehicle(
    id: 'drifter',
    name: 'Drift King',
    nameKo: '드리프트 킹',
    baseStats: VehicleStats(
      speed: 6,
      acceleration: 5,
      handling: 9,
      boost: 5,
    ),
    unlockCost: 8000,
    unlockLevel: 2,
  );

  static const tank = Vehicle(
    id: 'tank',
    name: 'Heavy Tank',
    nameKo: '헤비 탱크',
    baseStats: VehicleStats(
      speed: 5,
      acceleration: 8,
      handling: 4,
      boost: 8,
    ),
    unlockCost: 12000,
    unlockLevel: 3,
  );

  static const balanced = Vehicle(
    id: 'balanced',
    name: 'All-Rounder',
    nameKo: '올라운더',
    baseStats: VehicleStats(
      speed: 7,
      acceleration: 7,
      handling: 7,
      boost: 7,
    ),
    unlockCost: 15000,
    unlockLevel: 3,
  );

  static const legend = Vehicle(
    id: 'legend',
    name: 'Legend Racer',
    nameKo: '레전드 레이서',
    baseStats: VehicleStats(
      speed: 10,
      acceleration: 9,
      handling: 8,
      boost: 10,
    ),
    unlockCost: 50000,
    unlockLevel: 5,
  );

  static const List<Vehicle> all = [
    starter,
    speedster,
    drifter,
    tank,
    balanced,
    legend,
  ];

  static Vehicle? getById(String id) {
    try {
      return all.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }
}
