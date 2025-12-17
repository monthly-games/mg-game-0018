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
              // Upgrade level indicator
              _buildUpgradeLevel(player, vehicle),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(child: _buildStatBar('속도', player.getUpgradedStats(vehicle).speed, Colors.red, vehicle.baseStats.speed)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildStatBar('가속', player.getUpgradedStats(vehicle).acceleration, Colors.orange, vehicle.baseStats.acceleration)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildStatBar('핸들링', player.getUpgradedStats(vehicle).handling, Colors.blue, vehicle.baseStats.handling)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildStatBar('부스트', player.getUpgradedStats(vehicle).boost, Colors.purple, vehicle.baseStats.boost)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('종합 평가: ', style: AppTextStyles.body),
                  Text(
                    '${player.getUpgradedStats(vehicle).overall.toStringAsFixed(1)}/10',
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
                if (isUnlocked)
                  const SizedBox(width: 8),
                if (isUnlocked)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: player.getVehicleUpgradeLevel(vehicle.id) < 5
                          ? () => _upgradeVehicle(context, player, vehicle)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                      ),
                      child: Text(
                        player.getVehicleUpgradeLevel(vehicle.id) >= 5
                            ? '최대 강화'
                            : '강화',
                      ),
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

  Widget _buildStatBar(String label, double value, Color color, [double? baseValue]) {
    final isUpgraded = baseValue != null && value > baseValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTextStyles.caption),
            if (isUpgraded) ...[
              const SizedBox(width: 4),
              Text(
                '+${((value - baseValue!) / baseValue * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.green,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
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
          '${value.toStringAsFixed(1)}/10',
          style: AppTextStyles.caption.copyWith(fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildUpgradeLevel(PlayerManager player, Vehicle vehicle) {
    final upgradeLevel = player.getVehicleUpgradeLevel(vehicle.id);

    return Row(
      children: [
        const Icon(Icons.trending_up, size: 16, color: Colors.purple),
        const SizedBox(width: 4),
        Text('강화 레벨:', style: AppTextStyles.caption),
        const SizedBox(width: 8),
        ...List.generate(5, (index) {
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              index < upgradeLevel ? Icons.star : Icons.star_border,
              size: 16,
              color: index < upgradeLevel ? Colors.amber : Colors.grey,
            ),
          );
        }),
        const SizedBox(width: 8),
        Text(
          '$upgradeLevel/5',
          style: AppTextStyles.caption.copyWith(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _upgradeVehicle(BuildContext context, PlayerManager player, Vehicle vehicle) {
    final currentLevel = player.getVehicleUpgradeLevel(vehicle.id);
    if (currentLevel >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미 최대 강화 레벨입니다!')),
      );
      return;
    }

    // Calculate upgrade cost (exponential)
    final upgradeCost = _getUpgradeCost(currentLevel + 1);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('차량 강화'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              vehicle.nameKo,
              style: AppTextStyles.header2,
            ),
            const SizedBox(height: 16),
            Text('강화 레벨: $currentLevel → ${currentLevel + 1}'),
            const SizedBox(height: 8),
            Text('모든 스탯 +10%'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on, color: Colors.yellow),
                const SizedBox(width: 4),
                Text(
                  '$upgradeCost 코인',
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (player.coins < upgradeCost)
              const Text(
                '코인이 부족합니다!',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: player.coins >= upgradeCost
                ? () {
                    if (player.upgradeVehicle(vehicle.id, upgradeCost)) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${vehicle.nameKo} 강화 완료! (레벨 ${currentLevel + 1})'),
                        ),
                      );
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
            ),
            child: const Text('강화'),
          ),
        ],
      ),
    );
  }

  int _getUpgradeCost(int targetLevel) {
    // Exponential cost: 500, 1000, 2000, 4000, 8000
    return 500 * (1 << (targetLevel - 1));
  }
}
