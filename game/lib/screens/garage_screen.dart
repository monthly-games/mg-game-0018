import 'package:flutter/material.dart';
import '../core/game_manager.dart';
import '../features/racing/models/vehicle.dart';
import '../features/meta/upgrade_config.dart';
import '../core/audio_manager.dart';

class GarageScreen extends StatefulWidget {
  const GarageScreen({super.key});

  @override
  State<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends State<GarageScreen> {
  // We can track last upgrade time to trigger animation,
  // but for simplicity let's just use Game state updates.
  // Actually, to animate specific buttons, we might need a map of vehicle IDs?
  // Let's just make the whole list rebuild and maybe animate the text?
  // A simple scale animation on press is easier with a custom widget or implicit animation.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Garage')),
      body: ListenableBuilder(
        listenable: GameManager().garage,
        builder: (context, _) {
          final vehicles = GameManager().garage.ownedVehicles;
          return ListView.builder(
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return _VehicleCard(vehicle: vehicle);
            },
          );
        },
      ),
    );
  }
}

class _VehicleCard extends StatefulWidget {
  final Vehicle vehicle;
  const _VehicleCard({required this.vehicle});

  @override
  State<_VehicleCard> createState() => _VehicleCardState();
}

class _VehicleCardState extends State<_VehicleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playUpgradeAnim() {
    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              v.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildStatRow('Speed', v.speedLevel, v.effectiveSpeed, () {
              if (GameManager().garage.upgradeSpeed(v.id)) {
                _playUpgradeAnim();
                AudioManager().playSfx('upgrade');
              }
            }),
            _buildStatRow(
              'Accel',
              v.accelerationLevel,
              v.effectiveAcceleration,
              () {
                if (GameManager().garage.upgradeAcceleration(v.id)) {
                  _playUpgradeAnim();
                  AudioManager().playSfx('upgrade');
                }
              },
            ),
            _buildStatRow('Handling', v.handlingLevel, v.effectiveHandling, () {
              if (GameManager().garage.upgradeHandling(v.id)) {
                _playUpgradeAnim();
                AudioManager().playSfx('upgrade');
              }
            }),
            const SizedBox(height: 10),
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                );
              },
              child: ElevatedButton(
                onPressed: () {
                  if (GameManager().garage.equipVehicle(v.id)) {
                    AudioManager().playSfx('click');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      GameManager().garage.equippedVehicle?.id == v.id
                      ? Colors.green
                      : Colors.grey,
                ),
                child: Text(
                  GameManager().garage.equippedVehicle?.id == v.id
                      ? 'Equipped'
                      : 'Equip',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    int level,
    double value,
    VoidCallback onUpgrade,
  ) {
    final cost = UpgradeConfig.getUpgradeCost(level);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(value: value / 200.0),
          ), // Arbitrary max
          const SizedBox(width: 10),
          Text('Lv.$level'),
          const SizedBox(width: 10),
          ElevatedButton(onPressed: onUpgrade, child: Text('Up (\$ $cost)')),
        ],
      ),
    );
  }
}
