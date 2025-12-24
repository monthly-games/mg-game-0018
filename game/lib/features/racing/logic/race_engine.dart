import 'dart:math';
import '../models/vehicle.dart';
import '../models/track.dart';
import '../../cards/models/card.dart';

class RaceResult {
  final int position;
  final int timeMs;
  final int coinsEarned;
  final bool isWin;

  RaceResult({
    required this.position,
    required this.timeMs,
    required this.coinsEarned,
    required this.isWin,
  });
}

class RaceEngine {
  final Random _random = Random();

  /// Simulate a race
  RaceResult simulateRace({
    required Vehicle vehicle,
    required List<RacingCard> activeCards,
    required Track track,
    required int opponentCount,
  }) {
    // 1. Calculate Player Speed
    double speedMultiplier = 1.0;

    // Apply Card Effects
    for (final card in activeCards) {
      if (card.type == CardType.boost) {
        speedMultiplier += (card.effectiveValue - 1.0);
      }
      // Note: Attack/Defense cards would be more complex in a full sim,
      // simplified here to just speed impact for phase 1.
    }

    final playerSpeed = vehicle.effectiveSpeed * speedMultiplier;

    // Base time = (Recall physics: t = d/v)
    // But this is RPG speed value, so let's map it arbitrarily.
    // Assume Speed 100 = 10 m/s
    // 2. Calculate Opponent Speeds
    // Balancing: Opponents scale based on Track Difficulty.
    // Difficulty 1: Base Speed ~100
    // Difficulty 2: Base Speed ~120
    // Difficulty 3: Base Speed ~150
    // If player upgrade level keeps up, they win.

    double difficultyBaseSpeed;
    switch (track.difficultyRating) {
      case 1:
        difficultyBaseSpeed = 100.0;
        break;
      case 2:
        difficultyBaseSpeed = 125.0;
        break;
      case 3:
        difficultyBaseSpeed = 160.0;
        break;
      default:
        difficultyBaseSpeed = 100.0;
    }

    final playerTimeSeconds = track.lengthMeters / (playerSpeed / 2.0);

    // Opponent Variance
    int betterThanOpponents = 0;
    for (int i = 0; i < opponentCount; i++) {
      // 90% - 110% of difficulty target
      double variance = 0.9 + (_random.nextDouble() * 0.2);
      double opponentSpeed = difficultyBaseSpeed * variance;

      final opponentTime = track.lengthMeters / (opponentSpeed / 2.0);

      // Lower time is better
      if (playerTimeSeconds < opponentTime) {
        betterThanOpponents++;
      }
    }

    // Position: Total racers - opponents beaten
    // e.g. 5 opponents. Beat 5 -> Position 1. Beat 0 -> Position 6.
    final position = (opponentCount + 1) - betterThanOpponents;

    // Rewards
    final isWin = position <= 3; // Top 3 counts as "Win"
    final coins = isWin ? (1000 ~/ position) : 50;

    return RaceResult(
      position: position,
      timeMs: (playerTimeSeconds * 1000).round(),
      coinsEarned: coins,
      isWin: isWin,
    );
  }
}
