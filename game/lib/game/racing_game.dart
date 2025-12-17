import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart' show KeyEvent, KeyDownEvent, LogicalKeyboardKey, KeyEventResult;
import 'components/vehicle_component.dart';
import 'components/track_component.dart';
import 'tracks/track_data.dart';
import 'ai/ai_controller.dart';
import '../features/vehicles/vehicle_data.dart';
import '../features/cards/card_data.dart';

/// Race state
enum RaceState {
  countdown,  // 3-2-1
  racing,     // Active race
  finished,   // Race complete
}

/// Racing game world
class RacingGame extends FlameGame with KeyboardEvents, TapCallbacks {
  final Track track;
  final Vehicle playerVehicle;
  final VehicleStats playerVehicleStats;
  final List<String> equippedCardIds;

  // Components
  late VehicleComponent playerVehicleComponent;
  late TrackComponent trackComponent;
  late CameraComponent cameraComponent;
  final List<VehicleComponent> aiVehicles = [];
  final List<AIController> aiControllers = [];

  // Race state
  RaceState raceState = RaceState.countdown;
  double countdownTimer = 3.0;
  double raceTime = 0;
  int totalLaps = 3;
  int playerFinalPosition = 0; // Set when race finishes

  // Player controls
  final Map<LogicalKeyboardKey, bool> _keysPressed = {};
  Vector2? _dragStart;
  Vector2? _currentDrag;

  // Card system
  final List<AbilityCard> equippedCards = [];
  final Map<String, double> cardCooldowns = {};

