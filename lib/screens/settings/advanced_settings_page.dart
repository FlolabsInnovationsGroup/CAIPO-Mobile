import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';
import '../../widgets/gradient_scaffold.dart';
import 'dart:math';

class AdvancedSettingsPage extends StatefulWidget {
  const AdvancedSettingsPage({super.key});

  @override
  _AdvancedSettingsPageState createState() => _AdvancedSettingsPageState();
}

class _AdvancedSettingsPageState extends State<AdvancedSettingsPage> with SingleTickerProviderStateMixin {
  bool developerMode = false;
  bool betaFeatures = false;
  bool enableLogs = false;
  bool experimentalAI = false;
  bool cachingEnabled = true;
  bool powerSavingMode = false;
  String selectedLogLevel = 'Warning';
  final List<String> logLevels = ['Debug', 'Info', 'Warning', 'Error', 'Critical'];
  
  bool haveUnsavedChanges = false;
  bool showRestartDialog = false;
  
  // For animations and expanded sections
  late AnimationController _animationController;
  bool _developerOptionsExpanded = false;
  bool _performanceOptionsExpanded = false;
  bool _debuggingOptionsExpanded = false;
  
  // For debug console
  final List<String> _debugLogs = [];
  final ScrollController _logsScrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
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
  void _updateSetting(String setting, dynamic value) {
    setState(() {
      switch (setting) {
        case 'developerMode':
          developerMode = value as bool;
          break;
        case 'betaFeatures':
          betaFeatures = value as bool;
          if (value == true && !showRestartDialog) {
            _showRestartRequiredDialog();
            showRestartDialog = true;
          }
          break;
        case 'enableLogs':
          enableLogs = value as bool;
          break;
        case 'experimentalAI':
          experimentalAI = value as bool;
          if (value == true && !showRestartDialog) {
            _showRestartRequiredDialog();
            showRestartDialog = true;
          }
          break;
        case 'cachingEnabled':
          cachingEnabled = value as bool;
          break;
        case 'powerSavingMode':
          powerSavingMode = value as bool;
          break;
        case 'logLevel':
          selectedLogLevel = value as String;
          break;
      }
      haveUnsavedChanges = true;
    });
    
    // Add a debug log entry
    if (enableLogs) {
      _addDebugLog("Setting '$setting' changed to '$value'");
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
                  developerMode = false;
                  betaFeatures = false;
                  enableLogs = false;
                  experimentalAI = false;
                  cachingEnabled = true;
                  powerSavingMode = false;
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
    
    return GradientScaffold(
      appBar: AppBar(
        title: const Text(
          'Advanced Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 22, 
            color: Colors.white
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
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with warning
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withOpacity(0.5),
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
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'These settings are intended for advanced users. '
                    'Changing them may affect app performance and stability.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Main settings
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Developer Options Section
                _buildExpandableSection(
                  title: 'Developer Options',
                  icon: Icons.code,
                  isExpanded: _developerOptionsExpanded,
                  onToggle: () {
                    setState(() {
                      _developerOptionsExpanded = !_developerOptionsExpanded;
                    });
                  },
                  children: [
                    _buildAnimatedSwitchTile(
                      title: 'Enable Developer Mode',
                      description: 'Access debugging tools and experimental features.',
                      icon: Icons.developer_mode,
                      value: developerMode,
                      isDarkMode: isDarkMode,
                      onChanged: (val) => _updateSetting('developerMode', val),
                    ),
                    _buildAnimatedSwitchTile(
                      title: 'Enable Beta Features',
                      description: 'Try out upcoming features before they are released.',
                      icon: Icons.new_releases,
                      value: betaFeatures,
                      isDarkMode: isDarkMode,
                      onChanged: (val) => _updateSetting('betaFeatures', val),
                    ),
                    _buildAnimatedSwitchTile(
                      title: 'Experimental AI Models',
                      description: 'Use cutting-edge AI models that are still in development.',
                      icon: Icons.psychology,
                      value: experimentalAI,
                      isDarkMode: isDarkMode,
                      onChanged: (val) => _updateSetting('experimentalAI', val),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Performance Options Section
                _buildExpandableSection(
                  title: 'Performance Options',
                  icon: Icons.speed,
                  isExpanded: _performanceOptionsExpanded,
                  onToggle: () {
                    setState(() {
                      _performanceOptionsExpanded = !_performanceOptionsExpanded;
                    });
                  },
                  children: [
                    _buildAnimatedSwitchTile(
                      title: 'Background Processing',
                      description: 'Allow the app to process data in the background.',
                      icon: Icons.all_inclusive,
                      value: !powerSavingMode,
                      isDarkMode: isDarkMode,
                      onChanged: (val) => _updateSetting('powerSavingMode', !val),
                    ),
                    _buildAnimatedSwitchTile(
                      title: 'Enable Caching',
                      description: 'Store temporary data to improve performance.',
                      icon: Icons.cached,
                      value: cachingEnabled,
                      isDarkMode: isDarkMode,
                      onChanged: (val) => _updateSetting('cachingEnabled', val),
                    ),
                    // Performance metrics card
                    if (developerMode)
                      _buildPerformanceMetricsCard(isDarkMode),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Debugging Options Section
                _buildExpandableSection(
                  title: 'Debugging Options',
                  icon: Icons.bug_report,
                  isExpanded: _debuggingOptionsExpanded,
                  onToggle: () {
                    setState(() {
                      _debuggingOptionsExpanded = !_debuggingOptionsExpanded;
                    });
                  },
                  children: [
                    _buildAnimatedSwitchTile(
                      title: 'Enable Debug Logs',
                      description: 'Log errors and diagnostic information for troubleshooting.',
                      icon: Icons.subject,
                      value: enableLogs,
                      isDarkMode: isDarkMode,
                      onChanged: (val) => _updateSetting('enableLogs', val),
                    ),
                    // Log level dropdown
                    if (enableLogs)
                      _buildLogLevelSelector(isDarkMode),
                    // Debug console
                    if (enableLogs && developerMode)
                      _buildDebugConsole(isDarkMode),
                  ],
                ),
              ],
            ),
          ),
          
          // Save button at bottom
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: haveUnsavedChanges ? _savePreferences : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.blueAccent,
                disabledBackgroundColor: Colors.blueAccent.withOpacity(0.5),
              ),
              child: Text(
                'Save Preferences',
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white.withOpacity(haveUnsavedChanges ? 1.0 : 0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      color: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.5)
                        .animate(_animationController),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
              child: Column(children: children),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnimatedSwitchTile({
    required String title,
    required String description,
    required IconData icon,
    required bool value,
    required bool isDarkMode,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        elevation: 0,
        color: Colors.white.withOpacity(isDarkMode ? 0.05 : 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: value 
                      ? Colors.blueAccent.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: value 
                      ? Colors.blueAccent
                      : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title, 
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description, 
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.blueAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLogLevelSelector(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        elevation: 0,
        color: Colors.white.withOpacity(isDarkMode ? 0.05 : 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Log Level',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Set the minimum severity level for log messages',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: DropdownButton<String>(
                  value: selectedLogLevel,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _updateSetting('logLevel', newValue);
                    }
                  },
                  items: logLevels.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                  isExpanded: true,
                  dropdownColor: Colors.grey.shade800,
                  underline: Container(), // Remove the default underline
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDebugConsole(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        elevation: 0,
        color: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Debug Console',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Clear'),
                    onPressed: _clearLogs,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, 
                        vertical: 4
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 150,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: _debugLogs.isEmpty
                    ? const Center(
                        child: Text(
                          'No logs available',
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _logsScrollController,
                        itemCount: _debugLogs.length,
                        itemBuilder: (context, index) {
                          final log = _debugLogs[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              log,
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                                color: log.contains('ERROR')
                                    ? Colors.red.shade300
                                    : log.contains('WARNING')
                                        ? Colors.orange.shade300
                                        : Colors.green.shade300,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Generate Test Log'),
                      onPressed: () {
                        final logTypes = ['INFO', 'WARNING', 'ERROR', 'DEBUG'];
                        final random = Random();
                        final logType = logTypes[random.nextInt(logTypes.length)];
                        _addDebugLog("$logType: Test log message generated");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8, 
                          horizontal: 16
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPerformanceMetricsCard(bool isDarkMode) {
    // Simulated performance metrics
    final memoryUsage = Random().nextInt(300) + 100; // 100-400 MB
    final cpuUsage = Random().nextInt(30) + 5; // 5-35%
    final responseTime = Random().nextInt(200) + 50; // 50-250ms
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        elevation: 0,
        color: Colors.blue.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Performance Metrics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _buildMetricRow(
                icon: Icons.memory,
                label: 'Memory Usage',
                value: '$memoryUsage MB',
                color: memoryUsage > 300 
                    ? Colors.red 
                    : memoryUsage > 200 
                        ? Colors.orange 
                        : Colors.green,
              ),
              const SizedBox(height: 12),
              _buildMetricRow(
                icon: Icons.speed,
                label: 'CPU Usage',
                value: '$cpuUsage%',
                color: cpuUsage > 25 
                    ? Colors.red 
                    : cpuUsage > 15 
                        ? Colors.orange 
                        : Colors.green,
              ),
              const SizedBox(height: 12),
              _buildMetricRow(
                icon: Icons.timer,
                label: 'Response Time',
                value: '$responseTime ms',
                color: responseTime > 200 
                    ? Colors.red 
                    : responseTime > 100 
                        ? Colors.orange 
                        : Colors.green,
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh Metrics'),
                  onPressed: () {
                    setState(() {
                      // This will rebuild the widget with new random values
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMetricRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
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
}
