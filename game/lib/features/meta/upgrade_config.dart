class UpgradeConfig {
  static int getUpgradeCost(int currentLevel) {
    // Base cost 100, increase by 20% each level
    // Level 0 -> 100
    // Level 1 -> 120
    // Level 2 -> 144
    double base = 100.0;
    for (int i = 0; i < currentLevel; i++) {
      base *= 1.2;
    }
    return base.round();
  }

  static const int maxLevel = 10;
}
