import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/racing/logic/race_engine.dart';
import 'package:game/features/racing/models/vehicle.dart';
import 'package:game/features/racing/models/track.dart';

void main() {
  group('Balancing Tests', () {
    late RaceEngine raceEngine;
    late Vehicle testVehicle;

    setUp(() {
      raceEngine = RaceEngine();
      testVehicle = Vehicle(
        id: 'v_test',
        name: 'Test Car',
        rarity: VehicleRarity.common,
        baseSpeed: 100, // Matches difficulty 1 baseline
        baseAcceleration: 10,
        baseHandling: 10,
      );
    });

    test(
      'Higher difficulty tracks produce faster opponents (lower finish time)',
      () {
        final easyTrack = Track(
          id: 't_easy',
          name: 'Easy',
          lengthMeters: 1000,
          difficultyRating: 1,
        );

        final hardTrack = Track(
          id: 't_hard',
          name: 'Hard',
          lengthMeters: 1000, // Same length to compare times directly
          difficultyRating: 3,
        );

        // We check "position" of player.
        // If difficulty 1 (speed 100) vs player (speed 100), player should be mid-pack ~50% win rate or better if variance favors.
        // If difficulty 3 (speed 160) vs player (speed 100), player should be last mostly.

        int playerWinsEasy = 0;
        int playerWinsHard = 0;

        for (int i = 0; i < 20; i++) {
          final resultEasy = raceEngine.simulateRace(
            vehicle: testVehicle,
            activeCards: [],
            track: easyTrack,
            opponentCount: 5,
          );
          if (resultEasy.isWin) playerWinsEasy++;

          final resultHard = raceEngine.simulateRace(
            vehicle: testVehicle,
            activeCards: [],
            track: hardTrack,
            opponentCount: 5,
          );
          if (resultHard.isWin) playerWinsHard++;
        }

        // Player should win easy track often
        expect(playerWinsEasy, greaterThan(5));

        // Player should rarely win hard track without upgrades
        expect(playerWinsHard, lessThan(5));

        print('Wins Easy: $playerWinsEasy/20, Wins Hard: $playerWinsHard/20');
      },
    );
  });
}
