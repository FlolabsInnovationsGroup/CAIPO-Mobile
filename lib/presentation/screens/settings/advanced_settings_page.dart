import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/gradient_scaffold.dart';
import 'dart:math';
import 'dart:async';

class AdvancedSettingsPage extends StatefulWidget {
  const AdvancedSettingsPage({super.key});

  @override
  _AdvancedSettingsPageState createState() => _AdvancedSettingsPageState();
}

class _AdvancedSettingsPageState extends State<AdvancedSettingsPage> with SingleTickerProviderStateMixin {
  // Settings values
  final Map<String, Map<String, dynamic>> _settings = {
    'Developer Options': {
      'Enable Developer Mode': {
        'value': false,
        'icon': Icons.developer_mode,
        'description': 'Access debugging tools and experimental features.',
        'details': 'Activates additional menus and options for development purposes. Not recommended for regular users.'
      },
      'Enable Beta Features': {
        'value': false,
        'icon': Icons.new_releases,
        'description': 'Try out upcoming features before they are released.',
        'details': 'Enables access to beta features which may not be fully stable. Requires app restart.',
        'requiresRestart': true
      },
      'Experimental AI Models': {
        'value': false,
        'icon': Icons.psychology,
        'description': 'Use cutting-edge AI models that are still in development.',
        'details': 'Enables access to the latest experimental AI models. May affect performance and accuracy. Requires app restart.',
        'requiresRestart': true
      },
      'API Access': {
        'value': false,
        'icon': Icons.api,
        'description': 'Enable direct API access for custom integrations.',
        'details': 'Provides access to the API configuration and token management for external integrations.'
      },
    },
    'Performance Options': {
      'Background Processing': {
        'value': true,
        'icon': Icons.all_inclusive,
        'description': 'Allow the app to process data in the background.',
        'details': 'Enables the app to continue processing tasks when minimized or when the screen is off. Disabling may save battery.'
      },
      'Enable Caching': {
        'value': true,
        'icon': Icons.cached,
        'description': 'Store temporary data to improve performance.',
        'details': 'Caches data to disk to improve load times and reduce network usage. Disabling will free up storage space but may slow down the app.'
      },
      'High Performance Mode': {
        'value': false,
        'icon': Icons.speed,
        'description': 'Optimize for maximum performance at the expense of battery life.',
        'details': 'Uses more system resources to deliver the best possible performance. May significantly increase battery usage.'
      },
      'Offline Mode': {
        'value': false,
        'icon': Icons.wifi_off,
        'description': 'Work without an internet connection using cached data.',
        'details': 'Disables network requests and operates using only locally cached data. Limited functionality available.'
      },
    },
    'Debugging Options': {
      'Enable Debug Logs': {
        'value': false,
        'icon': Icons.subject,
        'description': 'Log errors and diagnostic information for troubleshooting.',
        'details': 'Records detailed application logs which can help identify and fix issues. May affect performance slightly.'
      },
      'Crash Reporting': {
        'value': true,
        'icon': Icons.report_problem,
        'description': 'Automatically send crash reports to help improve stability.',
        'details': 'Sends anonymous crash reports to our servers to help identify and fix issues. No personal data is included.'
      },
      'Extended Error Details': {
        'value': false,
        'icon': Icons.bug_report,
        'description': 'Show detailed technical error information when problems occur.',
        'details': 'Displays technical error details when crashes or errors occur, instead of user-friendly messages.'
      },
      'Network Debugging': {
        'value': false,
        'icon': Icons.wifi,
        'description': 'Monitor and log network traffic for troubleshooting.',
        'details': 'Logs all network requests and responses for debugging. May slow down network operations.'
      },
    },
    'Advanced Features': {
      'Custom Themes': {
        'value': false,
        'icon': Icons.format_paint,
        'description': 'Create and apply custom themes beyond the built-in options.',
        'details': 'Allows creating and modifying custom themes with advanced color and style options.'
      },
      'Voice Command Mode': {
        'value': false,
        'icon': Icons.record_voice_over,
        'description': 'Control the app using voice commands for hands-free operation.',
        'details': 'Enables navigation and control of the app using voice commands. Requires microphone permission.'
      },
      'Alternative Text Models': {
        'value': false,
        'icon': Icons.text_fields,
        'description': 'Use third-party text processing models instead of default models.',
        'details': 'Allows using alternative text processing models. May require additional downloads.'
      },
      'Keyboard Shortcuts': {
        'value': true,
        'icon': Icons.keyboard,
        'description': 'Enable keyboard shortcuts for faster navigation and actions.',
        'details': 'Enables keyboard shortcuts for common actions on desktop platforms.'
      },
    },
  };
  
  // Selected log level
  String selectedLogLevel = 'Warning';
  final List<String> logLevels = ['Debug', 'Info', 'Warning', 'Error', 'Critical'];
  
