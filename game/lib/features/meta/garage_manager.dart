import 'package:flutter/foundation.dart';
import '../racing/models/vehicle.dart';
import 'economy_manager.dart';
import 'upgrade_config.dart';
import '../racing/data/vehicle_data.dart';

class GarageManager extends ChangeNotifier {
  final EconomyManager _economy;
  final List<Vehicle> _ownedVehicles = [];
  String? _equippedVehicleId;

  GarageManager(this._economy);

  List<Vehicle> get ownedVehicles => List.unmodifiable(_ownedVehicles);

  Vehicle? get equippedVehicle {
    if (_equippedVehicleId == null && _ownedVehicles.isNotEmpty) {
      return _ownedVehicles.first;
    }
    try {
      return _ownedVehicles.firstWhere((v) => v.id == _equippedVehicleId);
    } catch (_) {
      return _ownedVehicles.isNotEmpty ? _ownedVehicles.first : null;
    }
  }

  void addVehicle(Vehicle vehicle) {
    if (!_ownedVehicles.any((v) => v.id == vehicle.id)) {
      _ownedVehicles.add(vehicle);
      if (_ownedVehicles.length == 1) {
        _equippedVehicleId = vehicle.id;
      }
      notifyListeners();
    }
  }

  bool equipVehicle(String id) {
    if (_ownedVehicles.any((v) => v.id == id)) {
      _equippedVehicleId = id;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool upgradeSpeed(String vehicleId) {
    final vehicle = _findVehicle(vehicleId);
    if (vehicle == null) return false;
    if (vehicle.speedLevel >= UpgradeConfig.maxLevel) return false;

    final cost = UpgradeConfig.getUpgradeCost(vehicle.speedLevel);
    if (_economy.spendCoins(cost)) {
      vehicle.speedLevel++;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool upgradeAcceleration(String vehicleId) {
    final vehicle = _findVehicle(vehicleId);
    if (vehicle == null) return false;
    if (vehicle.accelerationLevel >= UpgradeConfig.maxLevel) return false;

    final cost = UpgradeConfig.getUpgradeCost(vehicle.accelerationLevel);
    if (_economy.spendCoins(cost)) {
      vehicle.accelerationLevel++;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool upgradeHandling(String vehicleId) {
    final vehicle = _findVehicle(vehicleId);
    if (vehicle == null) return false;
    if (vehicle.handlingLevel >= UpgradeConfig.maxLevel) return false;

    final cost = UpgradeConfig.getUpgradeCost(vehicle.handlingLevel);
    if (_economy.spendCoins(cost)) {
      vehicle.handlingLevel++;
      notifyListeners();
      return true;
    }
    return false;
  }

  Vehicle? _findVehicle(String id) {
    try {
      return _ownedVehicles.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'ownedVehicles': _ownedVehicles.map((v) => v.toJson()).toList(),
      'equippedId': _equippedVehicleId,
    };
  }

  void loadFromJson(Map<String, dynamic> json) {
    _ownedVehicles.clear();
    final List<dynamic> vehiclesJson = json['ownedVehicles'] ?? [];

    // We need access to VehicleData to restore base stats.
    // Ideally VehicleData would be injected or importable.
    // I will use VehicleData static accessor here.

    for (var vJson in vehiclesJson) {
      final id = vJson['id'];
      // Find base data
      final baseList = VehicleData.getAllVehicles();
      try {
        final base = baseList.firstWhere((b) => b.id == id);
        final restored = Vehicle.fromJson(vJson, base);
        _ownedVehicles.add(restored);
      } catch (e) {
        debugPrint('Failed to load vehicle $id: $e');
      }
    }

    _equippedVehicleId = json['equippedId'];
    notifyListeners();
  }
}
