import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:mg_common_game/core/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/core/ui/theme/app_text_styles.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';

/// Race results screen shown after completing a race
class RaceResultsScreen extends StatelessWidget {
  final int position; // 1-4
  final String trackName;
  final String raceTime;
  final int coinsEarned;
  final int experienceEarned;
  final bool isNewBestTime;

  const RaceResultsScreen({
    super.key,
    required this.position,
    required this.trackName,
    required this.raceTime,
    required this.coinsEarned,
    required this.experienceEarned,
    this.isNewBestTime = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MGColors.backgroundDark.withValues(alpha: 0.9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(MGSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Result title
                _buildResultTitle(),

                const SizedBox(height: MGSpacing.xl),

                // Position medal
                _buildPositionMedal(),

                const SizedBox(height: MGSpacing.xl),

                // Track info
                Text(
                  trackName,
                  style: AppTextStyles.header2.copyWith(fontSize: 24),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: MGSpacing.lg),

                // Race stats card
                _buildStatsCard(),

                const SizedBox(height: MGSpacing.lg),

                // Rewards card
                _buildRewardsCard(),

                const SizedBox(height: MGSpacing.xl),

                // Buttons
                _buildButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultTitle() {
    final title = position == 1
        ? '승리!'
        : position <= 3
            ? '입상!'
            : '완주!';

    final color = position == 1
        ? MGColors.gold
        : position <= 3
            ? MGColors.warning
            : MGColors.common;

    return Text(
      title,
      style: AppTextStyles.header1.copyWith(
        fontSize: 48,
        color: color,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPositionMedal() {
    final color = _getPositionColor();
    final icon = _getPositionIcon();

    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.2),
        border: Border.all(color: color, width: 4),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 64),
          const SizedBox(height: MGSpacing.xs),
          Text(
            '$position위',
            style: TextStyle(
              color: color,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      color: AppColors.panel,
      child: Padding(
        padding: const EdgeInsets.all(MGSpacing.mdLg),
        child: Column(
          children: [
            Text('레이스 기록', style: AppTextStyles.header2),
            const SizedBox(height: MGSpacing.md),
            _buildStatRow(Icons.timer, '완주 시간', raceTime),
            if (isNewBestTime) ...[
              const SizedBox(height: MGSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: MGColors.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: MGColors.gold),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: MGColors.gold, size: 16),
                    const SizedBox(width: MGSpacing.xxs),
                    Text(
                      '신기록!',
                      style: TextStyle(
                        color: MGColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsCard() {
    return Card(
      color: AppColors.panel,
      child: Padding(
        padding: const EdgeInsets.all(MGSpacing.mdLg),
        child: Column(
          children: [
            Text('보상', style: AppTextStyles.header2),
            const SizedBox(height: MGSpacing.md),
            _buildRewardRow(Icons.monetization_on, '코인', '+$coinsEarned', MGColors.gold),
            const SizedBox(height: MGSpacing.sm),
            _buildRewardRow(Icons.trending_up, '경험치', '+$experienceEarned', MGColors.info),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(width: MGSpacing.sm),
            Text(label, style: AppTextStyles.body),
          ],
        ),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardRow(IconData icon, String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(width: MGSpacing.sm),
            Text(label, style: AppTextStyles.body),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        // Continue button
        SizedBox(
          width: 200,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context, {
                'position': position,
                'rewards': coinsEarned,
              });
            },
            icon: const Icon(Icons.check_circle, size: 28),
            label: const Text('확인', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),

        const SizedBox(height: MGSpacing.sm),

        // Race again button
        SizedBox(
          width: 200,
          child: OutlinedButton.icon(
            onPressed: () {
              // Pop twice: results screen + race screen, to return to home and race again
              Navigator.pop(context);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.replay, size: 24),
            label: const Text('다시 경주', style: TextStyle(fontSize: 16)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Color _getPositionColor() {
    switch (position) {
      case 1:
        return MGColors.gold; // Gold
      case 2:
        return MGColors.common; // Silver
      case 3:
        return MGColors.warning; // Bronze
      default:
        return MGColors.common; // Default
    }
  }

  IconData _getPositionIcon() {
    switch (position) {
      case 1:
        return Icons.emoji_events; // Trophy
      case 2:
        return Icons.military_tech; // Medal
      case 3:
        return Icons.workspace_premium; // Badge
      default:
        return Icons.check_circle; // Checkmark
    }
  }
}
