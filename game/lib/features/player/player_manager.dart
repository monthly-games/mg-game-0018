import 'package:flutter/foundation.dart';
import '../vehicles/vehicle_data.dart';
import '../cards/card_data.dart';

/// Player progression and inventory
class PlayerManager extends ChangeNotifier {
  // Currency (Balanced starting values)
  int _coins = 2000; // Increased to allow first vehicle unlock
  int _diamonds = 100; // Increased for premium pack option
  int _fuel = 100;

  // Fuel regeneration
  DateTime _lastFuelUpdate = DateTime.now();
  static const int fuelRegenPerMinute = 1; // 1 fuel per minute
  static const int maxFuel = 100;

  // Current selections
  String _selectedVehicleId = 'starter';
  List<String> _equippedCardIds = ['boost', 'shield', 'missile'];

  // Unlocked content
  final Set<String> _unlockedVehicles = {'starter'};
  final Set<String> _unlockedCards = {'boost', 'shield', 'missile', 'slowdown'};

  // Vehicle upgrades (vehicleId -> upgrade level 0-5)
  final Map<String, int> _vehicleUpgrades = {'starter': 0};

  // League progression
  int _currentLeague = 1; // 1-5

  // Getters
  int get coins => _coins;
  int get diamonds => _diamonds;
  int get fuel => _fuel;
  String get selectedVehicleId => _selectedVehicleId;
  List<String> get equippedCardIds => List.unmodifiable(_equippedCardIds);
  Set<String> get unlockedVehicles => Set.unmodifiable(_unlockedVehicles);
  Set<String> get unlockedCards => Set.unmodifiable(_unlockedCards);
  int get currentLeague => _currentLeague;

  Vehicle? get selectedVehicle => Vehicles.getById(_selectedVehicleId);
  List<AbilityCard?> get equippedCards =>
      _equippedCardIds.map((id) => AbilityCards.getById(id)).toList();

  /// Add coins
  void addCoins(int amount) {
    _coins += amount;
    notifyListeners();
  }

  /// Spend coins
  bool spendCoins(int amount) {
    if (_coins < amount) return false;
    _coins -= amount;
    notifyListeners();
    return true;
  }

  /// Add diamonds
  void addDiamonds(int amount) {
    _diamonds += amount;
    notifyListeners();
  }

  /// Spend diamonds
  bool spendDiamonds(int amount) {
    if (_diamonds < amount) return false;
    _diamonds -= amount;
    notifyListeners();
    return true;
  }

  /// Add fuel
  void addFuel(int amount) {
    _updateFuelRegeneration();
    _fuel = (_fuel + amount).clamp(0, maxFuel);
    notifyListeners();
  }

  /// Update fuel regeneration based on time passed
  void _updateFuelRegeneration() {
    if (_fuel >= maxFuel) {
      _lastFuelUpdate = DateTime.now();
      return;
    }

    final now = DateTime.now();
    final minutesPassed = now.difference(_lastFuelUpdate).inMinutes;

    if (minutesPassed > 0) {
      final fuelToAdd = minutesPassed * fuelRegenPerMinute;
      _fuel = (_fuel + fuelToAdd).clamp(0, maxFuel);
      _lastFuelUpdate = now.subtract(Duration(
        seconds: now.difference(_lastFuelUpdate).inSeconds % 60,
      ));
    }
  }

  /// Get fuel with regeneration applied
  @override
  int get fuel {
    _updateFuelRegeneration();
    return _fuel;
  }

  /// Spend fuel
  bool spendFuel(int amount) {
    if (_fuel < amount) return false;
    _fuel -= amount;
    notifyListeners();
    return true;
  }

  /// Select vehicle
  bool selectVehicle(String vehicleId) {
    if (!_unlockedVehicles.contains(vehicleId)) return false;
    _selectedVehicleId = vehicleId;
    notifyListeners();
    return true;
  }

  /// Unlock vehicle
  bool unlockVehicle(String vehicleId, int cost) {
    if (_unlockedVehicles.contains(vehicleId)) return false;
    if (!spendCoins(cost)) return false;

    _unlockedVehicles.add(vehicleId);
    notifyListeners();
    return true;
  }

  /// Unlock card
  bool unlockCard(String cardId) {
    if (_unlockedCards.contains(cardId)) return false;
    _unlockedCards.add(cardId);
    notifyListeners();
    return true;
  }

  /// Equip cards (3 slots)
  bool equipCards(List<String> cardIds) {
    if (cardIds.length > 3) return false;

    for (final id in cardIds) {
      if (!_unlockedCards.contains(id)) return false;
    }

    _equippedCardIds = List.from(cardIds);
    notifyListeners();
    return true;
  }

  /// Increase league
  void promoteLeague() {
    if (_currentLeague < 5) {
      _currentLeague++;
      notifyListeners();
    }
  }

  /// Get vehicle upgrade level
  int getVehicleUpgradeLevel(String vehicleId) {
    return _vehicleUpgrades[vehicleId] ?? 0;
  }

  /// Upgrade vehicle (max level 5)
  bool upgradeVehicle(String vehicleId, int cost) {
    if (!_unlockedVehicles.contains(vehicleId)) return false;

    final currentLevel = _vehicleUpgrades[vehicleId] ?? 0;
    if (currentLevel >= 5) return false; // Max level

    if (!spendCoins(cost)) return false;

    _vehicleUpgrades[vehicleId] = currentLevel + 1;
    notifyListeners();
    return true;
  }

  /// Get upgraded stats for a vehicle
  VehicleStats getUpgradedStats(Vehicle vehicle) {
    final upgradeLevel = getVehicleUpgradeLevel(vehicle.id);
    final upgradeBonus = upgradeLevel * 0.1; // +10% per level

    return VehicleStats(
      speed: vehicle.baseStats.speed * (1 + upgradeBonus),
      acceleration: vehicle.baseStats.acceleration * (1 + upgradeBonus),
      handling: vehicle.baseStats.handling * (1 + upgradeBonus),
      boost: vehicle.baseStats.boost * (1 + upgradeBonus),
    );
  }

  /// Get vehicle upgrades map for saving
  Map<String, int> getVehicleUpgradesMap() {
    return Map.from(_vehicleUpgrades);
  }

  /// Get last fuel update time for saving
  DateTime getLastFuelUpdate() {
    return _lastFuelUpdate;
  }

  /// Load from save data
  void loadFromSave({
    required int coins,
    required int diamonds,
    required int fuel,
    required DateTime lastFuelUpdate,
    required String selectedVehicleId,
    required List<String> equippedCardIds,
    required Set<String> unlockedVehicles,
    required Set<String> unlockedCards,
    required Map<String, int> vehicleUpgrades,
    required int currentLeague,
  }) {
    _coins = coins;
    _diamonds = diamonds;
    _fuel = fuel;
    _lastFuelUpdate = lastFuelUpdate;
    _selectedVehicleId = selectedVehicleId;
    _equippedCardIds = List.from(equippedCardIds);
    _unlockedVehicles.clear();
    _unlockedVehicles.addAll(unlockedVehicles);
    _unlockedCards.clear();
    _unlockedCards.addAll(unlockedCards);
    _vehicleUpgrades.clear();
    _vehicleUpgrades.addAll(vehicleUpgrades);
    _currentLeague = currentLeague;
    notifyListeners();
  }
}
