import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:mg_common_game/core/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/core/ui/theme/app_text_styles.dart';import 'package:mg_common_game/l10n/localization.dart';


import '../features/player/player_manager.dart';
import '../features/save/save_manager.dart';
import 'achievement_screen.dart';
import 'daily_quest_screen.dart';
import 'race_screen.dart';
import 'garage_screen.dart';
import 'deck_screen.dart';
import 'shop_screen.dart';
import 'league_screen.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Show tutorial on first launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTutorial();
    });
  }

  Future<void> _checkAndShowTutorial() async {
    final saveManager = Provider.of<SaveManager>(context, listen: false);
    final hasSave = await saveManager.hasSaveData();

    // Show tutorial only for new players
    if (!hasSave && mounted) {
      _showTutorial();
    }
  }

  void _showTutorial() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.directions_car, color: AppColors.primary, size: 32),
            const SizedBox(width: MGSpacing.sm),
            const Expanded(child: Text('ui_general_환영합니다'.tr)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('카툰 레이싱 RPG', style: AppTextStyles.header2),
              const SizedBox(height: MGSpacing.md),
              _buildTutorialStep('🏎️', '차량 선택', '차고에서 차량을 해금하고 강화'),
              const SizedBox(height: MGSpacing.sm),
              _buildTutorialStep('🃏', '카드 덱', '능력 카드로 전략적인 덱 구성'),
              const SizedBox(height: MGSpacing.sm),
              _buildTutorialStep('🏁', '레이스', '연료로 레이스 참가 및 보상 획득'),
              const SizedBox(height: MGSpacing.sm),
              _buildTutorialStep('🏪', '상점', '코인으로 아이템 구매'),
              const SizedBox(height: MGSpacing.sm),
              _buildTutorialStep('🏆', '리그', '승급으로 새 트랙과 차량 해금'),
              const SizedBox(height: MGSpacing.md),
              Container(
                padding: const EdgeInsets.all(MGSpacing.sm),
                decoration: BoxDecoration(
                  color: MGColors.info.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: MGColors.info),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: MGColors.info, size: 20),
                    const SizedBox(width: MGSpacing.xs),
                    Expanded(
                      child: Text(
                        '연료는 1분에 1씩 자동 회복됩니다!',
                        style: AppTextStyles.caption.copyWith(color: MGColors.info),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.check),
            label: Text('ui_general_시작하기'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialStep(String emoji, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: MGSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: MGSpacing.xxs),
              Text(description, style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ui_general_cartoon_racing_rpg'.tr),
        backgroundColor: AppColors.primary,
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
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final saveManager = Provider.of<SaveManager>(context, listen: false);
              final success = await saveManager.saveGame();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '게임이 저장되었습니다' : '저장 실패'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
            tooltip: '게임 저장',
          ),
        ],
      ),
      body: Consumer<PlayerManager>(
        builder: (context, player, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('카툰 레이싱 RPG', style: AppTextStyles.header1),
                const SizedBox(height: MGSpacing.xl),

                // Currency display
                Card(
                  color: AppColors.panel,
                  child: Padding(
                    padding: const EdgeInsets.all(MGSpacing.md),
                    child: Column(
                      children: [
                        _buildCurrencyRow(Icons.monetization_on, '코인', player.coins, MGColors.gold),
                        const SizedBox(height: MGSpacing.xs),
                        _buildCurrencyRow(Icons.diamond, '다이아몬드', player.diamonds, MGColors.energy),
                        const SizedBox(height: MGSpacing.xs),
                        _buildCurrencyRow(Icons.local_gas_station, '연료', player.fuel, MGColors.warning),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: MGSpacing.xl),

                // Current vehicle
                Card(
                  color: AppColors.panel,
                  child: Padding(
                    padding: const EdgeInsets.all(MGSpacing.md),
                    child: Column(
                      children: [
                        Text('현재 차량', style: AppTextStyles.header2),
                        const SizedBox(height: MGSpacing.xs),
                        Text(player.selectedVehicle?.nameKo ?? '없음',
                             style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: MGSpacing.xs),
                        if (player.selectedVehicle != null) ...[
                          Text('progress_속도_playerselectedvehiclebasestatsspeed10'.tr),
                          Text('progress_가속_playerselectedvehiclebasestatsacceleration10'.tr),
                          Text('progress_핸들링_playerselectedvehiclebasestatshandling10'.tr),
                          Text('progress_부스트_playerselectedvehiclebasestatsboost10'.tr),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: MGSpacing.xl),

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

                const SizedBox(height: MGSpacing.md),

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
                      label: 'ui_general_'.tr카드_덱,
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ShopScreen()),
                        );
                      },
                    ),
                    _buildMenuButton(
                      context,
                      icon: Icons.emoji_events,
                      label: 'ui_general_'.tr모든_리그,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LeagueScreen()),
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
            const SizedBox(width: MGSpacing.xs),
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

  void _startRace(BuildContext context, PlayerManager player) async {
    // Spend fuel
    if (!player.spendFuel(10)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ui_general_연료가_부족합니다'.tr)),
      );
      return;
    }

    // Get selected vehicle
    final vehicle = player.selectedVehicle;
    if (vehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ui_general_차량을_선택해주세요'.tr)),
      );
      return;
    }

    // Get upgraded stats

    // Start race on first available track (city1)
    final saveManager = Provider.of<SaveManager>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RaceScreen(),
      ),
    );
    // Handle race results
    if (result != null && result is Map<String, dynamic>) {
      final position = result['position'] as int;
      final rewards = result['rewards'] as int;

      player.addCoins(rewards);

      // Auto-save after race
      await saveManager.saveGame();

      messenger.showSnackBar(
        SnackBar(
          content: Text('notification_레이스_완료_position위_보상_rewards'.tr),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
