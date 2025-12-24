import 'package:flutter/material.dart';
import '../core/game_manager.dart';
import '../features/racing/logic/race_engine.dart';
import '../features/racing/data/track_data.dart';
import '../features/racing/models/track.dart';
import '../core/audio_manager.dart';

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
            Text('Position: ${result.position} / 6'),
            Text('Time: ${(result.timeMs / 1000).toStringAsFixed(2)}s'),
            Text('Earnings: ${result.coinsEarned} Coins'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final garage = GameManager().garage;

    return Scaffold(
      appBar: AppBar(title: const Text('Race Simulation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Vehicle Info
            Card(
              child: ListTile(
                title: Text(
                  'Driver: ${garage.equippedVehicle?.name ?? "None"}',
                ),
                subtitle: const Text('Ready to race!'),
                leading: const Icon(Icons.directions_car),
              ),
            ),
            const SizedBox(height: 20),

            // Track Selection
            const Text('Select Track:', style: TextStyle(fontSize: 18)),
            DropdownButton<Track>(
              value: _selectedTrack,
              isExpanded: true,
              items: TrackData.getAllTracks().map((track) {
                return DropdownMenuItem(
                  value: track,
                  child: Text('${track.name} (${track.lengthMeters}m)'),
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
                  padding: const EdgeInsets.all(24),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('START RACE', style: TextStyle(fontSize: 24)),
              ),

            const SizedBox(height: 20),
            if (_lastResult != null)
              Text(
                'Last Run: ${_lastResult!.position}th Place',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
