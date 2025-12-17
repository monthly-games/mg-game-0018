import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import '../../features/vehicles/vehicle_data.dart';
import '../../features/cards/card_data.dart';

/// Vehicle physics component for racing gameplay
class VehicleComponent extends PositionComponent {
  final Vehicle vehicle;
  final bool isPlayer;

  // Physics state
  Vector2 velocity = Vector2.zero();
  @override
  double angle = 0; // Radians
  double currentSpeed = 0;
  double maxSpeed = 0;
  double acceleration = 0;
  double handling = 0;
  double boostPower = 0;

  // Control state
  double steeringInput = 0; // -1 (left) to 1 (right)
  bool accelerating = false;
  bool braking = false;
  bool boosting = false;

  // Active effects
  double speedMultiplier = 1.0;
  bool hasShield = false;
  double shieldDuration = 0;

  // Lap tracking
  int currentLap = 1;
  int checkpointsHit = 0;

  VehicleComponent({
    required this.vehicle,
    required this.isPlayer,
    Vector2? position,
  }) : super(
    position: position ?? Vector2.zero(),
    size: Vector2(40, 60),
    anchor: Anchor.center,
  ) {
    // Initialize physics from vehicle stats
    maxSpeed = vehicle.baseStats.speed * 50; // Scale to pixels/sec
    acceleration = vehicle.baseStats.acceleration * 20;
    handling = vehicle.baseStats.handling * 0.05;
    boostPower = vehicle.baseStats.boost;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update active effects
    if (shieldDuration > 0) {
      shieldDuration -= dt;
      if (shieldDuration <= 0) {
        hasShield = false;
      }
    }

    // Calculate acceleration
    double accel = 0;
    if (accelerating) {
      accel = acceleration;
    } else if (braking) {
      accel = -acceleration * 2; // Brake harder
    }

    // Apply boost
    double effectiveMaxSpeed = maxSpeed * speedMultiplier;
    if (boosting) {
      effectiveMaxSpeed *= (1.0 + boostPower * 0.2);
      accel *= 1.5;
    }

    // Update speed
    currentSpeed += accel * dt;
    currentSpeed = currentSpeed.clamp(0, effectiveMaxSpeed);

    // Apply friction
    if (!accelerating && !braking) {
      currentSpeed *= pow(0.95, dt * 60); // Decay
    }

    // Apply steering
    if (currentSpeed > 10) {
      double turnRate = handling * steeringInput * dt;
      angle += turnRate * (currentSpeed / maxSpeed); // Turn faster at higher speeds
    }

    // Update velocity from angle and speed
    velocity.x = cos(angle) * currentSpeed;
    velocity.y = sin(angle) * currentSpeed;

    // Update position
    position += velocity * dt;
  }

  @override
  void render(Canvas canvas) {
    // Draw vehicle body
    final paint = Paint()
      ..color = isPlayer ? const Color(0xFF00FF00) : const Color(0xFFFF0000);

    // Shield effect
    if (hasShield) {
      final shieldPaint = Paint()
        ..color = const Color(0x4400FFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x / 2 + 5,
        shieldPaint,
      );
    }

    // Vehicle body (rotated rectangle)
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(angle);
    canvas.translate(-size.x / 2, -size.y / 2);

    // Main body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(5, 0, size.x - 10, size.y),
        const Radius.circular(8),
      ),
      paint,
    );

    // Front indicator
    final frontPaint = Paint()..color = const Color(0xFFFFFF00);
    canvas.drawRect(
      Rect.fromLTWH(size.x / 2 - 5, 0, 10, 10),
      frontPaint,
    );

    // Boost effect
    if (boosting) {
      final boostPaint = Paint()
        ..color = const Color(0xFFFF8800)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromLTWH(size.x / 2 - 8, size.y - 5, 16, 12),
        boostPaint,
      );
    }

    canvas.restore();
  }

  /// Apply card ability effect
  void applyCardEffect(AbilityCard card) {
    switch (card.type) {
      case CardType.boost:
        speedMultiplier = card.basePower;
        Future.delayed(Duration(seconds: 3), () {
          speedMultiplier = 1.0;
        });
        break;

      case CardType.shield:
        hasShield = true;
        shieldDuration = 5.0;
        break;

      case CardType.missile:
        // Handled by race manager
        break;

      case CardType.slowdown:
        // Applied to target vehicle
        break;

      case CardType.magnet:
        // Collect nearby items (future)
        break;

      case CardType.jump:
        // Jump over obstacles (future)
        break;

      case CardType.repair:
        // Restore health/damage (future)
        break;
    }
  }

  /// Apply negative effect (from opponent cards)
  void applySlowdown(double duration, double factor) {
    speedMultiplier = factor;
    Future.delayed(Duration(seconds: duration.toInt()), () {
      speedMultiplier = 1.0;
    });
  }

  /// Check if hit by missile
  void hitByMissile() {
    if (hasShield) {
      hasShield = false;
      shieldDuration = 0;
    } else {
      // Spin out
      currentSpeed *= 0.3;
      angle += pi / 4; // 45 degree spin
    }
  }

  /// Get current progress (0-1) for ranking
  double get progress {
    // Will be calculated by race manager based on checkpoints
    return (currentLap - 1 + checkpointsHit / 4.0) / 3.0; // 3 laps, 4 checkpoints
  }
}
