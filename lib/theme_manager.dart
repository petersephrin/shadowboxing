import 'package:flutter/material.dart';

// Theme types
enum ThemeType { normal, intense, victory }

/// Manages the visual theme of the game
class GameThemeManager {
  // Current theme type
  ThemeType _currentTheme = ThemeType.normal;

  // Singleton pattern
  static final GameThemeManager _instance = GameThemeManager._internal();

  factory GameThemeManager() {
    return _instance;
  }

  GameThemeManager._internal();

  // Theme colors
  final Map<ThemeType, GameThemeColors> _themeColors = {
    ThemeType.normal: GameThemeColors(
      backgroundColor: Colors.grey[900]!,
      accentColor: Colors.blue,
      buttonColor: Colors.blue,
      textColor: Colors.white,
      headMoverColor: Colors.blue,
      guesserColor: Colors.purple,
    ),
    ThemeType.intense: GameThemeColors(
      backgroundColor: Colors.red[900]!,
      accentColor: Colors.orange,
      buttonColor: Colors.orange,
      textColor: Colors.white,
      headMoverColor: Colors.deepOrange,
      guesserColor: Colors.deepPurple,
    ),
    ThemeType.victory: GameThemeColors(
      backgroundColor: Colors.amber,
      accentColor: Colors.green,
      buttonColor: Colors.green,
      textColor: Colors.black,
      headMoverColor: Colors.green,
      guesserColor: Colors.teal,
    ),
  };

  /// Set the current theme type
  void setTheme(ThemeType themeType) {
    _currentTheme = themeType;
  }

  /// Get the current theme colors
  GameThemeColors get colors => _themeColors[_currentTheme]!;

  /// Get the current theme type
  ThemeType get currentTheme => _currentTheme;

  /// Update theme based on streak count
  void updateThemeBasedOnStreak(int streak) {
    if (streak >= 3) {
      setTheme(ThemeType.victory);
    } else if (streak == 2) {
      setTheme(ThemeType.intense);
    } else {
      setTheme(ThemeType.normal);
    }
  }
}

/// Holds the color values for a specific theme
class GameThemeColors {
  final Color backgroundColor;
  final Color accentColor;
  final Color buttonColor;
  final Color textColor;
  final Color headMoverColor;
  final Color guesserColor;

  GameThemeColors({
    required this.backgroundColor,
    required this.accentColor,
    required this.buttonColor,
    required this.textColor,
    required this.headMoverColor,
    required this.guesserColor,
  });

  /// Get button gradient colors
  List<Color> getButtonGradient(bool isHeadMover) {
    final baseColor = isHeadMover ? headMoverColor : guesserColor;
    return [
      baseColor,
      baseColor.withBlue(baseColor.blue ~/ 1.5).withRed(baseColor.red ~/ 1.5),
    ];
  }

  /// Get a highlight color for effects
  Color get highlightColor => accentColor.withOpacity(0.7);
}
