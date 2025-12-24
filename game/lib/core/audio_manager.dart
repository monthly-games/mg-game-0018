import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

class AudioManager {
  // Singleton pattern for easy access
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _isInit = false;

  void initialize() {
    if (_isInit) return;
    // Preload common sounds if assets existed
    // FlameAudio.audioCache.loadAll(['sfx_click.wav', 'sfx_win.wav']);
    _isInit = true;
  }

  void playSfx(String name) {
    if (kIsWeb) return; // Audio often tricky on web without user interaction
    try {
      // In a real scenario: FlameAudio.play('sfx/$name.wav');
      // For this prototype without assets, we just log.
      debugPrint('Playing SFX: $name');
    } catch (e) {
      debugPrint('Error playing SFX: $e');
    }
  }

  void playMusic(String name) {
    try {
      // FlameAudio.bgm.play('music/$name.mp3');
      debugPrint('Playing Music: $name');
    } catch (e) {
      debugPrint('Error playing Music: $e');
    }
  }
}
