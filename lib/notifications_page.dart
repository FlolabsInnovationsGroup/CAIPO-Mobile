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
  // Grouped notification settings
  Map<String, Map<String, bool>> _notificationGroups = {
    'General': {
      'Push Notifications': true,
      'Email Notifications': false,
    },
    'App': {
      'Reminders': true,
      'Weekly Reports': false,
    },
    'Content': {
      'App Updates': true,
      'Transcription Alerts': true,
    }
  };
  
  // Icons for each notification type
  final Map<String, IconData> _notificationIcons = {
    'Push Notifications': Icons.notifications_active,
    'Email Notifications': Icons.email,
    'Reminders': Icons.access_time,
    'Weekly Reports': Icons.summarize,
    'App Updates': Icons.system_update,
    'Transcription Alerts': Icons.record_voice_over,
  };
  
  // Descriptions for each notification type
  final Map<String, String> _notificationDescriptions = {
    'Push Notifications': 'Receive notifications directly to your device.',
    'Email Notifications': 'Receive notifications via email.',
    'Reminders': 'Get reminded about pending tasks and actions.',
    'Weekly Reports': 'Receive a summary of your activity every week.',
    'App Updates': 'Be notified when new features are available.',
    'Transcription Alerts': 'Get notified when your transcriptions are ready.',
  };
  
  // Time preferences
  String selectedTimeRange = "Anytime";
  final List<String> timeRanges = ["Anytime", "8 AM - 8 PM", "9 AM - 5 PM", "Custom"];
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  
  // Track if there are unsaved changes
  bool haveUnsavedChanges = false;
  bool showConfirmation = false;
  
  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Track expanded categories
  Set<String> _expandedCategories = {'General', 'App', 'Content'};
  
  // Tab controller for notification types
  int _selectedTab = 0;
  final List<String> _tabs = ['All', 'Messages', 'Transcriptions', 'Updates'];
  
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
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
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
  void _updateSetting(String category, String setting, bool value) {
    setState(() {
      _notificationGroups[category]![setting] = value;
      haveUnsavedChanges = true;
    });
  }
  
  // Toggle a category expansion state
  void _toggleCategory(String category) {
    setState(() {
      if (_expandedCategories.contains(category)) {
        _expandedCategories.remove(category);
      } else {
        _expandedCategories.add(category);
      }
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
  
  // Select time
  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
      builder: (BuildContext context, Widget? child) {
        // Use theme provider to style the time picker
        final themeProvider = Provider.of<ThemeProvider>(context);
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: themeProvider.accentColor,
              onPrimary: Colors.white,
              surface: themeProvider.modalBackgroundColor,
              onSurface: themeProvider.primaryTextColor,
            ),
            dialogBackgroundColor: themeProvider.modalBackgroundColor,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
        haveUnsavedChanges = true;
      });
    }
  }
  
  // Check for unsaved changes before navigating back
  Future<bool> _onWillPop() async {
    if (!haveUnsavedChanges) {
      return true;
    }
    
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        
        return AlertDialog(
          title: Text(
            'Unsaved Changes',
            style: themeProvider.headlineMedium,
          ),
          content: Text(
            'You have unsaved notification settings. Do you want to discard these changes?',
            style: themeProvider.bodyMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(themeProvider.borderRadius),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: themeProvider.textButtonStyle,
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('DISCARD'),
            ),
          ],
        );
      },
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
          title: Text(
            'Notifications & Reminders',
            style: themeProvider.settingsHeaderStyle,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: themeProvider.primaryIconColor),
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
              // Warning banner
              Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(themeProvider.borderRadius),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Customize how and when you receive notifications from CAIPO.',
                        style: themeProvider.bodyMedium.copyWith(
                          color: Colors.blue.shade800,
                        ),
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
                    _buildCategoryHeader('General Notifications', isDarkMode, themeProvider),
                    _buildAnimatedSwitchTile(
                      title: 'Push Notifications',
                      description: 'Receive notifications directly to your device.',
                      icon: Icons.notifications_active,
                      value: _notificationGroups['General']!['Push Notifications']!,
                      isDarkMode: isDarkMode,
                      themeProvider: themeProvider,
                      onChanged: (val) => _updateSetting('General', 'Push Notifications', val),
                    ),
                    _buildAnimatedSwitchTile(
                      title: 'Email Notifications',
                      description: 'Receive notifications via email.',
                      icon: Icons.email,
                      value: _notificationGroups['General']!['Email Notifications']!,
                      isDarkMode: isDarkMode,
                      themeProvider: themeProvider,
                      onChanged: (val) => _updateSetting('General', 'Email Notifications', val),
                    ),
                    
                    _buildCategoryHeader('App Notifications', isDarkMode, themeProvider),
                    _buildAnimatedSwitchTile(
                      title: 'Reminders',
                      description: 'Get reminded about pending tasks and actions.',
                      icon: Icons.access_time,
                      value: _notificationGroups['App']!['Reminders']!,
                      isDarkMode: isDarkMode,
                      themeProvider: themeProvider,
                      onChanged: (val) => _updateSetting('App', 'Reminders', val),
                    ),
                    _buildAnimatedSwitchTile(
                      title: 'Weekly Reports',
                      description: 'Receive a summary of your activity every week.',
                      icon: Icons.summarize,
                      value: _notificationGroups['App']!['Weekly Reports']!,
                      isDarkMode: isDarkMode,
                      themeProvider: themeProvider,
                      onChanged: (val) => _updateSetting('App', 'Weekly Reports', val),
                    ),
                    
                    _buildCategoryHeader('Content Notifications', isDarkMode, themeProvider),
                    _buildAnimatedSwitchTile(
                      title: 'App Updates',
                      description: 'Be notified when new features are available.',
                      icon: Icons.system_update,
                      value: _notificationGroups['Content']!['App Updates']!,
                      isDarkMode: isDarkMode,
                      themeProvider: themeProvider,
                      onChanged: (val) => _updateSetting('Content', 'App Updates', val),
                    ),
                    _buildAnimatedSwitchTile(
                      title: 'Transcription Alerts',
                      description: 'Get notified when your transcriptions are ready.',
                      icon: Icons.record_voice_over,
                      value: _notificationGroups['Content']!['Transcription Alerts']!,
                      isDarkMode: isDarkMode,
                      themeProvider: themeProvider,
                      onChanged: (val) => _updateSetting('Content', 'Transcription Alerts', val),
                    ),
                    
                    // Notification time preferences
                    if (_notificationGroups['General']!['Push Notifications']! || _notificationGroups['General']!['Email Notifications']!) ...[
                      _buildCategoryHeader('Notification Time', isDarkMode, themeProvider),
                      _buildTimePreferences(isDarkMode, themeProvider),
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
                decoration: themeProvider.settingsBottomBarDecoration,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Success confirmation
                    AnimatedCrossFade(
                      firstChild: Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Notification settings saved!',
                              style: themeProvider.bodyMedium.copyWith(
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
                    
                    // Action buttons
                    Row(
                      children: [
                        // Reset button
                        TextButton.icon(
                          onPressed: haveUnsavedChanges
                              ? () => _showResetConfirmation(themeProvider)
                              : null,
                          icon: Icon(
                            Icons.refresh,
                            size: 18,
                            color: Colors.red,
                          ),
                          label: Text(
                            'Reset',
                            style: themeProvider.bodyMedium.copyWith(
                              color: Colors.red,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // Save button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: haveUnsavedChanges ? _savePreferences : null,
                            icon: const Icon(Icons.save),
                            label: const Text('Save Preferences'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(themeProvider.borderRadius),
                              ),
                              backgroundColor: themeProvider.accentColor,
                              disabledBackgroundColor: themeProvider.accentColor.withOpacity(0.5),
                              elevation: 0,
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
  
  Widget _buildCategoryHeader(String title, bool isDarkMode, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 12.0),
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: themeProvider.settingsHeaderDecoration,
      child: Row(
        children: [
          Icon(
            _getCategoryIcon(title),
            color: themeProvider.accentColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: themeProvider.settingsHeaderStyle.copyWith(
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'general notifications':
        return Icons.notifications_active_outlined;
      case 'app notifications':
        return Icons.apps_outlined;
      case 'content notifications':
        return Icons.article_outlined;
      case 'notification time':
        return Icons.schedule_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }
  
  Widget _buildAnimatedSwitchTile({
    required String title,
    required String description,
    required IconData icon,
    required bool value,
    required bool isDarkMode,
    required ThemeProvider themeProvider,
    required ValueChanged<bool> onChanged,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            decoration: themeProvider.settingsCardDecoration,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: themeProvider.getSettingsIconDecoration(isActive: value),
                  child: Icon(
                    icon,
                    color: value ? themeProvider.accentColor : themeProvider.secondaryIconColor,
                    size: 24,
                  ),
                ),
                title: Text(
                  title, 
                  style: themeProvider.settingsTitleStyle,
                ),
                subtitle: Text(
                  description, 
                  style: themeProvider.settingsDescriptionStyle,
                ),
                trailing: Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: themeProvider.accentColor,
                  activeTrackColor: themeProvider.accentColor.withOpacity(0.3),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildTimePreferences(bool isDarkMode, ThemeProvider themeProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: isDarkMode ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(themeProvider.borderRadius),
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: themeProvider.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.schedule,
                    color: themeProvider.accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notification Time Preference',
                      style: themeProvider.titleMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      'Choose when you want to receive notifications',
                      style: themeProvider.bodySmall.copyWith(
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Time range options with improved layout
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
                  child: AnimatedContainer(
                    duration: themeProvider.animationDurationShort,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, 
                      vertical: 10
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? themeProvider.accentColor.withOpacity(isDarkMode ? 0.3 : 0.1)
                          : isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected 
                            ? themeProvider.accentColor 
                            : Colors.transparent,
                        width: 1.5,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: themeProvider.accentColor.withOpacity(0.2),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ] : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected)
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: themeProvider.accentColor,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                            ],
                          ),
                        Text(
                          time,
                          style: themeProvider.bodyMedium.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? themeProvider.accentColor
                                : isDarkMode
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            
            // Custom time range selector with improved UI
            if (selectedTimeRange == "Custom") ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? Colors.black.withOpacity(0.2)
                      : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(themeProvider.borderRadius),
                  border: Border.all(
                    color: isDarkMode 
                        ? Colors.grey.shade800 
                        : Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Custom Time Range',
                      style: themeProvider.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(context, true),
                            borderRadius: BorderRadius.circular(8),
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
                                border: Border.all(
                                  color: themeProvider.accentColor.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: themeProvider.accentColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _startTime.format(context),
                                    style: themeProvider.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'to',
                            style: themeProvider.bodyMedium,
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(context, false),
                            borderRadius: BorderRadius.circular(8),
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
                                border: Border.all(
                                  color: themeProvider.accentColor.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: themeProvider.accentColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _endTime.format(context),
                                    style: themeProvider.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Daily schedule options
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildDayChip('Mon', true, isDarkMode, themeProvider),
                        _buildDayChip('Tue', true, isDarkMode, themeProvider),
                        _buildDayChip('Wed', true, isDarkMode, themeProvider),
                        _buildDayChip('Thu', true, isDarkMode, themeProvider),
                        _buildDayChip('Fri', true, isDarkMode, themeProvider),
                        _buildDayChip('Sat', false, isDarkMode, themeProvider),
                        _buildDayChip('Sun', false, isDarkMode, themeProvider),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  // Show help dialog with explanation of notification options
  void _showHelp(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.help_outline,
              color: themeProvider.accentColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Notification Help',
              style: themeProvider.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpItem(
                'Push Notifications',
                'Receive alerts on your device when important events happen, such as completed transcriptions.',
                Icons.notifications_active,
                themeProvider,
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                'Email Notifications',
                'Get emails about your activity, updates, and important information.',
                Icons.email,
                themeProvider,
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                'Notification Time',
                'Control when notifications are sent to avoid disruptions during focused work or sleep hours.',
                Icons.access_time,
                themeProvider,
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                'Weekly Reports',
                'Receive a summary of your activity every week, including usage statistics and suggestions.',
                Icons.summarize,
                themeProvider,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: themeProvider.textButtonStyle,
            child: const Text('Got It'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(themeProvider.borderRadius),
        ),
      ),
    );
  }
  
  Widget _buildHelpItem(String title, String description, IconData icon, ThemeProvider themeProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: themeProvider.accentColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: themeProvider.accentColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: themeProvider.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: themeProvider.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Show confirmation dialog for resetting settings
  void _showResetConfirmation(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reset Settings',
          style: themeProvider.headlineMedium,
        ),
        content: Text(
          'This will reset all notification settings to their default values. Are you sure you want to continue?',
          style: themeProvider.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: themeProvider.textButtonStyle,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(themeProvider.borderRadius),
        ),
      ),
    );
  }
  
  // Reset notification settings to defaults
  void _resetSettings() {
    setState(() {
      // Reset to default values
      _notificationGroups = {
        'General': {
          'Push Notifications': true,
          'Email Notifications': false,
        },
        'App': {
          'Reminders': true,
          'Weekly Reports': false,
        },
        'Content': {
          'App Updates': true,
          'Transcription Alerts': true,
        }
      };
      
      selectedTimeRange = "Anytime";
      _startTime = const TimeOfDay(hour: 9, minute: 0);
      _endTime = const TimeOfDay(hour: 17, minute: 0);
      
      // Mark as having unsaved changes
      haveUnsavedChanges = true;
    });
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings reset to defaults'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  Widget _buildDayChip(String day, bool isActive, bool isDarkMode, ThemeProvider themeProvider) {
    return GestureDetector(
      onTap: () {
        // Would toggle day selection in a real app
        setState(() {
          haveUnsavedChanges = true;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? themeProvider.accentColor.withOpacity(isDarkMode ? 0.3 : 0.1)
              : isDarkMode
                  ? Colors.grey.shade800.withOpacity(0.5)
                  : Colors.grey.shade200.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? themeProvider.accentColor
                : Colors.transparent,
          ),
        ),
        child: Text(
          day,
          style: themeProvider.bodySmall.copyWith(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive
                ? themeProvider.accentColor
                : isDarkMode
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}