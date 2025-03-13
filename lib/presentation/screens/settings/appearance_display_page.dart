import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
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
  String selectedAnimationSpeed = 'Normal';
  double selectedBorderRadius = 12.0;
  double selectedElevation = 1.0;
  bool haveUnsavedChanges = false;

  // Map to track hover states for interactive UI
  final Map<String, bool> _hoverStates = {};

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  // Available options
  final List<String> fontOptions = ['Roboto', 'Montserrat', 'Poppins', 'Open Sans', 'Lato'];
  final Map<String, Color> accentColorOptions = {
    'Blue': Colors.blue,
    'Purple': Colors.purple,
    'Green': Colors.green,
    'Orange': Colors.orange,
    'Pink': Colors.pink,
    'Teal': Colors.teal,
    'Red': Colors.red,
    'Indigo': Colors.indigo,
  };
  
  final List<String> animationSpeedOptions = ['Slow', 'Normal', 'Fast', 'None'];
  
  // For demonstrating animation
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller for demos
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    
    // Get the current theme settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      setState(() {
        usePurpleGradient = themeProvider.usePurpleGradient;
        textScale = themeProvider.textSizeMultiplier;
        selectedFontFamily = themeProvider.fontFamily;
        selectedAccentColor = themeProvider.accentColorName.capitalize();
        useAnimations = themeProvider.useAnimations;
        selectedAnimationSpeed = themeProvider.animationSpeedName.capitalize();
        selectedBorderRadius = themeProvider.borderRadius;
        selectedElevation = themeProvider.getThemeData(true).cardTheme.elevation ?? 1.0;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _savePreferences() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    // Update theme settings
    themeProvider.toggleGradientStyle(usePurpleGradient);
    themeProvider.setTextSizeMultiplier(textScale);
    themeProvider.setFontFamily(selectedFontFamily);
    themeProvider.setAccentColor(selectedAccentColor.toLowerCase());
    themeProvider.setUseAnimations(useAnimations);
    themeProvider.setAnimationSpeed(selectedAnimationSpeed.toLowerCase());
    themeProvider.setBorderRadius(selectedBorderRadius);
    themeProvider.setElevationFactor(selectedElevation);
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Appearance settings saved'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(themeProvider.borderRadius),
        ),
        backgroundColor: Colors.green.shade700,
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          'Appearance & Display',
          style: themeProvider.settingsHeaderStyle,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeProvider.primaryIconColor),
          onPressed: () {
            if (haveUnsavedChanges) {
              _showUnsavedChangesDialog();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
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
                Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Changes to appearance settings will be applied immediately.',
                    style: themeProvider.bodyMedium.copyWith(
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Main content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                Container(
                  constraints: const BoxConstraints(minHeight: 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Theme Section
                      _buildSection(
                        'Theme',
                        [
                          _buildSettingCard(
                            'Dark Mode',
                            'Switch between light and dark theme',
                            Switch(
                              value: isDarkMode,
                              onChanged: (value) {
                                setState(() {
                                  themeProvider.toggleTheme(value);
                                  haveUnsavedChanges = true;
                                });
                              },
                            ),
                            themeProvider,
                          ),
                          _buildSettingCard(
                            'Purple Gradient',
                            'Use purple gradient style throughout the app',
                            Switch(
                              value: usePurpleGradient,
                              onChanged: (value) {
                                setState(() {
                                  usePurpleGradient = value;
                                  haveUnsavedChanges = true;
                                });
                              },
                            ),
                            themeProvider,
                          ),
                          _buildSettingCard(
                            'Accent Color',
                            'Choose your preferred accent color',
                            SizedBox(
                              width: 120,
                              child: DropdownButton<String>(
                                value: selectedAccentColor,
                                isExpanded: true,
                                items: accentColorOptions.keys.map((String color) {
                                  return DropdownMenuItem<String>(
                                    value: color,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: accentColorOptions[color],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(color),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      selectedAccentColor = newValue;
                                      haveUnsavedChanges = true;
                                    });
                                  }
                                },
                              ),
                            ),
                            themeProvider,
                          ),
                        ],
                        themeProvider,
                      ),

                      const SizedBox(height: 16),

                      // Typography Section
                      _buildSection(
                        'Typography',
                        [
                          _buildSettingCard(
                            'Text Size',
                            'Adjust the size of text throughout the app',
                            SizedBox(
                              width: 200,
                              child: Slider(
                                value: textScale,
                                min: 0.8,
                                max: 1.4,
                                divisions: 6,
                                label: '${(textScale * 100).round()}%',
                                onChanged: (value) {
                                  setState(() {
                                    textScale = value;
                                    haveUnsavedChanges = true;
                                  });
                                },
                              ),
                            ),
                            themeProvider,
                          ),
                          _buildSettingCard(
                            'Font Family',
                            'Choose your preferred font family',
                            SizedBox(
                              width: 150,
                              child: DropdownButton<String>(
                                value: selectedFontFamily,
                                isExpanded: true,
                                items: fontOptions.map((String font) {
                                  return DropdownMenuItem<String>(
                                    value: font,
                                    child: Text(
                                      font,
                                      style: TextStyle(fontFamily: font),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      selectedFontFamily = newValue;
                                      haveUnsavedChanges = true;
                                    });
                                  }
                                },
                              ),
                            ),
                            themeProvider,
                          ),
                          _buildTextPreview(isDarkMode, themeProvider),
                        ],
                        themeProvider,
                      ),

                      const SizedBox(height: 16),

                      // Animations Section
                      _buildSection(
                        'Animations',
                        [
                          _buildSettingCard(
                            'Enable Animations',
                            'Show subtle animations throughout the app',
                            Switch(
                              value: useAnimations,
                              onChanged: (value) {
                                setState(() {
                                  useAnimations = value;
                                  haveUnsavedChanges = true;
                                });
                              },
                            ),
                            themeProvider,
                          ),
                          if (useAnimations)
                            _buildSettingCard(
                              'Animation Speed',
                              'Adjust the speed of animations',
                              SizedBox(
                                width: 150,
                                child: DropdownButton<String>(
                                  value: selectedAnimationSpeed,
                                  isExpanded: true,
                                  items: animationSpeedOptions.map((String speed) {
                                    return DropdownMenuItem<String>(
                                      value: speed,
                                      child: Text(speed),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        selectedAnimationSpeed = newValue;
                                        haveUnsavedChanges = true;
                                      });
                                    }
                                  },
                                ),
                              ),
                              themeProvider,
                            ),
                          _buildAnimationPreview(isDarkMode, themeProvider),
                        ],
                        themeProvider,
                      ),

                      const SizedBox(height: 16),

                      // Visual Style Section
                      _buildSection(
                        'Visual Style',
                        [
                          _buildSettingCard(
                            'Corner Roundness',
                            'Adjust the roundness of corners throughout the app',
                            SizedBox(
                              width: 200,
                              child: Slider(
                                value: selectedBorderRadius,
                                min: 0,
                                max: 24,
                                divisions: 12,
                                label: '${selectedBorderRadius.round()}',
                                onChanged: (value) {
                                  setState(() {
                                    selectedBorderRadius = value;
                                    haveUnsavedChanges = true;
                                  });
                                },
                              ),
                            ),
                            themeProvider,
                          ),
                          _buildSettingCard(
                            'Elevation',
                            'Adjust the shadow depth of elements',
                            SizedBox(
                              width: 200,
                              child: Slider(
                                value: selectedElevation,
                                min: 0,
                                max: 2,
                                divisions: 4,
                                label: selectedElevation.toStringAsFixed(1),
                                onChanged: (value) {
                                  setState(() {
                                    selectedElevation = value;
                                    haveUnsavedChanges = true;
                                  });
                                },
                              ),
                            ),
                            themeProvider,
                          ),
                          _buildStyleSettings(isDarkMode, themeProvider),
                        ],
                        themeProvider,
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom action bar
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: themeProvider.settingsBottomBarDecoration,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => _resetSettings(),
                  icon: const Icon(Icons.restore, color: Colors.red),
                  label: Text(
                    'Reset',
                    style: themeProvider.bodyMedium.copyWith(
                      color: Colors.red,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: haveUnsavedChanges ? _savePreferences : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProvider.accentColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: themeProvider.accentColor.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(themeProvider.borderRadius),
                    ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 12.0),
          margin: const EdgeInsets.only(bottom: 8.0),
          decoration: themeProvider.settingsHeaderDecoration,
          child: Row(
            children: [
              Icon(
                _getSectionIcon(title),
                color: themeProvider.accentColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: themeProvider.settingsHeaderStyle,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  IconData _getSectionIcon(String section) {
    switch (section.toLowerCase()) {
      case 'theme':
        return Icons.palette_outlined;
      case 'typography':
        return Icons.text_fields_outlined;
      case 'animations':
        return Icons.animation_outlined;
      case 'visual style':
        return Icons.style_outlined;
      default:
        return Icons.settings_outlined;
    }
  }

  Widget _buildThemeTab(bool isDarkMode, ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Theme Mode', themeProvider),
          _buildThemeModeSelector(isDarkMode, themeProvider),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Color Scheme', themeProvider),
          _buildColorSchemeSelector(isDarkMode, themeProvider),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Accent Color', themeProvider),
          _buildAccentColorSelector(isDarkMode, themeProvider),
          
          const SizedBox(height: 24),
          _buildPreviewCard(isDarkMode, themeProvider),
        ],
      ),
    );
  }

  Widget _buildTextTab(bool isDarkMode, ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Text Size', themeProvider),
          _buildTextSizeSlider(isDarkMode, themeProvider),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Font Family', themeProvider),
          _buildFontFamilySelector(isDarkMode, themeProvider),
          
          const SizedBox(height: 24),
          _buildTextPreview(isDarkMode, themeProvider),
        ],
      ),
    );
  }
  
  Widget _buildEffectsTab(bool isDarkMode, ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Animations', themeProvider),
          _buildSwitchTile(
            title: 'Enable Animations',
            description: 'Show subtle animations throughout the app',
            icon: Icons.animation,
            value: useAnimations,
            isDarkMode: isDarkMode,
            themeProvider: themeProvider,
            onChanged: (val) {
              setState(() {
                useAnimations = val;
                haveUnsavedChanges = true;
              });
            },
          ),
          
          const SizedBox(height: 16),
          if (useAnimations)
            _buildAnimationSpeedSelector(isDarkMode, themeProvider),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Visual Style', themeProvider),
          _buildStyleSettings(isDarkMode, themeProvider),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Preview', themeProvider),
          _buildAnimationPreview(isDarkMode, themeProvider),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeProvider themeProvider) {
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

  Widget _buildColorSchemeSelector(bool isDarkMode, ThemeProvider themeProvider) {
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

  Widget _buildAccentColorSelector(bool isDarkMode, ThemeProvider themeProvider) {
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

  Widget _buildTextSizeSlider(bool isDarkMode, ThemeProvider themeProvider) {
    return Card(
      elevation: isDarkMode ? 1 : 2,
      color: isDarkMode 
          ? Colors.black26
          : Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(themeProvider.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Text Size',
                  style: themeProvider.titleMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: themeProvider.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(themeProvider.borderRadius / 2),
                    border: Border.all(
                      color: themeProvider.accentColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '${(textScale * 100).toInt()}%',
                    style: themeProvider.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: themeProvider.accentColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('A', style: themeProvider.bodyMedium),
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
                    activeColor: themeProvider.accentColor,
                  ),
                ),
                Text('A', style: themeProvider.bodyMedium.copyWith(fontSize: 22)),
              ],
            ),
            
            // Sample text at different scales
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black12 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(themeProvider.borderRadius / 2),
                border: Border.all(
                  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sample text at ${(textScale * 100).toInt()}% scale',
                    style: themeProvider.bodySmall.copyWith(
                      color: themeProvider.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The quick brown fox jumps over the lazy dog.',
                    style: themeProvider.bodyLarge.copyWith(
                      fontSize: themeProvider.bodyLarge.fontSize! * textScale,
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

  Widget _buildFontFamilySelector(bool isDarkMode, ThemeProvider themeProvider) {
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
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(bool isDarkMode, ThemeProvider themeProvider) {
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

  Widget _buildTextPreview(bool isDarkMode, ThemeProvider themeProvider) {
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

  Widget _buildAnimationPreview(bool isDarkMode, ThemeProvider themeProvider) {
    return Card(
      elevation: isDarkMode ? 1 : 2,
      color: isDarkMode 
          ? Colors.black26
          : Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(themeProvider.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live Preview',
              style: themeProvider.titleMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Demonstrate animation effect
                    setState(() {
                      _isAnimating = true;
                    });
                    
                    // Start the animation
                    _animationController.reset();
                    _animationController.forward();
                    
                    // Stop the animation after it's done
                    Future.delayed(const Duration(milliseconds: 800), () {
                      if (mounted) {
                        setState(() {
                          _isAnimating = false;
                        });
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColorOptions[selectedAccentColor],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(selectedBorderRadius),
                    ),
                    elevation: selectedElevation * 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.play_arrow),
                      const SizedBox(width: 8),
                      Text(
                        'Preview Effect',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: selectedFontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black12 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(themeProvider.borderRadius),
                border: Border.all(
                  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                ),
              ),
              child: Center(
                child: ScaleTransition(
                  scale: _isAnimating ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
                  child: FadeTransition(
                    opacity: _isAnimating ? _fadeAnimation : const AlwaysStoppedAnimation(1.0),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: accentColorOptions[selectedAccentColor],
                        borderRadius: BorderRadius.circular(selectedBorderRadius),
                        boxShadow: [
                          BoxShadow(
                            color: accentColorOptions[selectedAccentColor]!.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.animation,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (!useAnimations) ...[
              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(themeProvider.borderRadius / 2),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'Animations are disabled',
                    style: themeProvider.bodyMedium.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
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
    required ThemeProvider themeProvider,
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

  Widget _buildAnimationSpeedSelector(bool isDarkMode, ThemeProvider themeProvider) {
    return Card(
      elevation: isDarkMode ? 1 : 2,
      color: isDarkMode 
          ? Colors.black26
          : Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(themeProvider.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Animation Speed',
              style: themeProvider.titleMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ...animationSpeedOptions.map((speed) {
                  // Track hover state
                  final hoverKey = 'speed_$speed';
                  final isHovering = _hoverStates[hoverKey] ?? false;
                  final isSelected = selectedAnimationSpeed == speed;
                  
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: MouseRegion(
                        onEnter: (_) => setState(() => _hoverStates[hoverKey] = true),
                        onExit: (_) => setState(() => _hoverStates[hoverKey] = false),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedAnimationSpeed = speed;
                              haveUnsavedChanges = true;
                            });
                          },
                          child: AnimatedContainer(
                            duration: themeProvider.animationDurationShort,
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? themeProvider.accentColor.withOpacity(0.2)
                                  : isHovering
                                      ? isDarkMode
                                          ? Colors.grey.shade800.withOpacity(0.5)
                                          : Colors.grey.shade200.withOpacity(0.8)
                                      : isDarkMode
                                          ? Colors.grey.shade800.withOpacity(0.3)
                                          : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(themeProvider.borderRadius / 2),
                              border: Border.all(
                                color: isSelected
                                    ? themeProvider.accentColor
                                    : isHovering
                                        ? themeProvider.accentColor.withOpacity(0.3)
                                        : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    speed == 'Slow' ? Icons.timelapse 
                                    : speed == 'Normal' ? Icons.speed
                                    : speed == 'Fast' ? Icons.flash_on
                                    : Icons.block,
                                    color: isSelected
                                        ? themeProvider.accentColor
                                        : themeProvider.secondaryIconColor,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    speed,
                                    style: themeProvider.bodyMedium.copyWith(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected
                                          ? themeProvider.accentColor
                                          : themeProvider.secondaryTextColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStyleSettings(bool isDarkMode, ThemeProvider themeProvider) {
    return Card(
      elevation: isDarkMode ? 1 : 2,
      color: isDarkMode 
          ? Colors.black26
          : Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(themeProvider.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Corner roundness
            Text(
              'Corner Roundness',
              style: themeProvider.titleMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: themeProvider.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(selectedBorderRadius / 3),
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: selectedBorderRadius,
                    min: 0,
                    max: 24,
                    divisions: 12,
                    label: "${selectedBorderRadius.toInt()}",
                    onChanged: (value) {
                      setState(() {
                        selectedBorderRadius = value;
                        haveUnsavedChanges = true;
                      });
                    },
                    activeColor: themeProvider.accentColor,
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: themeProvider.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(selectedBorderRadius),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Elevation
            Text(
              'Elevation',
              style: themeProvider.titleMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.filter_none,
                  color: themeProvider.secondaryIconColor,
                  size: 20,
                ),
                Expanded(
                  child: Slider(
                    value: selectedElevation,
                    min: 0,
                    max: 2,
                    divisions: 4,
                    label: "$selectedElevation",
                    onChanged: (value) {
                      setState(() {
                        selectedElevation = value;
                        haveUnsavedChanges = true;
                      });
                    },
                    activeColor: themeProvider.accentColor,
                  ),
                ),
                Icon(
                  Icons.layers,
                  color: themeProvider.secondaryIconColor,
                  size: 20,
                ),
              ],
            ),
            
            // Preview of different corner and elevation settings
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode 
                    ? Colors.black12
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(themeProvider.borderRadius),
                border: Border.all(
                  color: isDarkMode 
                      ? Colors.grey.shade800 
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStylePreview(
                    label: 'Card',
                    borderRadius: selectedBorderRadius,
                    elevation: selectedElevation,
                    isDarkMode: isDarkMode,
                    themeProvider: themeProvider,
                  ),
                  _buildStylePreview(
                    label: 'Button',
                    borderRadius: selectedBorderRadius,
                    elevation: selectedElevation,
                    isDarkMode: isDarkMode,
                    themeProvider: themeProvider,
                    isButton: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStylePreview({
    required String label,
    required double borderRadius,
    required double elevation,
    required bool isDarkMode,
    required ThemeProvider themeProvider,
    bool isButton = false,
  }) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 60,
          decoration: BoxDecoration(
            color: isButton 
                ? accentColorOptions[selectedAccentColor]
                : isDarkMode
                    ? Colors.grey.shade900
                    : Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1 * elevation),
                blurRadius: 8 * elevation,
                spreadRadius: 1 * elevation,
                offset: Offset(0, 2 * elevation),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: themeProvider.bodyMedium.copyWith(
                color: isButton ? Colors.white : themeProvider.primaryTextColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${borderRadius.toInt()}px / ${elevation.toStringAsFixed(1)}',
          style: themeProvider.bodySmall.copyWith(
            color: themeProvider.secondaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: themeProvider.textButtonStyle,
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: haveUnsavedChanges ? _savePreferences : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(themeProvider.borderRadius),
                ),
                backgroundColor: themeProvider.accentColor,
                disabledBackgroundColor: themeProvider.accentColor.withOpacity(0.5),
              ),
              child: Text(
                'Save Preferences',
                style: themeProvider.titleMedium.copyWith(
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

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Settings'),
          content: const Text(
            'Are you sure you want to reset all appearance settings to their defaults?'
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
                  textScale = 1.0;
                  usePurpleGradient = true;
                  selectedFontFamily = 'Roboto';
                  selectedAccentColor = 'Blue';
                  useAnimations = true;
                  selectedAnimationSpeed = 'Normal';
                  selectedBorderRadius = 12.0;
                  selectedElevation = 1.0;
                  haveUnsavedChanges = true;
                });
              },
              child: const Text('RESET'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingCard(
    String title,
    String subtitle,
    Widget trailing,
    ThemeProvider themeProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: themeProvider.settingsCardDecoration,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: themeProvider.getSettingsIconDecoration(
                  isActive: title.toLowerCase().contains('dark') 
                      ? Theme.of(context).brightness == Brightness.dark 
                      : true
                ),
                child: Icon(
                  _getSettingIcon(title),
                  color: themeProvider.accentColor,
                  size: 24,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: themeProvider.settingsTitleStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: themeProvider.settingsDescriptionStyle,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: trailing,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSettingIcon(String setting) {
    switch (setting.toLowerCase()) {
      case 'dark mode':
        return Icons.dark_mode_outlined;
      case 'purple gradient':
        return Icons.gradient;
      case 'text size':
        return Icons.format_size;
      case 'font family':
        return Icons.font_download_outlined;
      default:
        return Icons.settings;
    }
  }
}

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}