import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../di/injection.dart';

class SettingsProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  static const String _recentSettingsKey = 'recent_settings';
  static const String _settingsStateKey = 'settings_state';
  static const String _wearableSettingsKey = 'wearable_settings';
  static const int maxRecentItems = 3;

  List<String> _recentSettings = [];
  Map<String, dynamic> _settingsState = {};
  Map<String, dynamic> _wearableSettings = {
    'dataSyncInterval': '30s',
    'batteryOptimization': true,
    'sensorSettings': {
      'motionSensor': true,
      'heartRateSensor': true,
      'temperatureSensor': true,
    },
    'devicePairing': false,
  };

  SettingsProvider(this._prefs) {
    _loadSettings();
  }

  // Getters
  List<String> get recentSettings => List.unmodifiable(_recentSettings);
  Map<String, dynamic> get settingsState => Map.unmodifiable(_settingsState);
  Map<String, dynamic> get wearableSettings => Map.unmodifiable(_wearableSettings);

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      // Load recent settings
      final recentJson = _prefs.getStringList(_recentSettingsKey);
      if (recentJson != null) {
        _recentSettings = recentJson;
      }

      // Load settings state
      final stateJson = _prefs.getString(_settingsStateKey);
      if (stateJson != null) {
        _settingsState = Map<String, dynamic>.from(
          jsonDecode(stateJson) as Map,
        );
      }

      // Load wearable settings
      final wearableJson = _prefs.getString(_wearableSettingsKey);
      if (wearableJson != null) {
        _wearableSettings = Map<String, dynamic>.from(
          jsonDecode(wearableJson) as Map,
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      await _prefs.setStringList(_recentSettingsKey, _recentSettings);
      await _prefs.setString(_settingsStateKey, jsonEncode(_settingsState));
      await _prefs.setString(_wearableSettingsKey, jsonEncode(_wearableSettings));
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  // Add to recent settings
  Future<void> addToRecent(String settingTitle) async {
    if (!_recentSettings.contains(settingTitle)) {
      _recentSettings.insert(0, settingTitle);
      if (_recentSettings.length > maxRecentItems) {
        _recentSettings.removeLast();
      }
    } else {
      _recentSettings.remove(settingTitle);
      _recentSettings.insert(0, settingTitle);
    }
    
    await _saveSettings();
    notifyListeners();
  }

  // Update a setting value
  Future<void> updateSetting(String key, dynamic value) async {
    _settingsState[key] = value;
    await _saveSettings();
    notifyListeners();
  }

  // Get a setting value with default
  T? getSetting<T>(String key, [T? defaultValue]) {
    return _settingsState[key] as T? ?? defaultValue;
  }

  // Clear recent settings
  Future<void> clearRecentSettings() async {
    _recentSettings.clear();
    await _saveSettings();
    notifyListeners();
  }

  // Update wearable settings
  Future<void> updateWearableSetting(String key, dynamic value) async {
    if (key.contains('.')) {
      // Handle nested settings (e.g., 'sensorSettings.motionSensor')
      final keys = key.split('.');
      var current = _wearableSettings;
      for (var i = 0; i < keys.length - 1; i++) {
        current = current[keys[i]] as Map<String, dynamic>;
      }
      current[keys.last] = value;
    } else {
      _wearableSettings[key] = value;
    }
    await _saveSettings();
    notifyListeners();
  }

  // Get wearable setting with default
  T? getWearableSetting<T>(String key, [T? defaultValue]) {
    if (key.contains('.')) {
      // Handle nested settings
      final keys = key.split('.');
      var current = _wearableSettings;
      for (var i = 0; i < keys.length - 1; i++) {
        current = current[keys[i]] as Map<String, dynamic>;
      }
      return current[keys.last] as T? ?? defaultValue;
    }
    return _wearableSettings[key] as T? ?? defaultValue;
  }
} 