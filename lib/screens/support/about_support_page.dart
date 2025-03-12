import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';
import '../../widgets/gradient_scaffold.dart';

class AboutSupportPage extends StatelessWidget {
  const AboutSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          'About & Support',
          style: themeProvider.settingsHeaderStyle,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeProvider.primaryIconColor),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAboutSection(themeProvider),
            const SizedBox(height: 20),
            _buildFAQSection(themeProvider),
            const SizedBox(height: 20),
            _buildSupportButton(themeProvider),
            const SizedBox(height: 24),
            _buildVersionInfo(themeProvider),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAboutSection(ThemeProvider themeProvider) {
    return Container(
      decoration: themeProvider.settingsCardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: themeProvider.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(themeProvider.borderRadius),
                border: Border.all(
                  color: themeProvider.accentColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: themeProvider.getSettingsIconDecoration(isActive: true),
                    child: Icon(
                      Icons.smart_toy_outlined,
                      color: themeProvider.accentColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CAIPO Assistant',
                          style: themeProvider.settingsTitleStyle.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.accentColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your AI-powered companion',
                          style: themeProvider.settingsDescriptionStyle.copyWith(
                            color: themeProvider.accentColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'CAIPO is your intelligent assistant designed to help streamline tasks, provide insights, and improve productivity through natural conversations.',
              style: themeProvider.settingsDescriptionStyle.copyWith(
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFAQSection(ThemeProvider themeProvider) {
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
                Icons.help_outline,
                color: themeProvider.accentColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Frequently Asked Questions',
                style: themeProvider.settingsHeaderStyle,
              ),
            ],
          ),
        ),
        Container(
          decoration: themeProvider.settingsCardDecoration,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              children: [
                _buildFAQItem(
                  question: 'How does CAIPO work?',
                  answer: 'CAIPO uses AI to process and understand your queries in real-time.',
                  themeProvider: themeProvider,
                ),
                Divider(color: themeProvider.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
                _buildFAQItem(
                  question: 'Is my data secure?',
                  answer: 'Yes, your interactions are private and encrypted.',
                  themeProvider: themeProvider,
                ),
                Divider(color: themeProvider.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
                _buildFAQItem(
                  question: 'How do I contact support?',
                  answer: 'You can contact support using the button below.',
                  themeProvider: themeProvider,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildFAQItem({
    required String question, 
    required String answer,
    required ThemeProvider themeProvider,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: themeProvider.settingsTitleStyle,
      ),
      iconColor: themeProvider.accentColor,
      collapsedIconColor: themeProvider.secondaryIconColor,
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          answer,
          style: themeProvider.settingsDescriptionStyle,
        ),
      ],
    );
  }
  
  Widget _buildSupportButton(ThemeProvider themeProvider) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          // Placeholder for support action
        },
        icon: const Icon(Icons.support_agent),
        label: const Text('Contact Support'),
        style: ElevatedButton.styleFrom(
          backgroundColor: themeProvider.accentColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(themeProvider.borderRadius),
          ),
          elevation: 3,
          textStyle: themeProvider.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
  
  Widget _buildVersionInfo(ThemeProvider themeProvider) {
    return Container(
      decoration: themeProvider.settingsCardDecoration,
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: themeProvider.getSettingsIconDecoration(isActive: true),
              child: Icon(
                Icons.flutter_dash,
                color: themeProvider.accentColor,
                size: 36,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'CAIPO',
              style: themeProvider.settingsTitleStyle,
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: themeProvider.settingsDescriptionStyle,
            ),
            const SizedBox(height: 16),
            Text(
              '© 2025 FLOMAD. All rights reserved.',
              style: themeProvider.settingsDescriptionStyle,
            ),
          ],
        ),
      ),
    );
  }
}