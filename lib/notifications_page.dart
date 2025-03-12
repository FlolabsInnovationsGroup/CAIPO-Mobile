import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';
import '../../widgets/gradient_scaffold.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> with SingleTickerProviderStateMixin {
  // Notification settings
  bool pushNotifications = true;
  bool emailNotifications = false;
  bool reminders = true;
  bool weeklyReports = false;
  bool appUpdates = true;
  bool transcriptionAlerts = true;
  
  // Time preferences
  String selectedTimeRange = "Anytime";
  final List<String> timeRanges = ["Anytime", "8 AM - 8 PM", "9 AM - 5 PM", "Custom"];
  
  // Track if there are unsaved changes
  bool haveUnsavedChanges = false;
  bool showConfirmation = false;
  
  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _animationController.forward();
    
    // Simulate loading saved preferences
    _loadSavedPreferences();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  // Load saved preferences (would connect to SharedPreferences in a real app)
  Future<void> _loadSavedPreferences() async {
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    // In a real app, you would load from SharedPreferences or backend
    // For now, we'll just use the default values defined above
  }
  
  // Update a notification setting
  void _updateSetting(String setting, bool value) {
    setState(() {
      switch (setting) {
        case 'push':
          pushNotifications = value;
          break;
        case 'email':
          emailNotifications = value;
          break;
        case 'reminders':
          reminders = value;
          break;
        case 'weekly':
          weeklyReports = value;
          break;
        case 'updates':
          appUpdates = value;
          break;
        case 'transcription':
          transcriptionAlerts = value;
          break;
      }
      haveUnsavedChanges = true;
    });
  }
  
  // Save notification preferences
  void _savePreferences() {
    // In a real app, you would save to SharedPreferences or backend
    
    // Show confirmation message
    setState(() {
      showConfirmation = true;
      haveUnsavedChanges = false;
    });
    
    // Hide the confirmation after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showConfirmation = false;
        });
      }
    });
  }
  
  // Check for unsaved changes before navigating back
  Future<bool> _onWillPop() async {
    if (!haveUnsavedChanges) {
      return true;
    }
    
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved notification settings. Do you want to discard these changes?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('DISCARD'),
          ),
        ],
      ),
    );
    
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    return WillPopScope(
      onWillPop: _onWillPop,
      child: GradientScaffold(
        appBar: AppBar(
          title: const Text(
            'Notifications & Reminders',
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 22, 
              color: Colors.white
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with explanation
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manage Notifications',
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Customize how and when you receive notifications from CAIPO.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Notification settings in a scrollable list
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    _buildCategoryHeader('General Notifications', isDarkMode),
                    _buildAnimatedSwitchTile(
                      title: 'Push Notifications',
                      description: 'Receive notifications directly to your device.',
                      icon: Icons.notifications_active,
                      value: pushNotifications,
                      isDarkMode: isDarkMode,
                      onChanged: (val) => _updateSetting('push', val),
                    ),
                    _buildAnimatedSwitchTile(
                      title: 'Email Notifications',
                      description: 'Receive notifications via email.',
                      icon: Icons.email,
                      value: emailNotifications,
                      isDarkMode: isDarkMode,
                      onChanged: (val) => _updateSetting('email', val),
                    ),
                    
                    _buildCategoryHeader('App Notifications', isDarkMode),
                    _buildAnimatedSwitchTile(
                      title: 'Reminders',
                      description: 'Get reminded about pending tasks and actions.',
                      icon: Icons.access_time,
                      value: reminders,
                      isDarkMode: isDarkMode,
                      onChanged: (val) => _updateSetting('reminders', val),
                    ),
                    _buildAnimatedSwitchTile(
                      title: 'Weekly Reports',
                      description: 'Receive a summary of your activity every week.',
                      icon: Icons.summarize,
                      value: weeklyReports,
                      isDarkMode: isDarkMode,
                      onChanged: (val) => _updateSetting('weekly', val),
                    ),
                    
                    _buildCategoryHeader('Content Notifications', isDarkMode),
                    _buildAnimatedSwitchTile(
                      title: 'App Updates',
                      description: 'Be notified when new features are available.',
                      icon: Icons.system_update,
                      value: appUpdates,
                      isDarkMode: isDarkMode,
                      onChanged: (val) => _updateSetting('updates', val),
                    ),
                    _buildAnimatedSwitchTile(
                      title: 'Transcription Alerts',
                      description: 'Get notified when your transcriptions are ready.',
                      icon: Icons.record_voice_over,
                      value: transcriptionAlerts,
                      isDarkMode: isDarkMode,
                      onChanged: (val) => _updateSetting('transcription', val),
                    ),
                    
                    // Notification time preferences
                    if (pushNotifications || emailNotifications) ...[
                      _buildCategoryHeader('Notification Time', isDarkMode),
                      _buildTimePreferences(isDarkMode),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'You can change these settings at any time. Some platform-specific notification settings may also need to be configured in your device settings.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.grey.shade400 : Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              
              // Save button and confirmation at bottom
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Success confirmation
                    AnimatedCrossFade(
                      firstChild: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Notification settings saved!',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      secondChild: const SizedBox(height: 36),
                      crossFadeState: showConfirmation 
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 300),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Save button
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: haveUnsavedChanges ? _savePreferences : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCategoryHeader(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(0, 1),
              blurRadius: 2,
            ),
          ],
          letterSpacing: 0.5,
        ),
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
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            elevation: isDarkMode ? 0 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: isDarkMode 
                ? Colors.black.withOpacity(0.3)
                : Colors.white.withOpacity(0.9),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: value 
                        ? (isDarkMode 
                            ? Colors.blueAccent.withOpacity(0.3) 
                            : Colors.blue.withOpacity(0.1))
                        : (isDarkMode 
                            ? Colors.grey.shade800 
                            : Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: value 
                        ? Colors.blueAccent
                        : isDarkMode 
                            ? Colors.grey.shade400 
                            : Colors.grey.shade600,
                    size: 24,
                  ),
                ),
                title: Text(
                  title, 
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  description, 
                  style: TextStyle(
                    fontSize: 13, 
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
                trailing: Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: Colors.blueAccent,
                  activeTrackColor: isDarkMode 
                      ? Colors.blueAccent.withOpacity(0.3)
                      : Colors.blue.withOpacity(0.15),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildTimePreferences(bool isDarkMode) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: isDarkMode ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDarkMode 
          ? Colors.black.withOpacity(0.3)
          : Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  'Notification Time Preference',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: timeRanges.map((time) {
                final isSelected = selectedTimeRange == time;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTimeRange = time;
                      haveUnsavedChanges = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, 
                      vertical: 8
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blueAccent.withOpacity(isDarkMode ? 0.3 : 0.1)
                          : isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected 
                            ? Colors.blueAccent 
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? Colors.blueAccent
                            : isDarkMode
                                ? Colors.grey.shade300
                                : Colors.grey.shade700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (selectedTimeRange == "Custom") ...[
              const SizedBox(height: 16),
              Text(
                'Select custom time range',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        // Would show time picker here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Time picker would appear here'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12, 
                          horizontal: 12
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: isDarkMode
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '9:00 AM',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('to'),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        // Would show time picker here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Time picker would appear here'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12, 
                          horizontal: 12
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: isDarkMode
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '5:00 PM',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}