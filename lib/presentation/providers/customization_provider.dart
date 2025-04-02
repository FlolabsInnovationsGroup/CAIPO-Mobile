import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CommandStyle {
  voice,
  gesture,
  both,
}

enum NotificationStyle {
  minimal,
  standard,
  detailed,
}

class CustomizationProvider with ChangeNotifier {
  static const String _commandStyleKey = 'command_style';
  static const String _notificationStyleKey = 'notification_style';
  static const String _useHapticFeedbackKey = 'haptic_feedback';
  static const String _useVoiceFeedbackKey = 'voice_feedback';
  static const String _useAnimationsKey = 'use_animations';
  static const String _animationSpeedKey = 'animation_speed';
  static const String _useCompactLayoutKey = 'compact_layout';
  static const String _customGesturesKey = 'custom_gestures';

  final SharedPreferences _prefs;

  CommandStyle _commandStyle;
  NotificationStyle _notificationStyle;
  bool _useHapticFeedback;
  bool _useVoiceFeedback;
  bool _useAnimations;
  double _animationSpeed;
  bool _useCompactLayout;
  Map<String, String> _customGestures;

  CustomizationProvider(this._prefs) :
    _commandStyle = CommandStyle.values[_prefs.getInt(_commandStyleKey) ?? CommandStyle.both.index],
    _notificationStyle = NotificationStyle.values[_prefs.getInt(_notificationStyleKey) ?? NotificationStyle.standard.index],
    _useHapticFeedback = _prefs.getBool(_useHapticFeedbackKey) ?? true,
    _useVoiceFeedback = _prefs.getBool(_useVoiceFeedbackKey) ?? true,
    _useAnimations = _prefs.getBool(_useAnimationsKey) ?? true,
    _animationSpeed = _prefs.getDouble(_animationSpeedKey) ?? 1.0,
    _useCompactLayout = _prefs.getBool(_useCompactLayoutKey) ?? false,
    _customGestures = Map<String, String>.from(
      _prefs.getString(_customGesturesKey) != null
          ? jsonDecode(_prefs.getString(_customGesturesKey)!)
          : {}
    );

  // Getters
  CommandStyle get commandStyle => _commandStyle;
  NotificationStyle get notificationStyle => _notificationStyle;
  bool get useHapticFeedback => _useHapticFeedback;
  bool get useVoiceFeedback => _useVoiceFeedback;
  bool get useAnimations => _useAnimations;
  double get animationSpeed => _animationSpeed;
  bool get useCompactLayout => _useCompactLayout;
  Map<String, String> get customGestures => _customGestures;

  // Layout helpers
  double get contentPadding => _useCompactLayout ? 8.0 : 16.0;
  double get itemSpacing => _useCompactLayout ? 8.0 : 12.0;
  double get cardElevation => _useCompactLayout ? 0.0 : 2.0;

  // Animation duration calculator
  Duration getAnimationDuration({Duration standard = const Duration(milliseconds: 300)}) {
    return Duration(milliseconds: (standard.inMilliseconds * (1 / _animationSpeed)).round());
  }

  // Setters with persistence
  Future<void> setCommandStyle(CommandStyle style) async {
    _commandStyle = style;
    await _prefs.setInt(_commandStyleKey, style.index);
    notifyListeners();
  }

  Future<void> setNotificationStyle(NotificationStyle style) async {
    _notificationStyle = style;
    await _prefs.setInt(_notificationStyleKey, style.index);
    notifyListeners();
  }

  Future<void> setHapticFeedback(bool value) async {
    _useHapticFeedback = value;
    await _prefs.setBool(_useHapticFeedbackKey, value);
    notifyListeners();
  }

  Future<void> setVoiceFeedback(bool value) async {
    _useVoiceFeedback = value;
    await _prefs.setBool(_useVoiceFeedbackKey, value);
    notifyListeners();
  }

  Future<void> setUseAnimations(bool value) async {
    _useAnimations = value;
    await _prefs.setBool(_useAnimationsKey, value);
    notifyListeners();
  }

  Future<void> setAnimationSpeed(double speed) async {
    _animationSpeed = speed.clamp(0.5, 2.0);
    await _prefs.setDouble(_animationSpeedKey, _animationSpeed);
    notifyListeners();
  }

  Future<void> setCompactLayout(bool value) async {
    _useCompactLayout = value;
    await _prefs.setBool(_useCompactLayoutKey, value);
    notifyListeners();
  }

  Future<void> setCustomGesture(String gesture, String action) async {
    _customGestures[gesture] = action;
    await _saveCustomGestures();
    notifyListeners();
  }

  Future<void> removeCustomGesture(String gesture) async {
    _customGestures.remove(gesture);
    await _saveCustomGestures();
    notifyListeners();
  }

  Future<void> _saveCustomGestures() async {
    await _prefs.setString(_customGesturesKey, jsonEncode(_customGestures));
  }

  // Helper methods for UI components
  Widget wrapWithAnimation(BuildContext context, Widget child, {bool slide = false}) {
    if (!_useAnimations) return child;

    return AnimatedSwitcher(
      duration: getAnimationDuration(),
      child: slide
          ? SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: ModalRoute.of(context)!.animation!,
                curve: Curves.easeOut,
              )),
              child: child,
            )
          : child,
    );
  }
} 