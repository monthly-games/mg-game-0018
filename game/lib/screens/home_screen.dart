import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/core/ui/theme/app_text_styles.dart';

import '../features/player/player_manager.dart';

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

                // Placeholder buttons
                Text('레이싱 게임 코어 메커니즘 구현 필요', style: AppTextStyles.body),
                Text('차량 물리, 트랙, AI 경쟁자 등', style: AppTextStyles.caption),
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
}
