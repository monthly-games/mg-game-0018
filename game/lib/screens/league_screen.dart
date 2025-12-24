import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/core/ui/theme/app_text_styles.dart';

import '../features/player/player_manager.dart';
import '../game/tracks/track_data.dart';

/// League tier data
class LeagueTier {
  final int level;
  final String name;
  final String nameKo;
  final Color color;
  final IconData icon;
  final int requiredWins; // Wins needed to unlock
  final int promotionReward; // Coins rewarded on promotion

  const LeagueTier({
    required this.level,
    required this.name,
    required this.nameKo,
    required this.color,
    required this.icon,
    required this.requiredWins,
    required this.promotionReward,
  });
}

class LeagueScreen extends StatefulWidget {
  const LeagueScreen({super.key});

  @override
  State<LeagueScreen> createState() => _LeagueScreenState();
}

class _LeagueScreenState extends State<LeagueScreen> {
  // League tiers
  static const leagueTiers = [
    LeagueTier(
      level: 1,
      name: 'Bronze',
      nameKo: '브론즈',
      color: Colors.brown,
      icon: Icons.workspace_premium,
      requiredWins: 0,
      promotionReward: 0,
    ),
    LeagueTier(
      level: 2,
      name: 'Silver',
      nameKo: '실버',
      color: Colors.grey,
      icon: Icons.military_tech,
      requiredWins: 5,
      promotionReward: 500,
    ),
    LeagueTier(
      level: 3,
      name: 'Gold',
      nameKo: '골드',
      color: Colors.amber,
      icon: Icons.emoji_events,
      requiredWins: 15,
      promotionReward: 1500,
    ),
    LeagueTier(
      level: 4,
      name: 'Platinum',
      nameKo: '플래티넘',
      color: Colors.cyan,
      icon: Icons.stars,
      requiredWins: 30,
      promotionReward: 3000,
    ),
    LeagueTier(
      level: 5,
      name: 'Diamond',
      nameKo: '다이아몬드',
      color: Colors.blue,
      icon: Icons.diamond,
      requiredWins: 50,
      promotionReward: 5000,
    ),
  ];

