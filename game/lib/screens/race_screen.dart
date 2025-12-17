import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:mg_common_game/core/ui/theme/app_text_styles.dart';
import '../game/racing_game.dart';
import '../game/tracks/track_data.dart';
import '../features/vehicles/vehicle_data.dart';
import '../features/cards/card_data.dart';
import 'race_results_screen.dart';
import 'dart:async';

/// Race screen with game and HUD overlay
class RaceScreen extends StatefulWidget {
  final Track track;
  final Vehicle vehicle;
  final VehicleStats vehicleStats;
  final List<String> equippedCardIds;

  const RaceScreen({
    super.key,
    required this.track,
    required this.vehicle,
    required this.vehicleStats,
    required this.equippedCardIds,
  });

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen> {
  late RacingGame game;
  Timer? _raceCheckTimer;
  bool _resultsShown = false;

  @override
  void initState() {
    super.initState();
    game = RacingGame(
      track: widget.track,
      playerVehicle: widget.vehicle,
      playerVehicleStats: widget.vehicleStats,
      equippedCardIds: widget.equippedCardIds,
    );

    // Check for race finish every 100ms
    _raceCheckTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (game.raceState == RaceState.finished && !_resultsShown) {
        _resultsShown = true;
        _showResults();
      }
    });
  }

  @override
  void dispose() {
    _raceCheckTimer?.cancel();
    super.dispose();
  }

  void _showResults() {
    // Calculate rewards based on position
    final position = game.playerFinalPosition;
    final rewards = _calculateRewards(position);
    final experience = _calculateExperience(position);

    // Wait a moment before showing results
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RaceResultsScreen(
            position: position,
            trackName: widget.track.nameKo,
            raceTime: game.formattedRaceTime,
            coinsEarned: rewards,
            experienceEarned: experience,
            isNewBestTime: false, // TODO: Track best times
          ),
        ),
      );
    });
  }

  int _calculateRewards(int position) {
    // Rewards based on position
    switch (position) {
      case 1:
        return 100;
      case 2:
        return 60;
      case 3:
        return 30;
      default:
        return 10;
    }
  }

  int _calculateExperience(int position) {
    // Experience based on position
    switch (position) {
      case 1:
        return 50;
      case 2:
        return 35;
      case 3:
        return 20;
      default:
        return 10;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Game
          GameWidget(game: game),

          // HUD Overlay
          _buildHUD(),
        ],
      ),
    );
  }

  Widget _buildHUD() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top bar: Time, Rank, Lap
            _buildTopBar(),

            const Spacer(),

            // Bottom: Card abilities
            _buildCardBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return StreamBuilder<int>(
      stream: Stream.periodic(const Duration(milliseconds: 100)),
      builder: (context, snapshot) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Time
              _buildStatBox(
                icon: Icons.timer,
                label: '시간',
                value: game.formattedRaceTime,
              ),

              // Rank
              _buildStatBox(
                icon: Icons.emoji_events,
                label: '순위',
                value: '${game.playerRank}/4',
                color: _getRankColor(game.playerRank),
              ),

              // Lap
              _buildStatBox(
                icon: Icons.loop,
                label: '랩',
                value: '${game.playerVehicleComponent.currentLap}/${game.totalLaps}',
              ),

              // Speed
              _buildStatBox(
                icon: Icons.speed,
                label: '속도',
                value: '${game.playerVehicleComponent.currentSpeed.toInt()}',
              ),

              // Back button
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatBox({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color ?? Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: Colors.white70),
        ),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            color: color ?? Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.orange[300]!;
      default:
        return Colors.white;
    }
  }

  Widget _buildCardBar() {
    return StreamBuilder<int>(
      stream: Stream.periodic(const Duration(milliseconds: 100)),
      builder: (context, snapshot) {
        if (game.raceState != RaceState.racing) {
          // Show countdown or finished message
          return _buildRaceStateMessage();
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 0; i < game.equippedCards.length; i++)
                _buildCardButton(i),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardButton(int index) {
    final card = game.equippedCards[index];
    final cooldown = game.cardCooldowns[card.id] ?? 0;
    final isReady = cooldown <= 0;

    return GestureDetector(
      onTap: isReady ? () => game.useCard(index) : null,
      child: Container(
        width: 80,
        height: 100,
        decoration: BoxDecoration(
          color: isReady
              ? _getCardRarityColor(card.rarity).withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
          border: Border.all(
            color: isReady
                ? _getCardRarityColor(card.rarity)
                : Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // Card icon
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getCardIcon(card.type),
                    color: isReady ? Colors.white : Colors.grey,
                    size: 32,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.nameKo,
                    style: AppTextStyles.caption.copyWith(
                      color: isReady ? Colors.white : Colors.grey,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Cooldown overlay
            if (!isReady)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${cooldown.ceil()}s',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

            // Ready indicator
            if (isReady)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.5),
                        blurRadius: 4,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRaceStateMessage() {
    String message = '';
    Color color = Colors.white;

    switch (game.raceState) {
      case RaceState.countdown:
        final count = game.countdownTimer.ceil();
        message = count > 0 ? '$count' : 'GO!';
        color = count > 0 ? Colors.yellow : Colors.green;
        break;
      case RaceState.finished:
        message = '레이스 완료!';
        color = Colors.amber;
        break;
      case RaceState.racing:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: AppTextStyles.header1.copyWith(
          color: color,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getCardRarityColor(CardRarity rarity) {
    switch (rarity) {
      case CardRarity.common:
        return Colors.grey;
      case CardRarity.rare:
        return Colors.blue;
      case CardRarity.epic:
        return Colors.purple;
      case CardRarity.legendary:
        return Colors.amber;
    }
  }

  IconData _getCardIcon(CardType type) {
    switch (type) {
      case CardType.boost:
        return Icons.flash_on;
      case CardType.shield:
        return Icons.shield;
      case CardType.missile:
        return Icons.rocket_launch;
      case CardType.slowdown:
        return Icons.slow_motion_video;
      case CardType.magnet:
        return Icons.attractions;
      case CardType.jump:
        return Icons.arrow_upward;
      case CardType.repair:
        return Icons.healing;
    }
  }
}
