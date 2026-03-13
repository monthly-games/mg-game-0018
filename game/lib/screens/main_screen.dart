import 'package:flutter/material.dart';
import 'achievement_screen.dart';
import 'daily_quest_screen.dart';
import 'garage_screen.dart';
import 'race_screen.dart';
import '../core/game_manager.dart';
import '../core/audio_manager.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: GameManager().initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
      endDrawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                    color: Color(0xFF1A237E)),
                child: Text('Community',
                    style: TextStyle(
                        color: Colors.white, fontSize: 24)),
              ),
              ListTile(
                leading: const Icon(Icons.shield),
                title: const Text('Guild War'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context)
                      .pushNamed('/guild-war');
                },
              ),
              ListTile(
                leading: const Icon(Icons.emoji_events),
                title: const Text('Tournament'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context)
                      .pushNamed('/tournament');
                },
              ),
              ListTile(
                leading: const Icon(Icons.celebration),
                title: const Text('Seasonal Event'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context)
                      .pushNamed('/seasonal-event');
                },
              ),
            ],
          ),
        ),
      ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Cartoon Racing RPG'),
            actions: [
              IconButton(
                icon: const Icon(Icons.assignment_rounded),
                tooltip: 'Daily Quests',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DailyQuestScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.emoji_events_rounded),
                tooltip: 'Achievements',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AchievementScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome Racer!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  icon: const Icon(Icons.garage),
                  label: const Text('Garage (Upgrades)'),
                  onPressed: () {
                    AudioManager().playSfx('click');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GarageScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.flag),
                  label: const Text('Race Track'),
                  onPressed: () {
                    AudioManager().playSfx('click');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RaceScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                    backgroundColor: MGColors.warning,
                    foregroundColor: MGColors.textHighEmphasis,
                  ),
                ),
                const SizedBox(height: 40),
                // Economy Display with Animation
                ListenableBuilder(
                  listenable: GameManager().economy,
                  builder: (context, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _AnimatedCount(
                          label: 'Coins',
                          value: GameManager().economy.coins,
                          icon: Icons.monetization_on,
                          color: MGColors.gold,
                        ),
                        const SizedBox(width: 20),
                        _AnimatedCount(
                          label: 'Gems',
                          value: GameManager().economy.gems,
                          icon: Icons.diamond,
                          color: MGColors.info,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedCount extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _AnimatedCount({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.toDouble()),
      duration: const Duration(seconds: 1),
      builder: (context, val, child) {
        return Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 5),
            Text(
              '$label: ${val.toInt()}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        );
      },
    );
  }
}
