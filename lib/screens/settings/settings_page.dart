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
  String _searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeInAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    final List<Map<String, dynamic>> settingsOptions = [
      {'title': 'Account & Profile', 'icon': Icons.person, 'page': const AccountProfilePage()},
      {'title': 'AI Preferences', 'icon': Icons.smart_toy, 'page': const AIPreferencesPage()},
      {'title': 'Notifications & Reminders', 'icon': Icons.notifications, 'page': const NotificationsPage()},
      {'title': 'Privacy & Data', 'icon': Icons.lock, 'page': const PrivacyDataPage()},
      {'title': 'Appearance & Display', 'icon': Icons.format_paint, 'page': const AppearanceDisplayPage()},
      {'title': 'Advanced Settings', 'icon': Icons.settings, 'page': const AdvancedSettingsPage()},
      {'title': 'About & Support', 'icon': Icons.help, 'page': const AboutSupportPage()},
      {
        'title': 'Dark Mode',
        'icon': Icons.dark_mode,
        'widget': Switch(
          value: themeProvider.themeMode == ThemeMode.dark,
          onChanged: (value) {
            setState(() {
              themeProvider.toggleTheme(value);
            });
          },
        ),
      },
    ];

    final filteredOptions = settingsOptions.where((option) =>
        option['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          'Settings', 
          style: TextStyle(
            fontSize: 22, 
            fontWeight: FontWeight.w600, 
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back, 
            size: 26, 
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
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
                      ? Colors.black.withAlpha(77) // 0.3 * 255 ≈ 77
                      : Colors.grey.shade200,
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDarkMode 
                        ? Colors.grey.shade400 
                        : Colors.grey.shade600,
                  ),
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
                      color: Colors.blueAccent.withAlpha(isDarkMode ? 179 : 255), // 0.7 or 1.0 * 255
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredOptions.length,
                itemBuilder: (context, index) {
                  final option = filteredOptions[index];
                  return Semantics(
                    button: true,
                    label: 'Settings option for ${option['title']}',
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12, 
                        vertical: 6
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      ),
                      color: isDarkMode 
                          ? Colors.black.withAlpha(77) // 0.3 * 255 ≈ 77
                          : Colors.white,
                      elevation: isDarkMode ? 0 : 1,
                      child: ListTile(
                        leading: Icon(
                          option['icon'],
                          size: 28,
                          color: isDarkMode 
                              ? Colors.blueAccent.shade100 
                              : Colors.blueAccent,
                        ),
                        title: Text(
                          option['title'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode 
                                ? Colors.white 
                                : Colors.black87,
                          ),
                        ),
                        trailing: option.containsKey('widget')
                            ? option['widget']
                            : Icon(
                                Icons.arrow_forward_ios,
                                size: 18,
                                color: isDarkMode 
                                    ? Colors.grey.shade400 
                                    : Colors.grey.shade600,
                              ),
                        onTap: option['page'] != null
                            ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => option['page']
                                  ),
                                )
                            : null,
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
}