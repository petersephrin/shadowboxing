import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

/// A helper class to manage sound effects for the game
class SoundEffectHandler {
  // Audio players for different sound effects
  final AudioPlayer _hitPlayer = AudioPlayer();
  final AudioPlayer _missPlayer = AudioPlayer();
  final AudioPlayer _victoryPlayer = AudioPlayer();
  final AudioPlayer _buttonPlayer = AudioPlayer();

  // Track if sound is enabled
  bool _soundEnabled = true;

  // Singleton pattern
  static final SoundEffectHandler _instance = SoundEffectHandler._internal();

  factory SoundEffectHandler() {
    return _instance;
  }

  SoundEffectHandler._internal();

  /// Initialize and load all sound effects
  Future<void> initialize() async {
    try {
      await _hitPlayer.setSource(AssetSource('hit.mp3'));
      await _missPlayer.setSource(AssetSource('miss.mp3'));
      await _victoryPlayer.setSource(AssetSource('victory.mp3'));
      await _buttonPlayer.setSource(AssetSource('button.mp3'));

      // Set volumes
      await _hitPlayer.setVolume(0.7);
      await _missPlayer.setVolume(0.6);
      await _victoryPlayer.setVolume(0.8);
      await _buttonPlayer.setVolume(0.5);
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing sound effects: $e');
      }
      _soundEnabled = false;
    }
  }

  /// Play the hit sound effect
  void playHitSound() {
    if (_soundEnabled) {
      _hitPlayer.resume();
    }
  }

  /// Play the miss sound effect
  void playMissSound() {
    if (_soundEnabled) {
      _missPlayer.resume();
    }
  }

  /// Play the victory sound effect
  void playVictorySound() {
    if (_soundEnabled) {
      _victoryPlayer.resume();
    }
  }

  /// Play the button click sound effect
  void playButtonSound() {
    if (_soundEnabled) {
      _buttonPlayer.resume();
    }
  }

  /// Enable or disable all sound effects
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;

    // If disabling sound, stop any currently playing sounds
    if (!enabled) {
      _hitPlayer.stop();
      _missPlayer.stop();
      _victoryPlayer.stop();
      _buttonPlayer.stop();
    }
  }

  /// Get the current sound enabled state
  bool get isSoundEnabled => _soundEnabled;

  /// Dispose all audio players when no longer needed
  void dispose() {
    _hitPlayer.dispose();
    _missPlayer.dispose();
    _victoryPlayer.dispose();
    _buttonPlayer.dispose();
  }
}
