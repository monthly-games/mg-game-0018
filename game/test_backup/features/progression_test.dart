import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/meta/economy_manager.dart';
import 'package:game/features/meta/garage_manager.dart';
import 'package:game/features/meta/card_manager.dart';
import 'package:game/features/racing/models/vehicle.dart';
import 'package:game/features/cards/models/card.dart';
import 'package:game/features/meta/upgrade_config.dart';

void main() {
  group('Progression Verification', () {
    late EconomyManager economy;
    late GarageManager garage;
    late Vehicle testCar;

    setUp(() {
      economy = EconomyManager();
      garage = GarageManager(economy);

      testCar = Vehicle(
        id: 'test_car',
        name: 'Test Car',
        rarity: VehicleRarity.common,
        baseSpeed: 100,
        baseAcceleration: 100,
        baseHandling: 100,
      );
      garage.addVehicle(testCar);
    });

    test('Economy transactions work', () {
      economy.addCoins(500);
      expect(economy.coins, 500);

      final success = economy.spendCoins(200);
      expect(success, true);
      expect(economy.coins, 300);

      final fail = economy.spendCoins(400);
      expect(fail, false);
      expect(economy.coins, 300);
    });

    test('Upgrade consumes coins and improves stats', () {
      economy.addCoins(1000);

      // Cost for level 0 -> 1 is 100
      final expectedCost = UpgradeConfig.getUpgradeCost(0);
      expect(expectedCost, 100);

      final initialSpeed = testCar.effectiveSpeed;

      final success = garage.upgradeSpeed(testCar.id);

      expect(success, true);
      expect(economy.coins, 1000 - expectedCost);
      expect(testCar.speedLevel, 1);
      expect(testCar.effectiveSpeed, greaterThan(initialSpeed));
    });

    test('Cannot upgrade without funds', () {
      economy.addCoins(10); // Not enough (need 100)

      final success = garage.upgradeSpeed(testCar.id);

      expect(success, false);
      expect(economy.coins, 10);
      expect(testCar.speedLevel, 0);
    });
  });

  group('Card Progression Verification', () {
    late EconomyManager economy;
    late CardManager cardManager;
    late RacingCard testCard;

    setUp(() {
      economy = EconomyManager();
      cardManager = CardManager(economy);

      testCard = RacingCard(
        id: 'c1',
        name: 'Boost',
        description: 'Speed',
        type: CardType.boost,
        rarity: CardRarity.common,
        effectValue: 1.2,
        level: 1,
      );
      cardManager.addCard(testCard);
    });

    test('Deck Management', () {
      expect(cardManager.deck.length, 1); // Auto-equipped
      cardManager.unequipCard('c1');
      expect(cardManager.deck.length, 0);
      cardManager.equipCard('c1');
      expect(cardManager.deck.length, 1);
    });

    test('Card Upgrade consumes coins', () {
      economy.addCoins(1000);
      // Cost level 0 -> 1 = 100 * 2 = 200
      final success = cardManager.upgradeCard('c1');

      expect(success, true);
      expect(
        economy.coins,
        760,
      ); // Cost for Level 1 is 120 * 2 = 240. 1000 - 240 = 760.

      final upgraded = cardManager.ownedCards.first;
      expect(upgraded.level, 2);
      expect(
        upgraded.effectiveValue,
        greaterThan(1.2),
      ); // 1.2 * (1 + 0*0.1) vs 1.2 * (1 + 0*0.1)? wait logic
      // effective = base * (1 + (level-1) * 0.1)
      // Level 0 (if I passed 0 in setup): 1 + -0.1?
      // My RacingCard defaults level=1 in constructor but I passed 0.
      // Let's check logic.
    });
  });
}
