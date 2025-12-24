import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/racing/models/vehicle.dart';
import 'package:game/features/racing/models/track.dart';
import 'package:game/features/cards/models/card.dart';
import 'package:game/features/racing/logic/race_engine.dart';

void main() {
  group('RaceEngine Verification', () {
    late RaceEngine engine;
    late Track simpleTrack;

    setUp(() {
      engine = RaceEngine();
      simpleTrack = const Track(
        id: 'track_01',
        name: 'Test Track',
        lengthMeters: 1000,
      );
    });

    test('Higher speed results in lower time', () {
      final slowCar = Vehicle(
        id: 'v1',
        name: 'Slow',
        rarity: VehicleRarity.common,
        baseSpeed: 100,
        baseAcceleration: 50,
        baseHandling: 50,
      );

      final fastCar = Vehicle(
        id: 'v2',
        name: 'Fast',
        rarity: VehicleRarity.epic,
        baseSpeed: 200,
        baseAcceleration: 50,
        baseHandling: 50,
      );

      final slowResult = engine.simulateRace(
        vehicle: slowCar,
        activeCards: [],
        track: simpleTrack,
        opponentCount: 0,
      );

      final fastResult = engine.simulateRace(
        vehicle: fastCar,
        activeCards: [],
        track: simpleTrack,
        opponentCount: 0,
      );

      print('Slow Time: ${slowResult.timeMs}ms');
      print('Fast Time: ${fastResult.timeMs}ms');

      expect(fastResult.timeMs, lessThan(slowResult.timeMs));
    });

    test('Card boost improves time', () {
      final car = Vehicle(
        id: 'v1',
        name: 'Standard',
        rarity: VehicleRarity.common,
        baseSpeed: 100,
        baseAcceleration: 50,
        baseHandling: 50,
      );

      final boostCard = RacingCard(
        id: 'c1',
        name: 'Nitro',
        description: 'Speed Boost',
        type: CardType.boost,
        rarity: CardRarity.common,
        effectValue: 1.5, // 50% boost
      );

      final normalResult = engine.simulateRace(
        vehicle: car,
        activeCards: [],
        track: simpleTrack,
        opponentCount: 0,
      );

      final boostedResult = engine.simulateRace(
        vehicle: car,
        activeCards: [boostCard],
        track: simpleTrack,
        opponentCount: 0,
      );

      print('Normal Time: ${normalResult.timeMs}ms');
      print('Boosted Time: ${boostedResult.timeMs}ms');

      expect(boostedResult.timeMs, lessThan(normalResult.timeMs));
    });
  });
}
