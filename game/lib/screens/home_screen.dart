import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/core/ui/theme/app_text_styles.dart';

import '../features/player/player_manager.dart';
import '../game/tracks/track_data.dart';
import 'race_screen.dart';
import 'garage_screen.dart';
import 'deck_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartoon Racing RPG'),
        backgroundColor: AppColors.primary,
      ),
      body: Consumer<PlayerManager>(
        builder: (context, player, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('카툰 레이싱 RPG', style: AppTextStyles.header1),
                const SizedBox(height: 32),

                // Currency display
                Card(
                  color: AppColors.panel,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildCurrencyRow(Icons.monetization_on, '코인', player.coins, Colors.yellow),
                        const SizedBox(height: 8),
                        _buildCurrencyRow(Icons.diamond, '다이아몬드', player.diamonds, Colors.cyan),
                        const SizedBox(height: 8),
                        _buildCurrencyRow(Icons.local_gas_station, '연료', player.fuel, Colors.orange),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Current vehicle
                Card(
                  color: AppColors.panel,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('현재 차량', style: AppTextStyles.header2),
                        const SizedBox(height: 8),
                        Text(player.selectedVehicle?.nameKo ?? '없음',
                             style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        if (player.selectedVehicle != null) ...[
                          Text('속도: ${player.selectedVehicle!.baseStats.speed}/10'),
                          Text('가속: ${player.selectedVehicle!.baseStats.acceleration}/10'),
                          Text('핸들링: ${player.selectedVehicle!.baseStats.handling}/10'),
                          Text('부스트: ${player.selectedVehicle!.baseStats.boost}/10'),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Race button
                ElevatedButton.icon(
                  onPressed: player.fuel >= 10
                      ? () => _startRace(context, player)
                      : null,
                  icon: const Icon(Icons.play_arrow, size: 32),
                  label: Text(
                    '레이스 시작 (연료 -10)',
                    style: AppTextStyles.body.copyWith(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),

                const SizedBox(height: 16),

                // Other menu buttons
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildMenuButton(
                      context,
                      icon: Icons.garage,
                      label: '차고',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const GarageScreen()),
                        );
                      },
                    ),
                    _buildMenuButton(
                      context,
                      icon: Icons.style,
                      label: '카드 덱',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DeckScreen()),
                        );
                      },
                    ),
                    _buildMenuButton(
                      context,
                      icon: Icons.store,
                      label: '상점',
                      onPressed: () {
                        // TODO: Navigate to shop screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('상점 화면 구현 예정')),
                        );
                      },
                    ),
                    _buildMenuButton(
                      context,
                      icon: Icons.emoji_events,
                      label: '리그',
                      onPressed: () {
                        // TODO: Navigate to league screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('리그 화면 구현 예정')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrencyRow(IconData icon, String label, int amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
        Text('$amount', style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  void _startRace(BuildContext context, PlayerManager player) {
    // Spend fuel
    if (!player.spendFuel(10)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('연료가 부족합니다!')),
      );
      return;
    }

    // Get selected vehicle
    final vehicle = player.selectedVehicle;
    if (vehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('차량을 선택해주세요!')),
      );
      return;
    }

    // Start race on first available track (city1)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RaceScreen(
          track: Tracks.city1,
          vehicle: vehicle,
          equippedCardIds: player.equippedCardIds,
        ),
      ),
    ).then((result) {
      // Handle race results
      if (result != null && result is Map<String, dynamic>) {
        final position = result['position'] as int;
        final rewards = result['rewards'] as int;

        player.addCoins(rewards);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('레이스 완료! ${position}위 - 보상: $rewards 코인'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }
}
