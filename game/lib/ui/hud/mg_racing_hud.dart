import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';
import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:mg_common_game/core/ui/typography/mg_text_styles.dart';
import 'package:mg_common_game/core/ui/widgets/buttons/mg_icon_button.dart';
import 'package:mg_common_game/core/ui/widgets/progress/mg_linear_progress.dart';

/// MG-0018 Cartoon Racing RPG HUD
/// 레이싱 게임용 HUD - 속도, 부스트, 랩, 순위 표시
class MGRacingHud extends StatelessWidget {
  final int speed;
  final int maxSpeed;
  final double boost;
  final double maxBoost;
  final int currentLap;
  final int totalLaps;
  final int position;
  final int totalRacers;
  final Duration raceTime;
  final Duration? bestLapTime;
  final VoidCallback? onPause;
  final VoidCallback? onBoost;

  const MGRacingHud({
    super.key,
    required this.speed,
    required this.maxSpeed,
    required this.boost,
    required this.maxBoost,
    required this.currentLap,
    required this.totalLaps,
    required this.position,
    required this.totalRacers,
    required this.raceTime,
    this.bestLapTime,
    this.onPause,
    this.onBoost,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(MGSpacing.sm),
        child: Column(
          children: [
            // 상단 HUD
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 왼쪽: 순위
                _buildPositionBadge(),
                SizedBox(width: MGSpacing.sm),
                // 중앙: 랩 & 타임
                Expanded(child: _buildLapInfo()),
                SizedBox(width: MGSpacing.sm),
                // 오른쪽: 일시정지
                if (onPause != null)
                  MGIconButton(
                    icon: Icons.pause,
                    onPressed: onPause!,
                    size: MGIconButtonSize.small,
                  ),
              ],
            ),
            const Spacer(),
            // 하단 HUD
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 왼쪽 하단: 속도계
                _buildSpeedometer(),
                const Spacer(),
                // 오른쪽 하단: 부스트
                _buildBoostGauge(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionBadge() {
    Color positionColor;
    if (position == 1) {
      positionColor = Colors.amber;
    } else if (position == 2) {
      positionColor = Colors.grey[300]!;
    } else if (position == 3) {
      positionColor = Colors.brown[300]!;
    } else {
      positionColor = MGColors.surface;
    }

    return Container(
      padding: EdgeInsets.all(MGSpacing.sm),
      decoration: BoxDecoration(
        color: positionColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(MGSpacing.sm),
        border: Border.all(
          color: position <= 3 ? Colors.white : MGColors.border,
          width: 2,
        ),
        boxShadow: position == 1
            ? [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getPositionSuffix(position),
            style: MGTextStyles.h2.copyWith(
              color: position <= 3 ? Colors.black87 : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '/ $totalRacers',
            style: MGTextStyles.caption.copyWith(
              color: position <= 3 ? Colors.black54 : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLapInfo() {
    return Container(
      padding: EdgeInsets.all(MGSpacing.sm),
      decoration: BoxDecoration(
        color: MGColors.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(MGSpacing.sm),
        border: Border.all(color: MGColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 랩 카운터
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flag, color: Colors.white, size: 18),
              SizedBox(width: MGSpacing.xs),
              Text(
                'LAP $currentLap / $totalLaps',
                style: MGTextStyles.buttonMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: MGSpacing.xxs),
          // 타임
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer, color: MGColors.primaryAction, size: 16),
              SizedBox(width: MGSpacing.xxs),
              Text(
                _formatDuration(raceTime),
                style: MGTextStyles.h3.copyWith(
                  color: Colors.white,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          if (bestLapTime != null) ...[
            SizedBox(height: MGSpacing.xxs),
            Text(
              'Best: ${_formatDuration(bestLapTime!)}',
              style: MGTextStyles.caption.copyWith(
                color: Colors.greenAccent,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpeedometer() {
    final double speedRatio = speed / maxSpeed;

    return Container(
      padding: EdgeInsets.all(MGSpacing.sm),
      decoration: BoxDecoration(
        color: MGColors.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(MGSpacing.sm),
        border: Border.all(color: MGColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 속도 숫자
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                speed.toString(),
                style: MGTextStyles.h1.copyWith(
                  color: _getSpeedColor(speedRatio),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              SizedBox(width: MGSpacing.xxs),
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  'km/h',
                  style: MGTextStyles.caption.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MGSpacing.xs),
          // 속도 바
          SizedBox(
            width: 120,
            child: MGLinearProgress(
              value: speedRatio,
              height: 8,
              backgroundColor: Colors.grey.withOpacity(0.3),
              progressColor: _getSpeedColor(speedRatio),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoostGauge() {
    final double boostRatio = boost / maxBoost;
    final bool canBoost = boostRatio >= 0.2;

    return GestureDetector(
      onTap: canBoost ? onBoost : null,
      child: Container(
        padding: EdgeInsets.all(MGSpacing.sm),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: canBoost
                ? [
                    Colors.orange.withOpacity(0.8),
                    Colors.red.withOpacity(0.6),
                  ]
                : [
                    Colors.grey.withOpacity(0.5),
                    Colors.grey.withOpacity(0.3),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(MGSpacing.sm),
          border: Border.all(
            color: canBoost ? Colors.orange : Colors.grey,
            width: 2,
          ),
          boxShadow: canBoost
              ? [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bolt,
              color: canBoost ? Colors.yellow : Colors.grey[400],
              size: 32,
            ),
            SizedBox(height: MGSpacing.xxs),
            Text(
              'BOOST',
              style: MGTextStyles.buttonSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: MGSpacing.xs),
            // 부스트 게이지
            SizedBox(
              width: 60,
              child: MGLinearProgress(
                value: boostRatio,
                height: 10,
                backgroundColor: Colors.black26,
                progressColor: canBoost ? Colors.yellow : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSpeedColor(double ratio) {
    if (ratio > 0.8) return Colors.red;
    if (ratio > 0.6) return Colors.orange;
    if (ratio > 0.4) return Colors.yellow;
    return Colors.green;
  }

  String _getPositionSuffix(int pos) {
    if (pos == 1) return '1st';
    if (pos == 2) return '2nd';
    if (pos == 3) return '3rd';
    return '${pos}th';
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    final millis = (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return '$minutes:$seconds.$millis';
  }
}
