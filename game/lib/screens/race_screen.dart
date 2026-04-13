import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:mg_common_game/core/localization/localization.dart';
import 'package:flutter/material.dart';
import '../core/game_manager.dart';
import '../features/racing/logic/race_engine.dart';
import '../features/racing/data/track_data.dart';
import '../features/racing/models/track.dart';
import '../core/audio_manager.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';import 'package:mg_common_game/l10n/localization.dart';


class RaceScreen extends StatefulWidget {
  const RaceScreen({super.key});

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen> {
  Track _selectedTrack = TrackData.beginnerLoop;
  final RaceEngine _engine = RaceEngine();
  bool _isRacing = false;
  RaceResult? _lastResult;

  void _startRace() async {
    AudioManager().playSfx('race_start');
    setState(() {
      _isRacing = true;
      _lastResult = null;
    });

    // Simulate delay
    await Future.delayed(const Duration(seconds: 2));

    final playerVehicle = GameManager().garage.equippedVehicle;
    if (playerVehicle == null) return; // Should not happen

    final result = _engine.simulateRace(
      vehicle: playerVehicle,
      activeCards: GameManager().cards.deck,
      track: _selectedTrack,
      opponentCount: 5,
    );

    if (mounted) {
      setState(() {
        _isRacing = false;
        _lastResult = result;
      });

      if (result.isWin) {
        AudioManager().playSfx('win');
        GameManager().economy.addCoins(result.coinsEarned);
      } else {
        AudioManager().playSfx('finish');
      }

      _showResultDialog(result);
    }
  }

  void _showResultDialog(RaceResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(result.isWin ? 'VICTORY!' : 'Race Finished'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ui_general_position_resultposition_6'.tr),
            Text('ui_general_time_resulttimems_1000tostringasfixed2s'.tr),
            Text('ui_general_earnings_resultcoinsearned_coins'.tr),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ui_general_diwali_token_collection'.tr),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final garage = GameManager().garage;

    return Scaffold(
      appBar: AppBar(title: Text('ui_general_race_simulation'.tr)),
      body: Padding(
        padding: const EdgeInsets.all(MGSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Vehicle Info
            Card(
              child: ListTile(
                title: Text(
                  'Driver: ${garage.equippedVehicle?.name ?? "None"}',
                ),
                subtitle: Text('ui_general_ready_to_race'.tr),
                leading: const Icon(Icons.directions_car),
              ),
            ),
            const SizedBox(height: MGSpacing.mdLg),

            // Track Selection
            const Text('Select Track:', style: TextStyle(fontSize: 18)),
            DropdownButton<Track>(
              value: _selectedTrack,
              isExpanded: true,
              items: TrackData.getAllTracks().map((track) {
                return DropdownMenuItem(
                  value: track,
                  child: Text('ui_general_trackname_tracklengthmetersm'.tr),
                );
              }).toList(),
              onChanged: _isRacing
                  ? null
                  : (val) {
                      if (val != null) setState(() => _selectedTrack = val);
                    },
            ),

            const Spacer(),

            // Race Action
            if (_isRacing)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _startRace,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(MGSpacing.lg),
                  backgroundColor: MGColors.success,
                  foregroundColor: MGColors.textHighEmphasis,
                ),
                child: const Text('START RACE', style: TextStyle(fontSize: 24)),
              ),

            const SizedBox(height: MGSpacing.mdLg),
            if (_lastResult != null)
              Text(
                'Last Run: ${_lastResult!.position}th Place',
                textAlign: TextAlign.center,
                style: const TextStyle(color: MGColors.common),
              ),
          ],
        ),
      ),
    );
  }
}
