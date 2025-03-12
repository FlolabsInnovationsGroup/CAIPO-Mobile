import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  late SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.system;
  bool _usePurpleGradient = true; // Control which gradient to use in dark mode

  // Add animation duration preference
  final Duration _animationDuration = Duration(milliseconds: 300);
  
  // Add font family option
  final String _fontFamily = 'Roboto';
  
  // Add accent color choice
  final Color _accentColor = Colors.blueAccent;

  ThemeProvider() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;
  bool get usePurpleGradient => _usePurpleGradient;

  Future<void> _loadThemeMode() async {
    _prefs = await SharedPreferences.getInstance();
    final savedTheme = _prefs.getString(_themeKey);
    if (savedTheme != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedTheme,
        orElse: () => ThemeMode.system,
      );
      notifyListeners();
    }
  }

  Future<void> loadPreferences() async {
    await _loadThemeMode();
    // Load gradient preference
    _usePurpleGradient = _prefs.getBool('usePurpleGradient') ?? true;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(_themeKey, mode.toString());
    notifyListeners();
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Get the appropriate scaffold gradient based on theme
  LinearGradient get scaffoldGradient {
    if (_themeMode == ThemeMode.light) {
      // Light theme gradient - softer blue shades for better visibility
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF2196F3), // Primary blue
          Color(0xFF1976D2), // Slightly darker blue
          Color(0xFF1565C0), // Even darker blue
          Color(0xFF0D47A1), // Very dark blue
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
      );
    } else {
      // Dark theme gradient
      if (_usePurpleGradient) {
        // Purple to dark blue gradient
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F0521), // Darker purple
            Color(0xFF000000), // Black
          ],
          stops: [0.6, 1.0],
        );
      } else {
        // Original teal/navy gradient
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
        colors: [
          Color(0xFF2196F3),  // Primary blue
          Color(0xFF64B5F6),  // Lighter blue
        ],
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
  void toggleTheme(bool isDarkMode) async {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    // Save the preference
    await _prefs.setBool('isDarkMode', isDarkMode);
    notifyListeners();
  }

  // Toggle between purple gradient and teal gradient in dark mode
  void toggleGradientStyle(bool usePurple) async {
    _usePurpleGradient = usePurple;
    // Save the preference
    await _prefs.setBool('usePurpleGradient', usePurple);
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
        : Colors.white; // Always white for better contrast
  }

  Color get cardBackground {
    return _themeMode == ThemeMode.dark 
        ? Colors.black.withAlpha(179) // 0.7 * 255 ≈ 179
        : Colors.white.withAlpha(230); // 0.9 * 255 ≈ 230
  }

  TextStyle get headlineStyle {
    return TextStyle(
      color: Colors.white, // Always white for better contrast
      fontSize: 22,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.3),
          offset: const Offset(0, 2),
          blurRadius: 4,
        ),
      ],
    );
  }

  TextStyle get bodyTextStyle {
    return TextStyle(
      color: _themeMode == ThemeMode.dark ? Colors.white70 : Colors.white,
      fontSize: 16,
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.2),
          offset: const Offset(0, 1),
          blurRadius: 3,
        ),
      ],
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
}