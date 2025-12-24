import '../models/vehicle.dart';

class VehicleData {
  static final Vehicle starter = Vehicle(
    id: 'v_starter',
    name: 'Starter Kart',
    rarity: VehicleRarity.common,
    baseSpeed: 100,
    baseAcceleration: 100,
    baseHandling: 100,
  );

  static final Vehicle balanced = Vehicle(
    id: 'v_balanced',
    name: 'Blue Racer',
    rarity: VehicleRarity.rare,
    baseSpeed: 120,
    baseAcceleration: 110,
    baseHandling: 110,
  );

  static final Vehicle speedster = Vehicle(
    id: 'v_speedster',
    name: 'Red Flash',
    rarity: VehicleRarity.epic,
    baseSpeed: 150,
    baseAcceleration: 90,
    baseHandling: 80,
  );

  static final Vehicle tank = Vehicle(
    id: 'v_tank',
    name: 'Heavy Metal',
    rarity: VehicleRarity.rare,
    baseSpeed: 90,
    baseAcceleration: 80,
    baseHandling: 140,
  );

  static final Vehicle driftKing = Vehicle(
    id: 'v_drift',
    name: 'Drift King',
    rarity: VehicleRarity.legendary,
    baseSpeed: 140,
    baseAcceleration: 130,
    baseHandling: 150,
  );

  static List<Vehicle> getAllVehicles() {
    return [starter, balanced, speedster, tank, driftKing];
  }
}
