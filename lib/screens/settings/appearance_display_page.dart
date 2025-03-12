import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';
import '../../widgets/gradient_scaffold.dart';

class AppearanceDisplayPage extends StatefulWidget {
  const AppearanceDisplayPage({super.key});

  @override
  _AppearanceDisplayPageState createState() => _AppearanceDisplayPageState();
}

class _AppearanceDisplayPageState extends State<AppearanceDisplayPage> with SingleTickerProviderStateMixin {
  double textScale = 1.0;
  bool usePurpleGradient = true;
  String selectedFontFamily = 'Roboto';
  String selectedAccentColor = 'Blue';
  bool useAnimations = true;
  bool haveUnsavedChanges = false;

  // Animation controller
  late TabController _tabController;

  // Available options
  final List<String> fontOptions = ['Roboto', 'Montserrat', 'Poppins', 'Open Sans', 'Lato'];
  final Map<String, Color> accentColorOptions = {
    'Blue': Colors.blue,
    'Purple': Colors.purple,
    'Green': Colors.green,
    'Orange': Colors.orange,
    'Pink': Colors.pink,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Get the current theme settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      setState(() {
        usePurpleGradient = themeProvider.usePurpleGradient;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _savePreferences() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    // Update theme settings
    themeProvider.toggleGradientStyle(usePurpleGradient);
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Appearance settings saved'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.green.shade700,
      ),
    );
    
    setState(() {
      haveUnsavedChanges = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          'Appearance & Display',
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
          onPressed: () {
            if (haveUnsavedChanges) {
              _showUnsavedChangesDialog();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        backgroundColor: isDarkMode 
            ? Colors.black26 
            : const Color(0xFF2196F3).withOpacity(0.8),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          tabs: const [
            Tab(text: 'Theme'),
            Tab(text: 'Text'),
            Tab(text: 'Effects'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildThemeTab(isDarkMode, themeProvider),
          _buildTextTab(isDarkMode),
          _buildEffectsTab(isDarkMode),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildThemeTab(bool isDarkMode, ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Theme Mode'),
          _buildThemeModeSelector(isDarkMode, themeProvider),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Color Scheme'),
          _buildColorSchemeSelector(isDarkMode),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Accent Color'),
          _buildAccentColorSelector(isDarkMode),
          
          const SizedBox(height: 24),
          _buildPreviewCard(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildTextTab(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Text Size'),
          _buildTextSizeSlider(isDarkMode),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Font Family'),
          _buildFontFamilySelector(isDarkMode),
          
          const SizedBox(height: 24),
          _buildTextPreview(isDarkMode),
        ],
      ),
    );
  }
  
  Widget _buildEffectsTab(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Animations'),
          _buildSwitchTile(
            title: 'Enable Animations',
            description: 'Show subtle animations throughout the app',
            icon: Icons.animation,
            value: useAnimations,
            isDarkMode: isDarkMode,
            onChanged: (val) {
              setState(() {
                useAnimations = val;
                haveUnsavedChanges = true;
              });
            },
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Interaction Preview'),
          _buildAnimationPreview(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.white 
              : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildThemeModeSelector(bool isDarkMode, ThemeProvider themeProvider) {
    return Card(
      elevation: isDarkMode ? 0 : 2,
      color: isDarkMode 
          ? Colors.black.withOpacity(0.3) 
          : Colors.white.withOpacity(0.8),
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
                  'Dark Mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Switch(
                  value: isDarkMode,
                  onChanged: (val) {
                    themeProvider.toggleTheme(val);
                    setState(() {
                      haveUnsavedChanges = true;
                    });
                  },
                  activeColor: Colors.blueAccent,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildThemeModeOption(
                    label: 'Light',
                    icon: Icons.light_mode,
                    isSelected: !isDarkMode,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      themeProvider.toggleTheme(false);
                      setState(() {
                        haveUnsavedChanges = true;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildThemeModeOption(
                    label: 'Dark',
                    icon: Icons.dark_mode,
                    isSelected: isDarkMode,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      themeProvider.toggleTheme(true);
                      setState(() {
                        haveUnsavedChanges = true;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModeOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blueAccent.withOpacity(0.2)
              : isDarkMode
                  ? Colors.grey.shade800.withOpacity(0.3)
                  : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.blueAccent
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: isSelected
                  ? Colors.blueAccent
                  : isDarkMode
                      ? Colors.grey.shade400
                      : Colors.grey.shade700,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Colors.blueAccent
                    : isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSchemeSelector(bool isDarkMode) {
    return Card(
      elevation: isDarkMode ? 0 : 2,
      color: isDarkMode 
          ? Colors.black.withOpacity(0.3) 
          : Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildGradientOption(
                    label: 'Purple',
                    colors: const [Color(0xFF6200EA), Color(0xFF3700B3)],
                    isSelected: usePurpleGradient,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      setState(() {
                        usePurpleGradient = true;
                        haveUnsavedChanges = true;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGradientOption(
                    label: 'Blue',
                    colors: const [Color(0xFF003545), Color(0xFF001E2E)],
                    isSelected: !usePurpleGradient,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      setState(() {
                        usePurpleGradient = false;
                        haveUnsavedChanges = true;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientOption({
    required String label,
    required List<Color> colors,
    required bool isSelected,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccentColorSelector(bool isDarkMode) {
    return Card(
      elevation: isDarkMode ? 0 : 2,
      color: isDarkMode 
          ? Colors.black.withOpacity(0.3) 
          : Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: accentColorOptions.entries.map((entry) {
            return _buildColorOption(
              color: entry.value,
              label: entry.key,
              isSelected: selectedAccentColor == entry.key,
              isDarkMode: isDarkMode,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildColorOption({
    required Color color,
    required String label,
    required bool isSelected,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAccentColor = label;
          haveUnsavedChanges = true;
        });
      },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Colors.white
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSizeSlider(bool isDarkMode) {
    return Card(
      elevation: isDarkMode ? 0 : 2,
      color: isDarkMode 
          ? Colors.black.withOpacity(0.3) 
          : Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Text Size',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${(textScale * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('A', style: TextStyle(fontSize: 14)),
                Expanded(
                  child: Slider(
                    value: textScale,
                    min: 0.8,
                    max: 1.5,
                    divisions: 7,
                    label: "${(textScale * 100).toInt()}%",
                    onChanged: (value) {
                      setState(() {
                        textScale = value;
                        haveUnsavedChanges = true;
                      });
                    },
                    activeColor: Colors.blueAccent,
                  ),
                ),
                const Text('A', style: TextStyle(fontSize: 22)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontFamilySelector(bool isDarkMode) {
    return Card(
      elevation: isDarkMode ? 0 : 2,
      color: isDarkMode 
          ? Colors.black.withOpacity(0.3) 
          : Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Font Family',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ...fontOptions.map((font) {
              return RadioListTile(
                title: Text(
                  font,
                  style: TextStyle(
                    fontFamily: font,
                    fontSize: 16,
                  ),
                ),
                value: font,
                groupValue: selectedFontFamily,
                onChanged: (value) {
                  setState(() {
                    selectedFontFamily = value.toString();
                    haveUnsavedChanges = true;
                  });
                },
                activeColor: Colors.blueAccent,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                dense: true,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(bool isDarkMode) {
    return Card(
      elevation: isDarkMode ? 0 : 2,
      color: isDarkMode 
          ? Colors.black.withOpacity(0.3) 
          : Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 150,
              decoration: BoxDecoration(
                gradient: usePurpleGradient
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF6200EA), Color(0xFF3700B3)],
                      )
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF003545), Color(0xFF001E2E)],
                      ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.color_lens,
                      size: 40,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Theme Preview',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextPreview(bool isDarkMode) {
    return Card(
      elevation: isDarkMode ? 0 : 2,
      color: isDarkMode 
          ? Colors.black.withOpacity(0.3) 
          : Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Text Preview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isDarkMode 
                    ? Colors.grey.shade900 
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Heading Text',
                    style: TextStyle(
                      fontSize: 20 * textScale,
                      fontWeight: FontWeight.bold,
                      fontFamily: selectedFontFamily,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Subheading would appear like this in your app',
                    style: TextStyle(
                      fontSize: 16 * textScale,
                      fontWeight: FontWeight.w500,
                      fontFamily: selectedFontFamily,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This is how normal body text will appear throughout the app. It should be easy to read and comfortable for your eyes.',
                    style: TextStyle(
                      fontSize: 14 * textScale,
                      fontFamily: selectedFontFamily,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationPreview(bool isDarkMode) {
    return Card(
      elevation: isDarkMode ? 0 : 2,
      color: isDarkMode 
          ? Colors.black.withOpacity(0.3) 
          : Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Animation Preview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Demonstrate animation effect
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        useAnimations
                            ? 'Animations are enabled'
                            : 'Animations are disabled',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColorOptions[selectedAccentColor],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Preview Effect',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String description,
    required IconData icon,
    required bool value,
    required bool isDarkMode,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: isDarkMode ? 0 : 2,
      color: isDarkMode 
          ? Colors.black.withOpacity(0.3) 
          : Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: value 
                    ? Colors.blueAccent.withOpacity(0.2)
                    : isDarkMode 
                        ? Colors.grey.shade800 
                        : Colors.grey.shade200,
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
                    ),
                  ),
                  Text(
                    description, 
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
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
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: haveUnsavedChanges ? _savePreferences : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
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

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
            'You have unsaved appearance changes. Would you like to save them before leaving?',
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