import 'racing_physics.dart';

class VehicleController {
  final RacingPhysics physics;
  final double nitroCapacity;
  final double nitroRechargeRate;

  double _currentNitro = 0;
  double _currentSpeed = 0;
  double _currentRotation = 0;

  VehicleController({
    required this.physics,
    required this.nitroCapacity,
    required this.nitroRechargeRate,
  }) {
    _currentNitro = nitroCapacity;
  }

  double get currentSpeed => _currentSpeed;
  double get currentRotation => _currentRotation;
  double get currentNitro => _currentNitro;

  void accelerate(double deltaTime) {
    _currentSpeed = (_currentSpeed + physics.baseAcceleration * deltaTime)
        .clamp(0, physics.baseMaxSpeed);
  }

  void brake(double deltaTime) {
    _currentSpeed = (_currentSpeed - physics.baseBraking * deltaTime).clamp(0, physics.baseMaxSpeed);
  }

  void turn(double direction, double deltaTime) {
    _currentRotation += direction * physics.baseTurnSpeed * deltaTime;
  }

  void useNitro(double deltaTime) {
    if (_currentNitro > 0) {
      _currentNitro -= deltaTime * 20;
      _currentSpeed = (_currentSpeed * 1.5).clamp(0, physics.baseMaxSpeed * 1.5);
    }
  }

  void update(double deltaTime) {
    _currentSpeed *= physics.baseFriction;
    if (_currentNitro < nitroCapacity) {
      _currentNitro += nitroRechargeRate * deltaTime;
      _currentNitro = _currentNitro.clamp(0, nitroCapacity);
    }
  }
}
