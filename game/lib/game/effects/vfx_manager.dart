import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';

/// VFX Manager for Cartoon Racing RPG (MG-0018)
/// Racing + Card + Idle 게임 전용 이펙트 관리자
class VfxManager extends Component with HasGameRef {
  VfxManager();
  final Random _random = Random();

  // Racing Effects
  void showBoostStart(Vector2 position) {
    gameRef.add(_createTrailEffect(position: position, color: MGColors.warning, length: 60));
    gameRef.add(_createSparkleEffect(position: position, color: MGColors.gold, count: 12));
    gameRef.add(_BoostText(position: position));
  }

  void showSpeedTrail(Vector2 position, Color vehicleColor) {
    gameRef.add(_createTrailEffect(position: position, color: vehicleColor.withValues(alpha: 0.6), length: 40));
  }

  void showDrift(Vector2 position) {
    gameRef.add(_createSmokeEffect(position: position, count: 8, color: MGColors.common));
    gameRef.add(_createSparkleEffect(position: position, color: MGColors.textHighEmphasis, count: 5));
  }

  void showCollision(Vector2 position) {
    gameRef.add(_createExplosionEffect(position: position, color: MGColors.warning, count: 20, radius: 50));
    gameRef.add(_createSmokeEffect(position: position, count: 10, color: MGColors.common));
    _triggerScreenShake(intensity: 6, duration: 0.3);
  }

  void showRaceFinish(Vector2 position, int placement) {
    Color color; String text;
    switch (placement) {
      case 1: color = MGColors.gold; text = '1ST!'; break;
      case 2: color = MGColors.common; text = '2ND'; break;
      case 3: color = MGColors.warning; text = '3RD'; break;
      default: color = MGColors.textHighEmphasis; text = '${placement}TH';
    }
    gameRef.add(_createExplosionEffect(position: position, color: color, count: placement == 1 ? 40 : 25, radius: 70));
    if (placement <= 3) {
      gameRef.add(_createSparkleEffect(position: position, color: MGColors.textHighEmphasis, count: 15));
    }
    gameRef.add(_PlacementText(position: position, text: text, color: color));
  }

  // Card/Ability Effects
  void showAbilityActivate(Vector2 position, Color abilityColor) {
    gameRef.add(_createConvergeEffect(position: position, color: abilityColor));
    gameRef.add(_createGroundCircle(position: position, color: abilityColor));
  }

  void showAbilityHit(Vector2 targetPosition, Color abilityColor) {
    gameRef.add(_createExplosionEffect(position: targetPosition, color: abilityColor, count: 18, radius: 45));
  }

  // Upgrade Effects
  void showVehicleUpgrade(Vector2 position) {
    gameRef.add(_createExplosionEffect(position: position, color: MGColors.gold, count: 30, radius: 60));
    gameRef.add(_createSparkleEffect(position: position, color: MGColors.gold, count: 15));
    gameRef.add(_UpgradeText(position: position));
  }

  void showTrackComplete(Vector2 centerPosition) {
    for (int i = 0; i < 5; i++) {
      Future.delayed(Duration(milliseconds: i * 120), () {
        if (!isMounted) return;
        gameRef.add(_createSparkleEffect(position: centerPosition + Vector2((_random.nextDouble() - 0.5) * 120, (_random.nextDouble() - 0.5) * 80), color: [MGColors.error, MGColors.warning, MGColors.gold, MGColors.success, MGColors.info][i], count: 10));
      });
    }
  }

  void showNumberPopup(Vector2 position, String text, {Color color = MGColors.textHighEmphasis}) {
    gameRef.add(_NumberPopup(position: position, text: text, color: color));
  }

  void _triggerScreenShake({double intensity = 5, double duration = 0.3}) {
    if (gameRef.camera.viewfinder.children.isNotEmpty) {
      gameRef.camera.viewfinder.add(MoveByEffect(Vector2(intensity, 0), EffectController(duration: duration / 10, repeatCount: (duration * 10).toInt(), alternate: true)));
    }
  }

