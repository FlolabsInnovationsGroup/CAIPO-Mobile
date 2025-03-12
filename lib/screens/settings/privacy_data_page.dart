import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';
import '../../widgets/gradient_scaffold.dart';

class PrivacyDataPage extends StatefulWidget {
  const PrivacyDataPage({super.key});

  @override
  _PrivacyDataPageState createState() => _PrivacyDataPageState();
}

class _PrivacyDataPageState extends State<PrivacyDataPage> with SingleTickerProviderStateMixin {
  bool dataSharing = false;
  bool personalizedAds = true;
  bool locationAccess = false;
  bool biometricData = false;
  bool usageAnalytics = true;
  bool haveUnsavedChanges = false;
  bool showConfirmation = false;
  
  // For animations
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
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  // Track changes and update save button state
  void _updateSetting(String setting, bool value) {
    setState(() {
      switch (setting) {
        case 'dataSharing':
          dataSharing = value;
          break;
        case 'personalizedAds':
          personalizedAds = value;
          break;
        case 'locationAccess':
          locationAccess = value;
          break;
        case 'biometricData':
          biometricData = value;
          break;
        case 'usageAnalytics':
          usageAnalytics = value;
          break;
      }
      haveUnsavedChanges = true;
    });
  }
  
  // Handle save preferences
  void _savePreferences() {
    // Here you would typically save to SharedPreferences or backend
    setState(() {
      haveUnsavedChanges = false;
      showConfirmation = true;
    });
    
    // Hide confirmation after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showConfirmation = false;
        });
      }
    });
  }
  
  // Prompt user before leaving if there are unsaved changes
  Future<bool> _onWillPop() async {
    if (!haveUnsavedChanges) {
      return true;
    }
    
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved privacy changes. Do you want to discard these changes?'
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
            'Privacy & Data',
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
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Privacy Information'),
                    content: const SingleChildScrollView(
                      child: Text(
                        'Your privacy is important to us. These settings control how your data is used within the app and whether it\'s shared with our services to improve your experience.\n\n'
                        'Data Sharing: Enables anonymous usage data to be shared with our team to improve the app.\n\n'
                        'Personalized Ads: Allows us to show you more relevant advertisements based on your interests.\n\n'
                        'Location Access: Provides more accurate location-based recommendations and services.\n\n'
                        'Biometric Data: Used for secure authentication features.\n\n'
                        'Usage Analytics: Helps us understand how you use the app to make it better.\n\n'
                        'You can change these settings at any time.'
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('CLOSE'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manage Your Data Preferences',
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Control how your data is used and shared with our services.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white70 : Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Privacy settings section
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    _buildCategoryHeader('Data Collection', isDarkMode),
                    _buildAnimatedSwitchTile(
                      title: 'Allow Data Sharing',
                      description: 'Share anonymous data to improve services.',
                      icon: Icons.share,
                      value: dataSharing,
                      isDarkMode: isDarkMode,
                      onChanged: (val) => _updateSetting('dataSharing', val),
                    ),
                    _buildAnimatedSwitchTile(
                      title: 'Usage Analytics',
                      description: 'Collect data on how you use the app to improve features.',
                      icon: Icons.analytics,
                      value: usageAnalytics,
                      isDarkMode: isDarkMode,
                      onChanged: (val) => _updateSetting('usageAnalytics', val),
                    ),
                    
                    _buildCategoryHeader('Permissions', isDarkMode),
                    _buildAnimatedSwitchTile(
                      title: 'Location Access',
                      description: 'Allow access to your location for better recommendations.',
                      icon: Icons.location_on,
                      value: locationAccess,
                      isDarkMode: isDarkMode,
                      onChanged: (val) => _updateSetting('locationAccess', val),
                    ),
                    _buildAnimatedSwitchTile(
                      title: 'Biometric Data',
                      description: 'Allow access to biometric data for authentication.',
                      icon: Icons.fingerprint,
                      value: biometricData,
                      isDarkMode: isDarkMode,
                      onChanged: (val) => _updateSetting('biometricData', val),
                    ),
                    
                    _buildCategoryHeader('Advertising', isDarkMode),
                    _buildAnimatedSwitchTile(
                      title: 'Personalized Ads',
                      description: 'Receive ads based on your preferences and usage patterns.',
                      icon: Icons.ads_click,
                      value: personalizedAds,
                      isDarkMode: isDarkMode,
                      onChanged: (val) => _updateSetting('personalizedAds', val),
                    ),
                    
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Changes to these settings will be applied when you save your preferences. '
                        'For more information, please check our Privacy Policy.',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade200,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              
              // Bottom section with save button
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
                    // Confirmation message
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
                              'Privacy settings saved successfully!',
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
                              padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 24
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)
                              ),
                              backgroundColor: Colors.blueAccent,
                            ),
                            child: Text(
                              'Save Preferences',
                              style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold, 
                                color: Colors.white.withOpacity(
                                  haveUnsavedChanges ? 1.0 : 0.7
                                ),
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
}