import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../player/player_manager.dart';

/// Save/load manager for game progression
class SaveManager extends ChangeNotifier {
  static const String _saveKey = 'racing_rpg_save_v1';

  final PlayerManager _playerManager;

  SaveManager({
    required PlayerManager playerManager,
  }) : _playerManager = playerManager;

  /// Save all game data
  Future<bool> saveGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final saveData = {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'player': {
          'coins': _playerManager.coins,
          'diamonds': _playerManager.diamonds,
          'fuel': _playerManager.fuel,
          'lastFuelUpdate': _playerManager.getLastFuelUpdate().toIso8601String(),
          'selectedVehicleId': _playerManager.selectedVehicleId,
          'equippedCardIds': _playerManager.equippedCardIds,
          'unlockedVehicles': _playerManager.unlockedVehicles.toList(),
          'unlockedCards': _playerManager.unlockedCards.toList(),
          'vehicleUpgrades': _playerManager.getVehicleUpgradesMap(),
          'currentLeague': _playerManager.currentLeague,
        },
      };

      final success = await prefs.setString(_saveKey, jsonEncode(saveData));

      if (success) {
        debugPrint('Game saved successfully at ${saveData['timestamp']}');
      }

      return success;
    } catch (e) {
      debugPrint('Failed to save game: $e');
      return false;
    }
  }

  /// Load game data
  Future<bool> loadGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saveString = prefs.getString(_saveKey);

      if (saveString == null) {
        debugPrint('No save data found');
        return false;
      }

      final saveData = jsonDecode(saveString) as Map<String, dynamic>;
      final playerData = saveData['player'] as Map<String, dynamic>;

      // Restore player data
      _playerManager.loadFromSave(
        coins: playerData['coins'] as int,
        diamonds: playerData['diamonds'] as int,
        fuel: playerData['fuel'] as int,
        lastFuelUpdate: DateTime.parse(playerData['lastFuelUpdate'] as String),
        selectedVehicleId: playerData['selectedVehicleId'] as String,
        equippedCardIds: (playerData['equippedCardIds'] as List).cast<String>(),
        unlockedVehicles: (playerData['unlockedVehicles'] as List).cast<String>().toSet(),
        unlockedCards: (playerData['unlockedCards'] as List).cast<String>().toSet(),
        vehicleUpgrades: (playerData['vehicleUpgrades'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, value as int),
        ),
        currentLeague: playerData['currentLeague'] as int,
      );

      debugPrint('Game loaded successfully from ${saveData['timestamp']}');
      return true;
    } catch (e) {
      debugPrint('Failed to load game: $e');
      return false;
    }
  }

  /// Check if save data exists
  Future<bool> hasSaveData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_saveKey);
  }

  /// Delete save data
  Future<bool> deleteSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_saveKey);
    } catch (e) {
      debugPrint('Failed to delete save: $e');
      return false;
    }
  }

  /// Get save info without loading
  Future<Map<String, dynamic>?> getSaveInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saveString = prefs.getString(_saveKey);

      if (saveString == null) return null;

      final saveData = jsonDecode(saveString) as Map<String, dynamic>;
      final playerData = saveData['player'] as Map<String, dynamic>;

      return {
        'timestamp': saveData['timestamp'],
        'coins': playerData['coins'],
        'diamonds': playerData['diamonds'],
        'currentLeague': playerData['currentLeague'],
        'unlockedVehicles': (playerData['unlockedVehicles'] as List).length,
        'unlockedCards': (playerData['unlockedCards'] as List).length,
      };
    } catch (e) {
      debugPrint('Failed to get save info: $e');
      return null;
    }
  }
}