  // Debug console
  final List<String> _debugLogs = [];
  final ScrollController _logsScrollController = ScrollController();
  final TextEditingController _logInputController = TextEditingController();
  
  // State variables
  bool haveUnsavedChanges = false;
  bool showRestartDialog = false;
  final String _searchQuery = '';
  String? _selectedCategory;
  bool _showSystemInfo = false;
  final bool _showPerformanceMetrics = false;
  Timer? _metricsRefreshTimer;
  final Map<String, double> _metrics = {
    'Memory Usage': 0,
    'CPU Usage': 0,
    'Network Speed': 0,
    'Battery Drain': 0,
    'Storage': 0,
  };
  
  // For animations and expanded sections
  late AnimationController _animationController;
  final Set<String> _expandedCategories = {'Developer Options', 'Performance Options', 'Debugging Options', 'Advanced Features'};
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Set initial selected category
    _selectedCategory = _settings.keys.first;
    
    // Populate some sample debug logs
    _debugLogs.add("[${DateTime.now().toString()}] System initialized");
    _debugLogs.add("[${DateTime.now().toString()}] All components loaded");
    _debugLogs.add("[${DateTime.now().toString()}] Ready");
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _logsScrollController.dispose();
    super.dispose();
  }
  
  // Update settings and track changes
  void _updateSetting(String category, String setting, bool value) {
    setState(() {
      if (_settings[category]?[setting] != null) {
        _settings[category]![setting]['value'] = value;
        haveUnsavedChanges = true;
        
        // Check if restart is required
        if (_settings[category]![setting]['requiresRestart'] == true && !showRestartDialog) {
          _showRestartRequiredDialog();
          showRestartDialog = true;
        }
      }
    });
    
    // Add a debug log entry
    if (_settings['Debugging Options']?['Enable Debug Logs']?['value'] == true) {
      _addDebugLog("Setting '$setting' in '$category' changed to '$value'");
    }
  }
  
  void _addDebugLog(String message) {
    setState(() {
      _debugLogs.add("[${DateTime.now().toString()}] $message");
    });
    
    // Scroll to the bottom of the logs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logsScrollController.hasClients) {
        _logsScrollController.animateTo(
          _logsScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  void _savePreferences() {
    // Here you would save to shared preferences or a backend
    
    // Add success log
    _addDebugLog("Advanced settings saved successfully");
    
    // Show a snackbar to confirm
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Advanced settings saved'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
    
    setState(() {
      haveUnsavedChanges = false;
    });
  }
  
  void _clearLogs() {
    setState(() {
      _debugLogs.clear();
      _addDebugLog("Logs cleared");
    });
  }
  
  void _showRestartRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Restart Required'),
          content: const Text(
            'Some of the changes you made require the app to be restarted to take effect. '
            'These changes will be applied the next time you launch the app.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  
  void _resetAllSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset All Settings'),
          content: const Text(
            'This will reset all advanced settings to their default values. '
            'This action cannot be undone. Are you sure?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  // Reset all settings to their default values
                  _settings['Developer Options']?.forEach((key, value) {
                    value['value'] = false;
                  });
                  
                  _settings['Performance Options']?['Background Processing']?['value'] = true;
                  _settings['Performance Options']?['Enable Caching']?['value'] = true;
                  _settings['Performance Options']?['High Performance Mode']?['value'] = false;
                  _settings['Performance Options']?['Offline Mode']?['value'] = false;
                  
                  _settings['Debugging Options']?['Enable Debug Logs']?['value'] = false;
                  _settings['Debugging Options']?['Crash Reporting']?['value'] = true;
                  _settings['Debugging Options']?['Extended Error Details']?['value'] = false;
                  _settings['Debugging Options']?['Network Debugging']?['value'] = false;
                  
                  _settings['Advanced Features']?['Custom Themes']?['value'] = false;
                  _settings['Advanced Features']?['Voice Command Mode']?['value'] = false;
                  _settings['Advanced Features']?['Alternative Text Models']?['value'] = false;
                  _settings['Advanced Features']?['Keyboard Shortcuts']?['value'] = true;
                  
                  selectedLogLevel = 'Warning';
                  haveUnsavedChanges = true;
                });
                _addDebugLog("All settings reset to defaults");
              },
              child: const Text('RESET'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    return WillPopScope(
      onWillPop: () async {
        if (haveUnsavedChanges) {
          _showUnsavedChangesDialog();
          return false;
        }
        return true;
      },
      child: GradientScaffold(
        appBar: AppBar(
          title: Text(
            'Advanced Settings',
            style: themeProvider.headlineLarge.copyWith(
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (haveUnsavedChanges) {
                _showUnsavedChangesDialog();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _resetAllSettings,
              tooltip: 'Reset all settings',
            ),
            // Toggle system info
            IconButton(
              icon: Icon(_showSystemInfo ? Icons.info : Icons.info_outline, color: Colors.white),
              onPressed: _toggleSystemInfo,
              tooltip: 'System Information',
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with warning
            _buildWarningHeader(isDarkMode, themeProvider),
            
            // Category tabs
            _buildCategoryTabs(isDarkMode, themeProvider),
            
            // Main content
            Expanded(
              child: _buildMainContent(isDarkMode, themeProvider),
            ),
            
            // Save button at bottom
            _buildBottomActionBar(isDarkMode, themeProvider),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMainContent(bool isDarkMode, ThemeProvider themeProvider) {
    // Show system info if enabled
    if (_showSystemInfo) {
      return _buildSystemInfoView(isDarkMode, themeProvider);
    }
    
    // Show all settings
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // If a category is selected, show only its settings
        if (_selectedCategory != null && _settings.containsKey(_selectedCategory)) ...[
          ...buildSettingsForCategory(_selectedCategory!, isDarkMode, themeProvider),
        ],
        
        // If Developer Mode is enabled, show additional debug options
        if (_selectedCategory == 'Debugging Options' && 
            _settings['Developer Options']?['Enable Developer Mode']?['value'] == true) ...[
          _buildDebugConsole(isDarkMode, themeProvider),
        ],
        
        // If Performance Metrics is enabled, show metrics panel
        if (_selectedCategory == 'Performance Options' && 
            _settings['Developer Options']?['Enable Developer Mode']?['value'] == true) ...[
          const SizedBox(height: 16),
          _buildPerformanceMetricsPanel(isDarkMode, themeProvider),
        ],
      ],
    );
  }

  List<Widget> buildSettingsForCategory(String category, bool isDarkMode, ThemeProvider themeProvider) {
    final settingsForCategory = _settings[category];
    if (settingsForCategory == null) return [];
    
    return [
      _buildCategoryHeader(category, isDarkMode, themeProvider),
      
      // If this is the Debugging category and debug logs are enabled, show log level selector
      if (category == 'Debugging Options' && 
          settingsForCategory['Enable Debug Logs']?['value'] == true) ...[
        _buildLogLevelSelector(isDarkMode, themeProvider),
      ],
      
      // Display all settings for this category
      ...settingsForCategory.entries.map((entry) {
        final settingName = entry.key;
        final settingData = entry.value;
        
        return _buildAnimatedSwitchTile(
          title: settingName,
          description: settingData['description'] as String,
          details: settingData['details'] as String,
          icon: settingData['icon'] as IconData,
          value: settingData['value'] as bool,
          isDarkMode: isDarkMode,
          themeProvider: themeProvider,
          requiresRestart: settingData['requiresRestart'] as bool? ?? false,
          onChanged: (val) => _updateSetting(category, settingName, val),
        );
      }),
    ];
  }

  Widget _buildWarningHeader(bool isDarkMode, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(themeProvider.borderRadius),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'These settings are intended for advanced users. Changes may affect app stability.',
              style: themeProvider.bodyMedium.copyWith(
                color: Colors.orange.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(bool isDarkMode, ThemeProvider themeProvider) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _settings.keys.map((category) {
          final isSelected = _selectedCategory == category;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? themeProvider.accentColor.withOpacity(isDarkMode ? 0.3 : 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(themeProvider.borderRadius),
                border: Border.all(
                  color: isSelected 
                      ? themeProvider.accentColor 
                      : themeProvider.settingsCardBorderColor,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    size: 18,
                    color: isSelected 
                        ? themeProvider.accentColor
                        : themeProvider.secondaryIconColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.replaceAll(' Options', ''),
                    style: themeProvider.bodyMedium.copyWith(
                      color: isSelected 
                          ? themeProvider.accentColor
                          : themeProvider.secondaryTextColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSystemInfoView(bool isDarkMode, ThemeProvider themeProvider) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Container(
          decoration: themeProvider.settingsCardDecoration,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'System Information',
                style: themeProvider.settingsHeaderStyle,
              ),
              const SizedBox(height: 16),
              _buildSystemInfoRow('Operating System', 'Android 13', themeProvider),
              _buildSystemInfoRow('Device Model', 'Pixel 6', themeProvider),
              _buildSystemInfoRow('App Version', '1.0.0 (build 100)', themeProvider),
              _buildSystemInfoRow('Screen Resolution', '1080 x 2400', themeProvider),
              _buildSystemInfoRow('Memory Usage', '1.2 GB / 8 GB', themeProvider),
              _buildSystemInfoRow('Storage', '45.3 GB free of 128 GB', themeProvider),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSystemInfoRow(String label, String value, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: themeProvider.bodyMedium.copyWith(
              color: themeProvider.secondaryTextColor,
            ),
          ),
          Text(
            value,
            style: themeProvider.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetricsPanel(bool isDarkMode, ThemeProvider themeProvider) {
    // Implementation of _buildPerformanceMetricsPanel method
    // This method should return a widget representing the performance metrics panel
    return Container(); // Placeholder return, actual implementation needed
  }

  Widget _buildDebugConsole(bool isDarkMode, ThemeProvider themeProvider) {
    // Implementation of _buildDebugConsole method
    // This method should return a widget representing the debug console
    return Container(); // Placeholder return, actual implementation needed
  }

  Widget _buildBottomActionBar(bool isDarkMode, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: themeProvider.settingsBottomBarDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: _resetAllSettings,
            icon: const Icon(Icons.restore),
            label: const Text('Reset All'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
          ElevatedButton(
            onPressed: haveUnsavedChanges ? _saveSettings : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.accentColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: themeProvider.accentColor.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Save Changes',
              style: themeProvider.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleSystemInfo() {
    setState(() {
      _showSystemInfo = !_showSystemInfo;
      _selectedCategory = null;
    });
  }

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
            'You have unsaved changes. Would you like to save them before leaving?'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to previous screen
              },
              child: const Text('DISCARD'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _savePreferences();
                Navigator.pop(context);
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryHeader(String category, bool isDarkMode, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: themeProvider.settingsHeaderDecoration,
        child: Row(
          children: [
            Icon(
              _getCategoryIcon(category),
              color: themeProvider.accentColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              category,
              style: themeProvider.settingsHeaderStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogLevelSelector(bool isDarkMode, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(themeProvider.borderRadius),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tune,
                color: themeProvider.accentColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Logging Level',
                style: themeProvider.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDarkMode ? Colors.black38 : Colors.white10,
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: logLevels.length,
              itemBuilder: (context, index) {
                final level = logLevels[index];
                final isSelected = selectedLogLevel == level;
                
                // Choose appropriate color based on log level
                Color levelColor;
                switch (level) {
                  case 'Debug':
                    levelColor = Colors.grey;
                    break;
                  case 'Info':
                    levelColor = Colors.blue;
                    break;
                  case 'Warning':
                    levelColor = Colors.orange;
                    break;
                  case 'Error':
                    levelColor = Colors.red;
                    break;
                  case 'Critical':
                    levelColor = Colors.purple;
                    break;
                  default:
                    levelColor = Colors.grey;
                }
                
                return GestureDetector(
                  onTap: () => _updateLogLevel(level),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? levelColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        level,
                        style: themeProvider.bodyMedium.copyWith(
                          color: isSelected ? Colors.white : levelColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Controls the verbosity of logs. Higher levels include all lower levels.',
            style: themeProvider.bodySmall.copyWith(
              color: themeProvider.secondaryTextColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_expandedCategories.contains(category)) {
        _expandedCategories.remove(category);
      } else {
        _expandedCategories.add(category);
      }
    });
  }

  Widget _buildAnimatedSwitchTile({
    required String title,
    required String description,
    required String details,
    required IconData icon,
    required bool value,
    required bool isDarkMode,
    required ThemeProvider themeProvider,
    required bool requiresRestart,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: themeProvider.settingsCardDecoration,
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: themeProvider.getSettingsIconDecoration(isActive: value),
              child: Icon(
                icon,
                color: themeProvider.getSettingsIconColor(isActive: value),
                size: 20,
              ),
            ),
            title: Text(
              title,
              style: themeProvider.settingsTitleStyle,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  description,
                  style: themeProvider.settingsDescriptionStyle,
                ),
                if (requiresRestart) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.refresh,
                        size: 14,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Requires restart',
                        style: themeProvider.bodySmall.copyWith(
                          color: Colors.orange,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            trailing: Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: themeProvider.accentColor,
              activeTrackColor: themeProvider.accentColor.withOpacity(0.4),
              inactiveThumbColor: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade50,
              inactiveTrackColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
            ),
          ),
          if (details.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                details,
                style: themeProvider.bodySmall.copyWith(
                  color: themeProvider.secondaryTextColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _updateLogLevel(String level) {
    setState(() {
      selectedLogLevel = level;
    });
    
    // Add a debug log entry
    if (_settings['Debugging Options']?['Enable Debug Logs']?['value'] == true) {
      _addDebugLog("Logging level changed to '$level'");
    }
  }

  // Save settings
  void _saveSettings() {
    // Here you would typically save to SharedPreferences or backend
    setState(() {
      haveUnsavedChanges = false;
    });

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings saved successfully'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Developer Options':
        return Icons.code;
      case 'Performance Options':
        return Icons.speed;
      case 'Debugging Options':
        return Icons.bug_report;
      case 'Advanced Features':
        return Icons.extension;
      default:
        return Icons.settings;
    }
  }
}