  RacingGame({
    required this.track,
    required this.playerVehicle,
    required this.playerVehicleStats,
    required this.equippedCardIds,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize cards
    for (final cardId in equippedCardIds) {
      final card = AbilityCards.getById(cardId);
      if (card != null) {
        equippedCards.add(card);
        cardCooldowns[cardId] = 0;
      }
    }

    // Create track
    trackComponent = TrackComponent(track: track);
    add(trackComponent);

    // Create player vehicle with upgraded stats
    playerVehicleComponent = VehicleComponent(
      vehicle: playerVehicle,
      isPlayer: true,
      position: track.startPosition.clone(),
      upgradeStats: playerVehicleStats,
    );
    playerVehicleComponent.angle = track.startAngle;
    add(playerVehicleComponent);

    // Create AI vehicles (3 opponents)
    final aiVehiclesList = [
      Vehicles.speedster,
      Vehicles.drifter,
      Vehicles.tank,
    ];

    for (int i = 0; i < 3; i++) {
      final aiVehicle = VehicleComponent(
        vehicle: aiVehiclesList[i],
        isPlayer: false,
        position: track.startPosition.clone() + Vector2(0, (i + 1) * 70.0),
      );
      aiVehicle.angle = track.startAngle;
      add(aiVehicle);
      aiVehicles.add(aiVehicle);

      // Create AI controller
      final controller = AIController(
        vehicle: aiVehicle,
        track: track,
        difficulty: i == 0 ? AIDifficulty.hard : AIDifficulty.medium,
      );
      aiControllers.add(controller);
    }

    // Setup camera to follow player
    cameraComponent = CameraComponent.withFixedResolution(
      world: world,
      width: 800,
      height: 600,
    );
    cameraComponent.follow(playerVehicleComponent);
    add(cameraComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);

    switch (raceState) {
      case RaceState.countdown:
        _updateCountdown(dt);
        break;
      case RaceState.racing:
        _updateRace(dt);
        break;
      case RaceState.finished:
        _updateFinished(dt);
        break;
    }
  }

  void _updateCountdown(double dt) {
    countdownTimer -= dt;
    if (countdownTimer <= 0) {
      raceState = RaceState.racing;
    }
  }

  void _updateRace(double dt) {
    raceTime += dt;

    // Update player controls
    _updatePlayerInput();

    // Update AI
    for (final controller in aiControllers) {
      controller.update(dt);
    }

    // Update card cooldowns
    for (final cardId in cardCooldowns.keys) {
      if (cardCooldowns[cardId]! > 0) {
        cardCooldowns[cardId] = cardCooldowns[cardId]! - dt;
      }
    }

    // Check checkpoints
    _checkCheckpoints();

    // Check race finish
    if (playerVehicleComponent.currentLap > totalLaps) {
      _finishRace();
    }
  }

  void _updateFinished(double dt) {
    // Handle post-race (results screen handled by UI overlay)
  }

  void _updatePlayerInput() {
    // Keyboard controls
    if (_keysPressed[LogicalKeyboardKey.arrowLeft] == true ||
        _keysPressed[LogicalKeyboardKey.keyA] == true) {
      playerVehicleComponent.steeringInput = -1;
    } else if (_keysPressed[LogicalKeyboardKey.arrowRight] == true ||
        _keysPressed[LogicalKeyboardKey.keyD] == true) {
      playerVehicleComponent.steeringInput = 1;
    } else {
      playerVehicleComponent.steeringInput = 0;
    }

    playerVehicleComponent.accelerating =
        _keysPressed[LogicalKeyboardKey.arrowUp] == true ||
        _keysPressed[LogicalKeyboardKey.keyW] == true;

    playerVehicleComponent.braking =
        _keysPressed[LogicalKeyboardKey.arrowDown] == true ||
        _keysPressed[LogicalKeyboardKey.keyS] == true;

    // Touch/drag controls (for mobile)
    if (_currentDrag != null && _dragStart != null) {
      final diff = _currentDrag! - _dragStart!;
      playerVehicleComponent.steeringInput = (diff.x / 100).clamp(-1.0, 1.0);
      playerVehicleComponent.accelerating = true;
    }
  }

  void _checkCheckpoints() {
    // Check player
    _checkVehicleCheckpoints(playerVehicleComponent);

    // Check AI
    for (final aiVehicle in aiVehicles) {
      _checkVehicleCheckpoints(aiVehicle);
    }
  }

  void _checkVehicleCheckpoints(VehicleComponent vehicle) {
    for (final checkpoint in track.checkpoints) {
      if (checkpoint.contains(vehicle.position)) {
        // Check if this is the next expected checkpoint
        if (checkpoint.index == vehicle.checkpointsHit) {
          vehicle.checkpointsHit++;

          // If completed all checkpoints, increment lap
          if (vehicle.checkpointsHit >= track.checkpoints.length) {
            vehicle.currentLap++;
            vehicle.checkpointsHit = 0;
          }
        }
      }
    }
  }

  void _finishRace() {
    raceState = RaceState.finished;

    // Calculate final rankings
    final rankings = _calculateRankings();

    // Store race results for UI
    playerFinalPosition = rankings.indexOf(playerVehicleComponent) + 1;
  }

  List<VehicleComponent> _calculateRankings() {
    final allVehicles = [playerVehicleComponent, ...aiVehicles];
    allVehicles.sort((a, b) => b.progress.compareTo(a.progress));
    return allVehicles;
  }

  /// Use ability card
  void useCard(int cardIndex) {
    if (raceState != RaceState.racing) return;
    if (cardIndex < 0 || cardIndex >= equippedCards.length) return;

    final card = equippedCards[cardIndex];

    // Check cooldown
    if (cardCooldowns[card.id]! > 0) return;

    // Apply effect
    _applyCardEffect(card);

    // Start cooldown
    cardCooldowns[card.id] = card.baseCooldown.toDouble();
  }

  void _applyCardEffect(AbilityCard card) {
    switch (card.type) {
      case CardType.boost:
      case CardType.shield:
      case CardType.magnet:
      case CardType.jump:
      case CardType.repair:
        // Apply to player
        playerVehicleComponent.applyCardEffect(card);
        break;

      case CardType.missile:
        // Fire at nearest opponent ahead
        _fireMissile();
        break;

      case CardType.slowdown:
        // Affect all opponents
        for (final aiVehicle in aiVehicles) {
          aiVehicle.applySlowdown(3.0, 0.6); // 3 seconds, 60% speed
        }
        break;
    }
  }

  void _fireMissile() {
    // Find nearest opponent ahead of player
    VehicleComponent? target;
    double minDistance = double.infinity;

    for (final aiVehicle in aiVehicles) {
      if (aiVehicle.progress > playerVehicleComponent.progress) {
        final distance = (aiVehicle.position - playerVehicleComponent.position).length;
        if (distance < minDistance) {
          minDistance = distance;
          target = aiVehicle;
        }
      }
    }

    // Hit target if found
    if (target != null) {
      target.hitByMissile();
    }
  }

  // Keyboard events
  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    _keysPressed[event.logicalKey] = event is KeyDownEvent;
    return KeyEventResult.handled;
  }

  // Touch events
  @override
  void onTapDown(TapDownEvent event) {
    _dragStart = event.localPosition;
    _currentDrag = _dragStart;
  }

  @override
  void onTapUp(TapUpEvent event) {
    _dragStart = null;
    _currentDrag = null;
    playerVehicleComponent.steeringInput = 0;
    playerVehicleComponent.accelerating = false;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _dragStart = null;
    _currentDrag = null;
    playerVehicleComponent.steeringInput = 0;
    playerVehicleComponent.accelerating = false;
  }

  // Getters for UI
  int get playerRank {
    final rankings = _calculateRankings();
    return rankings.indexOf(playerVehicleComponent) + 1;
  }

  String get formattedRaceTime {
    final minutes = (raceTime ~/ 60).toString().padLeft(2, '0');
    final seconds = (raceTime % 60).toStringAsFixed(2).padLeft(5, '0');
    return '$minutes:$seconds';
  }
}