  // Private generators
  ParticleSystemComponent _createTrailEffect({required Vector2 position, required Color color, required double length}) {
    return ParticleSystemComponent(particle: Particle.generate(count: 15, lifespan: 0.5, generator: (i) {
      final offset = (i / 15) * length;
      return AcceleratedParticle(position: position.clone() + Vector2(offset, 0), speed: Vector2(-100, (_random.nextDouble() - 0.5) * 30), acceleration: Vector2(-50, 0), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress).clamp(0.0, 1.0);
        canvas.drawCircle(Offset.zero, 4 * (1.0 - particle.progress * 0.6), Paint()..color = color.withValues(alpha: opacity * 0.7));
      }));
    }));
  }

  ParticleSystemComponent _createExplosionEffect({required Vector2 position, required Color color, required int count, required double radius}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.6, generator: (i) {
      final angle = _random.nextDouble() * 2 * pi; final speed = radius * (0.4 + _random.nextDouble() * 0.6);
      return AcceleratedParticle(position: position.clone(), speed: Vector2(cos(angle), sin(angle)) * speed, acceleration: Vector2(0, 80), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress).clamp(0.0, 1.0);
        canvas.drawCircle(Offset.zero, 5 * (1.0 - particle.progress * 0.3), Paint()..color = color.withValues(alpha: opacity));
      }));
    }));
  }

  ParticleSystemComponent _createConvergeEffect({required Vector2 position, required Color color}) {
    return ParticleSystemComponent(particle: Particle.generate(count: 10, lifespan: 0.4, generator: (i) {
      final startAngle = (i / 10) * 2 * pi; final startPos = Vector2(cos(startAngle), sin(startAngle)) * 40;
      return MovingParticle(from: position + startPos, to: position.clone(), child: ComputedParticle(renderer: (canvas, particle) {
        canvas.drawCircle(Offset.zero, 4, Paint()..color = color.withValues(alpha: (1.0 - particle.progress * 0.5).clamp(0.0, 1.0)));
      }));
    }));
  }

  ParticleSystemComponent _createSparkleEffect({required Vector2 position, required Color color, required int count}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.5, generator: (i) {
      final angle = _random.nextDouble() * 2 * pi; final speed = 50 + _random.nextDouble() * 40;
      return AcceleratedParticle(position: position.clone(), speed: Vector2(cos(angle), sin(angle)) * speed, acceleration: Vector2(0, 40), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress).clamp(0.0, 1.0); final size = 3 * (1.0 - particle.progress * 0.5);
        final path = Path(); for (int j = 0; j < 4; j++) { final a = (j * pi / 2); if (j == 0) path.moveTo(cos(a) * size, sin(a) * size); else path.lineTo(cos(a) * size, sin(a) * size); } path.close();
        canvas.drawPath(path, Paint()..color = color.withValues(alpha: opacity));
      }));
    }));
  }

  ParticleSystemComponent _createSmokeEffect({required Vector2 position, required int count, required Color color}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.6, generator: (i) {
      return AcceleratedParticle(position: position.clone() + Vector2((_random.nextDouble() - 0.5) * 20, 0), speed: Vector2((_random.nextDouble() - 0.5) * 20, -20 - _random.nextDouble() * 15), acceleration: Vector2(0, -8), child: ComputedParticle(renderer: (canvas, particle) {
        final progress = particle.progress; final opacity = (0.5 - progress * 0.5).clamp(0.0, 1.0);
        canvas.drawCircle(Offset.zero, 5 + progress * 8, Paint()..color = color.withValues(alpha: opacity));
      }));
    }));
  }

  ParticleSystemComponent _createGroundCircle({required Vector2 position, required Color color}) {
    return ParticleSystemComponent(particle: Particle.generate(count: 1, lifespan: 0.5, generator: (i) {
      return ComputedParticle(renderer: (canvas, particle) {
        final progress = particle.progress; final opacity = (1.0 - progress).clamp(0.0, 1.0);
        canvas.drawCircle(Offset(position.x, position.y), 12 + progress * 25, Paint()..color = color.withValues(alpha: opacity * 0.4)..style = PaintingStyle.stroke..strokeWidth = 2);
      });
    }));
  }
}

class _BoostText extends TextComponent {
  _BoostText({required Vector2 position}) : super(text: 'BOOST!', position: position + Vector2(0, -30), anchor: Anchor.center, textRenderer: TextPaint(style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: MGColors.warning, shadows: [Shadow(color: MGColors.error, blurRadius: 10)])));
  @override Future<void> onLoad() async { await super.onLoad(); scale = Vector2.all(0.5); add(ScaleEffect.to(Vector2.all(1.1), EffectController(duration: 0.2, curve: Curves.elasticOut))); add(MoveByEffect(Vector2(0, -20), EffectController(duration: 0.8, curve: Curves.easeOut))); add(OpacityEffect.fadeOut(EffectController(duration: 0.8, startDelay: 0.3))); add(RemoveEffect(delay: 1.1)); }
}

class _PlacementText extends TextComponent {
  _PlacementText({required Vector2 position, required String text, required Color color}) : super(text: text, position: position, anchor: Anchor.center, textRenderer: TextPaint(style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color, letterSpacing: 2, shadows: [Shadow(color: color, blurRadius: 12)])));
  @override Future<void> onLoad() async { await super.onLoad(); scale = Vector2.all(0.3); add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.5, curve: Curves.elasticOut))); add(RemoveEffect(delay: 3.0)); }
}

class _UpgradeText extends TextComponent {
  _UpgradeText({required Vector2 position}) : super(text: 'UPGRADE!', position: position + Vector2(0, -35), anchor: Anchor.center, textRenderer: TextPaint(style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: MGColors.gold, shadows: [Shadow(color: MGColors.warning, blurRadius: 10)])));
  @override Future<void> onLoad() async { await super.onLoad(); scale = Vector2.all(0.5); add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.3, curve: Curves.elasticOut))); add(MoveByEffect(Vector2(0, -20), EffectController(duration: 1.0, curve: Curves.easeOut))); add(OpacityEffect.fadeOut(EffectController(duration: 1.0, startDelay: 0.5))); add(RemoveEffect(delay: 1.5)); }
}

class _NumberPopup extends TextComponent {
  _NumberPopup({required Vector2 position, required String text, required Color color}) : super(text: text, position: position, anchor: Anchor.center, textRenderer: TextPaint(style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color, shadows: const [Shadow(color: MGColors.backgroundDarkDark, blurRadius: 4, offset: Offset(1, 1))])));
  @override Future<void> onLoad() async { await super.onLoad(); add(MoveByEffect(Vector2(0, -25), EffectController(duration: 0.6, curve: Curves.easeOut))); add(OpacityEffect.fadeOut(EffectController(duration: 0.6, startDelay: 0.2))); add(RemoveEffect(delay: 0.8)); }
}
