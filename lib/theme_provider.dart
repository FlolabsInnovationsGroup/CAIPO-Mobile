import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark; // Default is dark mode
  bool _usePurpleGradient = true; // Control which gradient to use in dark mode

  // Add animation duration preference
  final Duration _animationDuration = Duration(milliseconds: 300);
  
  // Add font family option
  final String _fontFamily = 'Roboto';
  
  // Add accent color choice
  final Color _accentColor = Colors.blueAccent;
  
  // Add border radius
  final double _borderRadius = 12.0;

  ThemeMode get themeMode => _themeMode;
  bool get usePurpleGradient => _usePurpleGradient;
  Color get accentColor => _accentColor;
  double get borderRadius => _borderRadius;

  // Get the appropriate scaffold gradient based on theme
  LinearGradient get scaffoldGradient {
    if (_themeMode == ThemeMode.light) {
      // Light theme gradient - light blue shades
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF2196F3), // Light blue
          Color(0xFF1976D2), // Slightly darker blue
          Color(0xFF0D47A1), // Even darker blue
          Color(0xFF0A2351), // Very dark blue
        ],
        stops: [0.0, 0.4, 0.8, 1.0],
      );
    } else {
      // Dark theme gradient
      if (_usePurpleGradient) {
        // Purple to dark blue gradient
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F0521), // Darker purple than Flutter standard
            Color(0xFF000000), // Black
          ],
          stops: [0.6, 1.0],
        );
      } else {
        // Original teal/navy gradient (like the reference image)
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF003545), // Deep teal/navy
            Color(0xFF001E2E), // Darker teal/navy
            Color(0xFF000E18), // Very dark blue
            Color(0xFF000000), // Black
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        );
      }
    }
  }

  // Get the header gradient (can be used for cards, app bars, etc.)
  LinearGradient get headerGradient {
    if (_themeMode == ThemeMode.light) {
      return const LinearGradient(
        colors: [Colors.blueAccent, Colors.lightBlueAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      if (_usePurpleGradient) {
        return const LinearGradient(
          colors: [Color(0xFF6200EA), Color(0xFF3700B3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      } else {
        return const LinearGradient(
          colors: [Color(0xFF0A0F1F), Color(0xFF152238)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      }
    }
  }

  // Get the appropriate gradient colors as a list (for backward compatibility)
  List<Color> getGradientColors() {
    if (_themeMode == ThemeMode.light) {
      // Light theme gradient - light blue shades
      return const [
        Color(0xFF2196F3), // Light blue
        Color(0xFF1976D2), // Slightly darker blue
        Color(0xFF0D47A1), // Even darker blue
        Color(0xFF0A2351), // Very dark blue
      ];
    } else {
      // Dark theme gradient
      if (_usePurpleGradient) {
        // Purple to dark blue gradient
        return const [
          Color(0xFF6200EA), // Deep purple
          Color(0xFF3700B3), // Purple
          Color(0xFF1A237E), // Indigo
          Color(0xFF000A35), // Very dark blue
        ];
      } else {
        // Original teal/navy gradient (like the reference image)
        return const [
          Color(0xFF003545), // Deep teal/navy
          Color(0xFF001E2E), // Darker teal/navy
          Color(0xFF000E18), // Very dark blue
          Color(0xFF000000), // Black
        ];
      }
    }
  }

  // Toggle between light and dark themes
  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Toggle between purple gradient and teal gradient in dark mode
  void toggleGradientStyle(bool usePurple) {
    _usePurpleGradient = usePurple;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  Color getIconColor(BuildContext context) {
    return _themeMode == ThemeMode.dark 
        ? Colors.white 
        : Colors.black87;
  }

  Color getTextColor(BuildContext context) {
    return _themeMode == ThemeMode.dark 
        ? Colors.white 
        : Colors.black87;
  }

  Color get cardBackground {
    return _themeMode == ThemeMode.dark 
        ? Colors.black.withAlpha(179) // 0.7 * 255 ≈ 179
        : Colors.white.withAlpha(230); // 0.9 * 255 ≈ 230
  }

  TextStyle get headlineStyle {
    return TextStyle(
      color: _themeMode == ThemeMode.dark ? Colors.white : Colors.black87,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    );
  }

  TextStyle get bodyTextStyle {
    return TextStyle(
      color: _themeMode == ThemeMode.dark ? Colors.white70 : Colors.black87,
      fontSize: 16,
    );
  }

  Color get inputBackgroundColor {
    return _themeMode == ThemeMode.dark 
        ? Colors.grey.shade800 
        : Colors.grey.shade200;
  }

  Color get inputTextColor {
    return _themeMode == ThemeMode.dark 
        ? Colors.white 
        : Colors.black87;
  }

  // Text styles
  TextStyle get titleMedium => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: primaryTextColor,
  );
  
  TextStyle get titleLarge => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: primaryTextColor,
  );
  
  TextStyle get bodyLarge => TextStyle(
    fontSize: 16,
    color: primaryTextColor,
  );
  
  TextStyle get bodyMedium => TextStyle(
    fontSize: 14,
    color: primaryTextColor,
  );
  
  TextStyle get bodySmall => TextStyle(
    fontSize: 12,
    color: secondaryTextColor,
  );
  
  TextStyle get headlineMedium => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: primaryTextColor,
  );
  
  // Text colors
  Color get primaryTextColor => _themeMode == ThemeMode.dark 
      ? Colors.white 
      : Colors.black87;
      
  Color get secondaryTextColor => _themeMode == ThemeMode.dark 
      ? Colors.white70 
      : Colors.black54;
      
  Color get secondaryIconColor => _themeMode == ThemeMode.dark 
      ? Colors.white70 
      : Colors.black45;

  ButtonStyle get textButtonStyle => TextButton.styleFrom(
    foregroundColor: accentColor,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  );
}