  // Mock player stats (in real implementation, these would come from PlayerManager)
  final int _totalWins = 0;
  final int _totalRaces = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('리그'),
        backgroundColor: AppColors.primary,
      ),
      body: Consumer<PlayerManager>(
        builder: (context, player, child) {
          final currentLeague = leagueTiers[player.currentLeague - 1];
          final nextLeague = player.currentLeague < 5
              ? leagueTiers[player.currentLeague]
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current league card
                _buildCurrentLeagueCard(currentLeague, player),

                const SizedBox(height: 24),

                // Player stats
                Text('레이싱 기록', style: AppTextStyles.header1),
                const SizedBox(height: 12),
                _buildStatsPanel(),

                const SizedBox(height: 24),

                // Next league promotion
                if (nextLeague != null) ...[
                  Text('다음 승급', style: AppTextStyles.header1),
                  const SizedBox(height: 12),
                  _buildPromotionCard(nextLeague, player),
                  const SizedBox(height: 24),
                ],

                // All leagues
                Text('모든 리그', style: AppTextStyles.header1),
                const SizedBox(height: 12),
                _buildAllLeagues(player),

                const SizedBox(height: 24),

                // Available tracks by league
                Text('사용 가능한 트랙', style: AppTextStyles.header1),
                const SizedBox(height: 12),
                _buildAvailableTracks(player),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentLeagueCard(LeagueTier league, PlayerManager player) {
    return Card(
      color: league.color.withOpacity(0.2),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: league.color, width: 3),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('현재 리그', style: AppTextStyles.caption),
            const SizedBox(height: 8),
            Icon(league.icon, color: league.color, size: 64),
            const SizedBox(height: 12),
            Text(
              league.nameKo,
              style: AppTextStyles.header1.copyWith(
                color: league.color,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Level ${league.level}',
              style: AppTextStyles.body.copyWith(color: league.color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsPanel() {
    final winRate = _totalRaces > 0
        ? ((_totalWins / _totalRaces) * 100).toStringAsFixed(1)
        : '0.0';

    return Card(
      color: AppColors.panel,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatColumn('총 레이스', '$_totalRaces', Icons.flag),
            _buildStatColumn('승리', '$_totalWins', Icons.emoji_events),
            _buildStatColumn('승률', '$winRate%', Icons.trending_up),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: AppColors.primary),
        const SizedBox(height: 8),
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.header2.copyWith(fontSize: 20),
        ),
      ],
    );
  }

  Widget _buildPromotionCard(LeagueTier nextLeague, PlayerManager player) {
    final winsNeeded = nextLeague.requiredWins - _totalWins;
    final canPromote = winsNeeded <= 0;

    return Card(
      color: AppColors.panel,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(nextLeague.icon, color: nextLeague.color, size: 48),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nextLeague.nameKo,
                    style: AppTextStyles.header2.copyWith(color: nextLeague.color),
                  ),
                  const SizedBox(height: 4),
                  if (canPromote) ...[
                    Text(
                      '승급 가능!',
                      style: AppTextStyles.body.copyWith(color: Colors.green),
                    ),
                    Text(
                      '보상: ${nextLeague.promotionReward} 코인',
                      style: AppTextStyles.caption,
                    ),
                  ] else ...[
                    Text(
                      '필요 승수: $winsNeeded',
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: _totalWins / nextLeague.requiredWins,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(nextLeague.color),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            if (canPromote)
              ElevatedButton(
                onPressed: () => _promoteLeague(player, nextLeague),
                style: ElevatedButton.styleFrom(
                  backgroundColor: nextLeague.color,
                ),
                child: const Text('승급'),
              )
            else
              const SizedBox(width: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildAllLeagues(PlayerManager player) {
    return Column(
      children: leagueTiers.map((league) {
        final isCurrentLeague = league.level == player.currentLeague;
        final isUnlocked = league.level <= player.currentLeague;

        return Card(
          color: isCurrentLeague
              ? league.color.withOpacity(0.2)
              : (isUnlocked ? AppColors.panel : Colors.grey[850]),
          child: ListTile(
            leading: Icon(
              league.icon,
              color: isUnlocked ? league.color : Colors.grey,
              size: 32,
            ),
            title: Text(
              league.nameKo,
              style: AppTextStyles.body.copyWith(
                color: isUnlocked ? league.color : Colors.grey,
                fontWeight: isCurrentLeague ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              isCurrentLeague
                  ? '현재 리그'
                  : (isUnlocked
                      ? '달성 완료'
                      : '${league.requiredWins}승 필요'),
              style: AppTextStyles.caption,
            ),
            trailing: isCurrentLeague
                ? const Icon(Icons.check_circle, color: Colors.green)
                : (isUnlocked
                    ? const Icon(Icons.lock_open, color: Colors.grey)
                    : const Icon(Icons.lock, color: Colors.grey)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAvailableTracks(PlayerManager player) {
    final availableTracks = Tracks.all
        .where((track) => track.requiredLeague <= player.currentLeague)
        .toList();

    final lockedTracks = Tracks.all
        .where((track) => track.requiredLeague > player.currentLeague)
        .toList();

    return Column(
      children: [
        // Available tracks
        ...availableTracks.map((track) => _buildTrackCard(track, true)),

        // Locked tracks
        if (lockedTracks.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            '잠긴 트랙',
            style: AppTextStyles.caption.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ...lockedTracks.map((track) => _buildTrackCard(track, false)),
        ],
      ],
    );
  }

  Widget _buildTrackCard(Track track, bool isUnlocked) {
    return Card(
      color: isUnlocked ? AppColors.panel : Colors.grey[850],
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isUnlocked ? track.roadColor : Colors.grey,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isUnlocked ? track.borderColor : Colors.grey[700]!,
              width: 2,
            ),
          ),
          child: Center(
            child: Icon(
              _getTrackTypeIcon(track.type),
              color: isUnlocked ? track.borderColor : Colors.grey[600],
            ),
          ),
        ),
        title: Text(
          track.nameKo,
          style: AppTextStyles.body.copyWith(
            color: isUnlocked ? Colors.white : Colors.grey,
          ),
        ),
        subtitle: Text(
          isUnlocked
              ? _getTrackTypeText(track.type)
              : '${leagueTiers[track.requiredLeague - 1].nameKo} 리그 필요',
          style: AppTextStyles.caption,
        ),
        trailing: isUnlocked
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.lock, color: Colors.grey),
      ),
    );
  }

  IconData _getTrackTypeIcon(TrackType type) {
    switch (type) {
      case TrackType.city:
        return Icons.location_city;
      case TrackType.desert:
        return Icons.wb_sunny;
      case TrackType.snow:
        return Icons.ac_unit;
      case TrackType.forest:
        return Icons.forest;
      case TrackType.beach:
        return Icons.beach_access;
      case TrackType.mountain:
        return Icons.terrain;
      case TrackType.volcano:
        return Icons.local_fire_department;
      case TrackType.space:
        return Icons.rocket_launch;
    }
  }

  String _getTrackTypeText(TrackType type) {
    switch (type) {
      case TrackType.city:
        return '도시';
      case TrackType.desert:
        return '사막';
      case TrackType.snow:
        return '설원';
      case TrackType.forest:
        return '숲';
      case TrackType.beach:
        return '해변';
      case TrackType.mountain:
        return '산악';
      case TrackType.volcano:
        return '화산';
      case TrackType.space:
        return '우주';
    }
  }

  void _promoteLeague(PlayerManager player, LeagueTier nextLeague) {
    player.promoteLeague();
    player.addCoins(nextLeague.promotionReward);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('승급 축하!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(nextLeague.icon, color: nextLeague.color, size: 80),
            const SizedBox(height: 16),
            Text(
              nextLeague.nameKo,
              style: AppTextStyles.header1.copyWith(
                color: nextLeague.color,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${nextLeague.promotionReward} 코인 획득!',
              style: AppTextStyles.body.copyWith(
                color: Colors.yellow,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '새로운 트랙이 해금되었습니다!',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );

    setState(() {
      // Refresh UI
    });
  }
}
