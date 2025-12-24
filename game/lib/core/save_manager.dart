import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/meta/economy_manager.dart';
import '../features/meta/garage_manager.dart';
import '../features/meta/card_manager.dart';

class SaveManager {
  final EconomyManager economy;
  final GarageManager garage;
  final CardManager cards;

  static const String _saveKey = 'save_data';

  SaveManager({
    required this.economy,
    required this.garage,
    required this.cards,
  });

  Future<void> saveGame() async {
    final prefs = await SharedPreferences.getInstance();

    final data = {
      'economy': economy.toJson(),
      'garage': garage.toJson(),
      'cards': cards.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    await prefs.setString(_saveKey, jsonEncode(data));
  }

  Future<bool> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_saveKey);

    if (jsonString == null) return false;

    try {
      final data = jsonDecode(jsonString);

      if (data.containsKey('economy')) {
        economy.loadFromJson(data['economy']);
      }
      if (data.containsKey('garage')) {
        garage.loadFromJson(data['garage']);
      }
      if (data.containsKey('cards')) {
        cards.loadFromJson(data['cards']);
      }
      return true;
    } catch (e) {
      // print('Failed to load save: $e');
      return false;
    }
  }

  Future<void> wipeSave() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_saveKey);
  }
}
