import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:game/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:game/game/level_design_config.dart';
import 'package:game/game/wave_spawn_table.dart';
import 'package:game/game/tutorial_config.dart';

/// E2E Test for MG-0018: Cartoon Racing RPG (JRPG Series #3)
///
/// Tests the game loop with focus on:
/// - Racing mechanics
/// - Speed and timing elements
/// - Competition progression
/// - Cartoon racing theme
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MG-0018 Cartoon Racing RPG - Game Loop E2E', () {
    testWidgets('Complete racing progression', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify main menu elements
      expect(find.text('MG-0018'), findsOneWidget);
      expect(find.text('Cartoon Racing RPG'), findsOneWidget);
      expect(find.text('Core Fun: $kCoreFunLoop'), findsOneWidget);

      // Navigate to tutorial
      await tester.tap(find.text('Tutorial'));
      await tester.pumpAndSettle();

      // Complete tutorial steps
      final tutorialSteps = kOnboardingTutorial.steps;
      for (int i = 0; i < tutorialSteps.length; i++) {
        await tester.pumpAndSettle();
        expect(find.text('${i + 1}/${tutorialSteps.length}'), findsOneWidget);

        await tester.tap(find.text(i == tutorialSteps.length - 1 ? 'Done' : 'Next'));
        await tester.pumpAndSettle();
      }

      // Navigate to game screen
      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      // Test racing progression
      int racesCompleted = 0;
      int totalGold = 0;
      int totalXP = 0;

      for (int i = 0; i < 8 && i < kLevelDesign.length; i++) {
        await tester.pumpAndSettle();

        final levelDesign = kLevelDesign[i];
        final spawn = kWaveSpawnTable[i];

        expect(find.text('Level ${levelDesign.levelIndex} - ${levelDesign.stage}'), findsOneWidget);

        // Complete race
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();

        // Racing rewards
        racesCompleted++;
        totalGold += levelDesign.goldReward;
        totalXP += levelDesign.xpReward;

        expect(find.text('$totalGold gold / $totalXP xp'), findsOneWidget);
      }

      // Verify racing progression
      expect(racesCompleted, greaterThan(0), reason: 'Should complete races');
      expect(totalGold, greaterThan(0), reason: 'Races should provide rewards');
      expect(totalXP, greaterThan(0), reason: 'Should gain XP');
    });

    testWidgets('Test racing variety and speed mechanics', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      // Racing should have track types
      for (int i = 0; i < 10 && i < kLevelDesign.length; i++) {
        final level = kLevelDesign[i];
        final spawn = kWaveSpawnTable[i];

        // Racing themes
        expect(level.stage.toLowerCase(), anyOf(
          contains('race'),
          contains('track'),
          contains('circuit'),
          contains('speed'),
          contains('dash'),
          contains('grand prix'),
          contains('championship'),
        ), reason: 'Levels should have racing themes');

        // Racing should have fast spawn cadence
        expect(spawn.spawnCadenceSeconds, lessThan(3.0),
            reason: 'Racing should have fast pacing');

        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Verify racing theme and visual elements', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      // Verify racing visual elements
      expect(find.byIcon(Icons.videogame_asset_rounded), findsWidgets);
      expect(find.byIcon(Icons.speed_rounded), findsWidgets);
    });

    testWidgets('Complete full racing season', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      int racesCompleted = 0;
      int maxRaces = 24;

      for (int i = 0; i < maxRaces && i < kLevelDesign.length; i++) {
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
        racesCompleted++;
      }

      expect(racesCompleted, equals(maxRaces), reason: 'Should complete 24 races');

      // Verify racing rewards
      final finalGold = kLevelDesign.take(maxRaces).map((l) => l.goldReward).fold(0, (a, b) => a + b);
      final finalXP = kLevelDesign.take(maxRaces).map((l) => l.xpReward).fold(0, (a, b) => a + b);

      expect(find.textContaining('$finalGold gold'), findsOneWidget);
      expect(find.textContaining('$finalXP xp'), findsOneWidget);
    });

    testWidgets('Test racing retention features', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test daily races
      await tester.tap(find.text('Daily'));
      await tester.pumpAndSettle();
      expect(find.text('Daily Quests'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      // Test tournament (racing championships)
      await tester.tap(find.text('Tournament'));
      await tester.pumpAndSettle();
      expect(find.text('Tournament'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      // Test seasonal events (racing seasons)
      await tester.tap(find.text('Event'));
      await tester.pumpAndSettle();
      expect(find.text('Seasonal Event'), findsOneWidget);
    });

    testWidgets('Verify racing championship progression', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Level Roadmap'));
      await tester.pumpAndSettle();

      // Racing should have championship structure
      for (int i = 0; i < kLevelDesign.length && i < 12; i++) {
        final level = kLevelDesign[i];
        expect(find.text('Level ${level.levelIndex} - ${level.stage}'), findsOneWidget);

        // Racing progression
        expect(level.stage.toLowerCase(), anyOf(
          contains('heat'),
          contains('semi-final'),
          contains('final'),
          contains('championship'),
          contains('cup'),
          contains('trophy'),
        ));
      }
    });

    testWidgets('Test speed and timing mechanics', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      // Test that racing has variable speed elements
      List<double> spawnCadences = [];

      for (int i = 0; i < 10 && i < kLevelDesign.length; i++) {
        final spawn = kWaveSpawnTable[i];
        spawnCadences.add(spawn.spawnCadenceSeconds);

        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
      }

      // Racing should have varied pacing
      final uniqueCadences = spawnCadences.toSet();
      expect(uniqueCadences.length, greaterThan(2),
          reason: 'Racing should have varied speeds');
    });
  });
}
