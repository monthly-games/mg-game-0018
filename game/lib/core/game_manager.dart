import '../features/meta/economy_manager.dart';
import '../features/meta/garage_manager.dart';
import '../features/meta/card_manager.dart';
import '../features/racing/data/vehicle_data.dart';
import '../features/cards/data/card_data.dart';
import 'save_manager.dart';

class GameManager {
  static final GameManager _instance = GameManager._internal();
  factory GameManager() => _instance;
  GameManager._internal();

  late EconomyManager economy;
  late GarageManager garage;
  late CardManager cards;
  late SaveManager saveManager; // Added SaveManager field

  bool _initialized = false;

  Future<void> initialize() async {
    // Changed to async
    if (_initialized) return;

    economy = EconomyManager();
    garage = GarageManager(economy);
    cards = CardManager(economy);
    saveManager = SaveManager(
      economy: economy,
      garage: garage,
      cards: cards,
    ); // Instantiated SaveManager

    // Try to load save, if fail, give starter content
    final loaded = await saveManager.loadGame();
    if (!loaded) {
      // Give starter content
      garage.addVehicle(VehicleData.starter);
      cards.addCard(CardData.getAllCards().first); // Add first card (Nitro)
    }

    // Auto-save on changes
    economy.addListener(_autoSave);
    garage.addListener(_autoSave);
    cards.addListener(_autoSave);

    _initialized = true;
  }

  void _autoSave() {
    saveManager.saveGame();
  }
}
