import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/core/ui/theme/app_text_styles.dart';

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
      backgroundColor: Colors.black.withOpacity(0.9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Result title
                _buildResultTitle(),

                const SizedBox(height: 32),

                // Position medal
                _buildPositionMedal(),

                const SizedBox(height: 32),

                // Track info
                Text(
                  trackName,
                  style: AppTextStyles.header2.copyWith(fontSize: 24),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Race stats card
                _buildStatsCard(),

                const SizedBox(height: 24),

                // Rewards card
                _buildRewardsCard(),

                const SizedBox(height: 32),

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
        ? Colors.amber
        : position <= 3
            ? Colors.orange
            : Colors.grey;

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
        color: color.withOpacity(0.2),
        border: Border.all(color: color, width: 4),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 64),
          const SizedBox(height: 8),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('레이스 기록', style: AppTextStyles.header2),
            const SizedBox(height: 16),
            _buildStatRow(Icons.timer, '완주 시간', raceTime),
            if (isNewBestTime) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '신기록!',
                      style: TextStyle(
                        color: Colors.amber,
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('보상', style: AppTextStyles.header2),
            const SizedBox(height: 16),
            _buildRewardRow(Icons.monetization_on, '코인', '+$coinsEarned', Colors.yellow),
            const SizedBox(height: 12),
            _buildRewardRow(Icons.trending_up, '경험치', '+$experienceEarned', Colors.blue),
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
            const SizedBox(width: 12),
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
            const SizedBox(width: 12),
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

        const SizedBox(height: 12),

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
        return Colors.amber; // Gold
      case 2:
        return Colors.grey[400]!; // Silver
      case 3:
        return Colors.orange[300]!; // Bronze
      default:
        return Colors.grey; // Default
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
