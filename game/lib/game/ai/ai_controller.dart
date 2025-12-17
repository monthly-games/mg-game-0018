import 'dart:math';
import 'package:flame/components.dart';
import '../components/vehicle_component.dart';
import '../tracks/track_data.dart';

/// AI difficulty levels
enum AIDifficulty {
  easy,   // Slower, makes mistakes
  medium, // Balanced
  hard,   // Fast, few mistakes
}

/// AI controller for opponent vehicles
class AIController {
  final VehicleComponent vehicle;
  final Track track;
  final AIDifficulty difficulty;
  final Random _random = Random();

  // AI state
  int targetWaypointIndex = 0;
  double reactionTime = 0;
  double mistakeTimer = 0;
  bool makingMistake = false;

  // AI parameters based on difficulty
  late double skillLevel;
  late double reactionDelay;
  late double mistakeFrequency;
  late double speedMultiplier;

  AIController({
    required this.vehicle,
    required this.track,
    required this.difficulty,
  }) {
    _initializeDifficulty();
  }

  void _initializeDifficulty() {
    switch (difficulty) {
      case AIDifficulty.easy:
        skillLevel = 0.6;
        reactionDelay = 0.3;
        mistakeFrequency = 0.15; // 15% chance per second
        speedMultiplier = 0.85;
        break;
      case AIDifficulty.medium:
        skillLevel = 0.8;
        reactionDelay = 0.15;
        mistakeFrequency = 0.08;
        speedMultiplier = 0.95;
        break;
      case AIDifficulty.hard:
        skillLevel = 0.95;
        reactionDelay = 0.05;
        mistakeFrequency = 0.03;
        speedMultiplier = 1.0;
        break;
    }

    // Apply speed multiplier to vehicle
    vehicle.maxSpeed *= speedMultiplier;
  }

  /// Update AI decision making
  void update(double dt) {
    // Update reaction time
    reactionTime -= dt;

    // Update mistake state
    if (makingMistake) {
      mistakeTimer -= dt;
      if (mistakeTimer <= 0) {
        makingMistake = false;
      }
    } else {
      // Random chance to make a mistake
      if (_random.nextDouble() < mistakeFrequency * dt) {
        _makeMistake();
      }
    }

    // Only make decisions after reaction delay
    if (reactionTime > 0) return;
    reactionTime = reactionDelay;

    // Get target waypoint
    final targetWaypoint = track.centerLine[targetWaypointIndex];
    final toTarget = targetWaypoint - vehicle.position;
    final distance = toTarget.length;

    // Update target waypoint if close enough
    if (distance < 80) {
      targetWaypointIndex = (targetWaypointIndex + 1) % track.centerLine.length;
    }

    // Calculate steering
    if (!makingMistake) {
      _calculateSteering(toTarget);
    } else {
      // During mistake, use wrong steering
      vehicle.steeringInput = (_random.nextDouble() - 0.5) * 2;
    }

    // Speed control
    _controlSpeed(distance);

    // Use ability cards (simple AI)
    _considerUsingCards();
  }

  void _calculateSteering(Vector2 toTarget) {
    // Calculate desired angle to target
    final desiredAngle = atan2(toTarget.y, toTarget.x);

    // Calculate angle difference
    var angleDiff = desiredAngle - vehicle.angle;

    // Normalize to -pi to pi
    while (angleDiff > pi) {
      angleDiff -= 2 * pi;
    }
    while (angleDiff < -pi) {
      angleDiff += 2 * pi;
    }

    // Apply steering based on angle difference and skill
    vehicle.steeringInput = (angleDiff * skillLevel).clamp(-1.0, 1.0);

    // Add some noise based on skill
    vehicle.steeringInput += (_random.nextDouble() - 0.5) * (1 - skillLevel) * 0.3;
    vehicle.steeringInput = vehicle.steeringInput.clamp(-1.0, 1.0);
  }

  void _controlSpeed(double distanceToTarget) {
    // Always accelerate unless making a mistake
    vehicle.accelerating = !makingMistake;
    vehicle.braking = false;

    // Check for sharp turns ahead
    final nextWaypointIndex = (targetWaypointIndex + 1) % track.centerLine.length;
    final currentWaypoint = track.centerLine[targetWaypointIndex];
    final nextWaypoint = track.centerLine[nextWaypointIndex];

    // Calculate turn sharpness
    final toNext = nextWaypoint - currentWaypoint;
    final toCurrent = currentWaypoint - vehicle.position;

    final dot = (toNext.normalized().dot(toCurrent.normalized()));

    // If sharp turn ahead (dot < 0), slow down
    if (dot < 0.3 && distanceToTarget < 150) {
      vehicle.accelerating = false;
      if (vehicle.currentSpeed > vehicle.maxSpeed * 0.6) {
        vehicle.braking = true;
      }
    }

    // Use boost on straight sections
    if (dot > 0.8 && vehicle.currentSpeed > vehicle.maxSpeed * 0.7) {
      vehicle.boosting = _random.nextDouble() < 0.3; // 30% chance
    } else {
      vehicle.boosting = false;
    }
  }

  void _makeMistake() {
    makingMistake = true;
    mistakeTimer = 0.5 + _random.nextDouble(); // 0.5-1.5 seconds

    // Type of mistake
    final mistakeType = _random.nextInt(3);
    switch (mistakeType) {
      case 0: // Oversteer
        vehicle.steeringInput = (_random.nextDouble() - 0.5) * 2;
        break;
      case 1: // Brake randomly
        vehicle.braking = true;
        vehicle.accelerating = false;
        break;
      case 2: // Wrong direction
        targetWaypointIndex = (targetWaypointIndex - 1) % track.centerLine.length;
        if (targetWaypointIndex < 0) {
          targetWaypointIndex = track.centerLine.length - 1;
        }
        break;
    }
  }

  void _considerUsingCards() {
    // Simple AI card usage
    // TODO: Implement smart card usage based on situation

    // For now, random usage with low probability
    if (_random.nextDouble() < 0.01 * skillLevel) { // ~1% per frame
      // Use boost card if available (will be handled by race manager)
    }
  }

  /// Reset AI for new race
  void reset() {
    targetWaypointIndex = 0;
    reactionTime = 0;
    mistakeTimer = 0;
    makingMistake = false;
  }
}
