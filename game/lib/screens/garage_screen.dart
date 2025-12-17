import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/core/ui/theme/app_text_styles.dart';
import '../features/player/player_manager.dart';
import '../features/vehicles/vehicle_data.dart';

/// Garage screen for vehicle selection and upgrades
class GarageScreen extends StatelessWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('차고'),
        backgroundColor: AppColors.primary,
      ),
      body: Consumer<PlayerManager>(
        builder: (context, player, child) {
          return Column(
            children: [
              // Currency display
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.panel,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCurrency(Icons.monetization_on, '코인', player.coins, Colors.yellow),
                    _buildCurrency(Icons.diamond, '다이아', player.diamonds, Colors.cyan),
                  ],
                ),
              ),

              // Vehicle list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: Vehicles.all.length,
                  itemBuilder: (context, index) {
                    final vehicle = Vehicles.all[index];
                    final isUnlocked = player.unlockedVehicles.contains(vehicle.id);
                    final isSelected = player.selectedVehicleId == vehicle.id;

                    return _buildVehicleCard(
                      context,
                      vehicle,
                      isUnlocked,
                      isSelected,
                      player,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrency(IconData icon, String label, int amount, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.body),
        const SizedBox(width: 8),
        Text(
          '$amount',
          style: AppTextStyles.body.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleCard(
    BuildContext context,
    Vehicle vehicle,
    bool isUnlocked,
    bool isSelected,
    PlayerManager player,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isSelected ? AppColors.primary.withOpacity(0.3) : AppColors.panel,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.nameKo,
                        style: AppTextStyles.header2,
                      ),
                      Text(
                        vehicle.name,
                        style: AppTextStyles.caption.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '선택됨',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Stats
            if (isUnlocked) ...[
              Row(
                children: [
                  Expanded(child: _buildStatBar('속도', vehicle.baseStats.speed, Colors.red)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildStatBar('가속', vehicle.baseStats.acceleration, Colors.orange)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildStatBar('핸들링', vehicle.baseStats.handling, Colors.blue)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildStatBar('부스트', vehicle.baseStats.boost, Colors.purple)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('종합 평가: ', style: AppTextStyles.body),
                  Text(
                    '${vehicle.baseStats.overall.toStringAsFixed(1)}/10',
                    style: AppTextStyles.body.copyWith(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Locked info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lock, color: Colors.white70),
                        const SizedBox(width: 8),
                        Text(
                          '잠김 - 레벨 ${vehicle.unlockLevel} 필요',
                          style: AppTextStyles.body.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.yellow, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${vehicle.unlockCost} 코인',
                          style: AppTextStyles.body.copyWith(color: Colors.yellow),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                if (isUnlocked && !isSelected)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        player.selectVehicle(vehicle.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${vehicle.nameKo} 선택됨')),
                        );
                      },
                      child: const Text('선택하기'),
                    ),
                  ),
                if (!isUnlocked)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: player.currentLeague >= vehicle.unlockLevel &&
                              player.coins >= vehicle.unlockCost
                          ? () {
                              if (player.unlockVehicle(vehicle.id, vehicle.unlockCost)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${vehicle.nameKo} 잠금 해제!')),
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('잠금 해제'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: value / 10,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${value.toInt()}/10',
          style: AppTextStyles.caption.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}
