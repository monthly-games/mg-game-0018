class RacingPhysics {
  double baseAcceleration;
  double baseMaxSpeed;
  double baseFriction;
  double baseTurnSpeed;
  double baseBraking;

  RacingPhysics({
    required this.baseAcceleration,
    required this.baseMaxSpeed,
    required this.baseFriction,
    required this.baseTurnSpeed,
    required this.baseBraking,
  });

  void applyUpgrades({
    double accelerationBonus = 0,
    double maxSpeedBonus = 0,
    double handlingBonus = 0,
    double brakingBonus = 0,
    double gripBonus = 0,
    double aeroBonus = 0,
    double weightBonus = 0,
  }) {
    baseAcceleration += accelerationBonus;
    baseMaxSpeed += maxSpeedBonus;
    baseTurnSpeed += handlingBonus;
    baseBraking += brakingBonus;
    baseFriction += gripBonus;
  }
}

class RacingConfig {
  static const double baseAcceleration = 5.0;
  static const double baseMaxSpeed = 100.0;
  static const double baseFriction = 0.95;
  static const double baseTurnSpeed = 3.0;
  static const double baseBraking = 8.0;
  static const double defaultNitroCapacity = 100.0;
  static const double nitroRechargeRate = 10.0;
  static const int defaultLapCount = 3;
}
