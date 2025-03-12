import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/theme_provider.dart';
import '../profile/account_profile_page.dart';
import '../ai/ai_preferences_page.dart';
import '/notifications_page.dart';
import 'privacy_data_page.dart';
import 'appearance_display_page.dart';
import 'advanced_settings_page.dart';
import '../support/about_support_page.dart';
import '../../widgets/gradient_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  
  // For animation of list items
  final List<Animation<double>> _itemAnimations = [];
  
  // Keep track of recently accessed settings
  final List<String> _recentSettings = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController, 
      curve: Curves.easeIn
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _addToRecent(String title) {
    // Add to recent if not already there
    if (!_recentSettings.contains(title)) {
      setState(() {
        _recentSettings.insert(0, title);
        if (_recentSettings.length > 3) {
          _recentSettings.removeLast();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    final List<Map<String, dynamic>> settingsOptions = [
      {'title': 'Account & Profile', 'icon': Icons.person, 'page': const AccountProfilePage(), 'description': 'Manage your personal information'},
      {'title': 'AI Preferences', 'icon': Icons.smart_toy, 'page': const AIPreferencesPage(), 'description': 'Customize how CAIPO interacts with you'},
      {'title': 'Notifications & Reminders', 'icon': Icons.notifications, 'page': const NotificationsPage(), 'description': 'Control alerts and reminders'},
      {'title': 'Privacy & Data', 'icon': Icons.shield, 'page': const PrivacyDataPage(), 'description': 'Manage data sharing and privacy options'},
      {'title': 'Appearance & Display', 'icon': Icons.palette, 'page': const AppearanceDisplayPage(), 'description': 'Customize your app appearance'},
      {'title': 'Advanced Settings', 'icon': Icons.build, 'page': const AdvancedSettingsPage(), 'description': 'Developer options and advanced features'},
      {'title': 'About & Support', 'icon': Icons.help_outline, 'page': const AboutSupportPage(), 'description': 'Get help and learn about CAIPO'},
      {
        'title': 'Theme',
        'icon': isDarkMode ? Icons.dark_mode : Icons.light_mode,
        'description': isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
        'widget': Switch(
          value: themeProvider.themeMode == ThemeMode.dark,
          activeColor: Colors.blueAccent,
          onChanged: (value) {
            setState(() {
              themeProvider.toggleTheme(value);
            });
          },
        ),
      },
    ];

    // Initialize animations for each list item if needed
    if (_itemAnimations.isEmpty && settingsOptions.isNotEmpty) {
      for (int i = 0; i < settingsOptions.length; i++) {
        _itemAnimations.add(
          Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                0.1 + (i * 0.05),  // Staggered start
                1.0,
                curve: Curves.easeOut,
              ),
            ),
          ),
        );
      }
    }

    // Filter options based on search query
    final filteredOptions = _searchQuery.isEmpty
        ? settingsOptions
        : settingsOptions.where((option) =>
            option['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (option['description'] != null && 
             option['description'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
          ).toList();

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
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
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: isDarkMode 
            ? Colors.black26 
            : const Color(0xFF2196F3).withOpacity(0.8),
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Search settings...',
                  hintStyle: TextStyle(
                    color: isDarkMode 
                        ? Colors.grey.shade400 
                        : Colors.grey.shade600,
                  ),
                  filled: true,
                  fillColor: isDarkMode 
                      ? Colors.black.withAlpha(77)
                      : Colors.grey.shade200,
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDarkMode 
                        ? Colors.grey.shade400 
                        : Colors.grey.shade600,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: isDarkMode 
                                ? Colors.grey.shade400 
                                : Colors.grey.shade600,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                            FocusScope.of(context).unfocus();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDarkMode 
                          ? Colors.grey.shade800 
                          : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.blueAccent.withAlpha(isDarkMode ? 179 : 255),
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
            ),
            
            // Recently accessed settings
            if (_recentSettings.isNotEmpty && _searchQuery.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 8.0, bottom: 12.0),
                child: Text(
                  'Recently Accessed',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  scrollDirection: Axis.horizontal,
                  itemCount: _recentSettings.length,
                  itemBuilder: (context, index) {
                    final recentTitle = _recentSettings[index];
                    final recentOption = settingsOptions.firstWhere(
                      (option) => option['title'] == recentTitle,
                      orElse: () => {'title': recentTitle},
                    );
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        avatar: recentOption['icon'] != null
                            ? Icon(
                                recentOption['icon'],
                                size: 16,
                                color: isDarkMode ? Colors.white70 : Colors.black54,
                              )
                            : null,
                        label: Text(recentTitle),
                        backgroundColor: isDarkMode
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        labelStyle: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        onPressed: () {
                          if (recentOption['page'] != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => recentOption['page'],
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Settings category header - only show if not searching
            if (_searchQuery.isEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 8.0, bottom: 12.0),
                child: Text(
                  'All Settings',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
              ),
            
            // No results message
            if (filteredOptions.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No settings found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try a different search term',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Settings list
            if (filteredOptions.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: filteredOptions.length,
                  itemBuilder: (context, index) {
                    final option = filteredOptions[index];
                    
                    return FadeTransition(
                      opacity: _itemAnimations.length > index
                          ? _itemAnimations[index]
                          : const AlwaysStoppedAnimation(1.0),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(
                          _itemAnimations.length > index
                              ? _itemAnimations[index]
                              : const AlwaysStoppedAnimation(1.0),
                        ),
                        child: _buildSettingCard(
                          option,
                          isDarkMode,
                          onTap: () {
                            if (option['page'] != null) {
                              _addToRecent(option['title']);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => option['page'],
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSettingCard(Map<String, dynamic> option, bool isDarkMode, {required VoidCallback onTap}) {
    return Semantics(
      button: true,
      label: 'Settings option for ${option['title']}',
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: isDarkMode ? 0 : 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: isDarkMode 
            ? Colors.black.withOpacity(0.3) 
            : Colors.white.withOpacity(0.9),
        child: InkWell(
          onTap: option['page'] != null ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.blueAccent.withOpacity(0.1),
          highlightColor: Colors.blueAccent.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Icon with background
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDarkMode 
                        ? Colors.blueAccent.withOpacity(0.2) 
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    option['icon'] ?? Icons.settings,
                    size: 24,
                    color: isDarkMode ? Colors.blueAccent : Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                // Title and description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option['title'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (option['description'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          option['description'],
                          style: TextStyle(
                            fontSize: 13,
                            color: isDarkMode 
                                ? Colors.grey.shade400 
                                : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Action (switch or arrow)
                option.containsKey('widget')
                    ? option['widget']
                    : Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: isDarkMode 
                            ? Colors.grey.shade600 
                            : Colors.grey.shade400,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}