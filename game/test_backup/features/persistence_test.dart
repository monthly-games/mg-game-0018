import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:game/core/save_manager.dart';
import 'package:game/features/meta/economy_manager.dart';
import 'package:game/features/meta/garage_manager.dart';
import 'package:game/features/meta/card_manager.dart';
import 'package:game/features/racing/models/vehicle.dart';

void main() {
  group('SaveManager Verification', () {
    late EconomyManager economy;
    late GarageManager garage;
    late CardManager cards;
    late SaveManager saveManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      economy = EconomyManager();
      garage = GarageManager(economy);
      cards = CardManager(economy);
      saveManager = SaveManager(economy: economy, garage: garage, cards: cards);
    });

    test('Saving and Loading preserves data', () async {
      // Modify state
      economy.addCoins(500);
      economy.addGems(10);

      final v = Vehicle(
        id: 'v_test',
        name: 'Test',
        rarity: VehicleRarity.common,
        baseSpeed: 10,
        baseAcceleration: 10,
        baseHandling: 10,
      );
      garage.addVehicle(v);

      // Save
      await saveManager.saveGame();

      // Reset state
      economy = EconomyManager();
      garage = GarageManager(economy);
      cards = CardManager(economy);
      final newSaveManager = SaveManager(
        economy: economy,
        garage: garage,
        cards: cards,
      );

      // Load
      final success = await newSaveManager.loadGame();

      expect(success, true);
      expect(economy.coins, 500);
      expect(economy.gems, 10);
    });
  });
}
