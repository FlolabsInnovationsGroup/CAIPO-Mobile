import 'package:flutter/material.dart';
import '../screens/dynamic/base_dynamic_screen.dart';
import '../../data/services/dynamic_screen_manager.dart';
import '../screens/notes/note_landing_screen.dart';

class AppDrawer extends StatelessWidget {
  final Function(BaseDynamicScreen) onDynamicScreenSelected;
  final String username;
  final String? userAvatarUrl;

  const AppDrawer({
    super.key,
    required this.onDynamicScreenSelected,
    required this.username,
    this.userAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    const Color(0xFF1E1E2E),
                    const Color(0xFF2D2D3F),
                  ]
                : [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
          ),
        ),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primaryColor,
                    theme.primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: userAvatarUrl != null
                    ? NetworkImage(userAvatarUrl!)
                    : null,
                child: userAvatarUrl == null
                    ? const Icon(Icons.person, color: Colors.blue)
                    : null,
              ),
              accountName: Text(
                username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              accountEmail: const Text('CAIPO Wearable User'),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'DYNAMIC SCREENS',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  _buildDynamicScreenTile(
                    context,
                    'Activity Tracking',
                    Icons.directions_run,
                    'Track your daily activities',
                    Colors.green,
                    'Track your steps, heart rate, and more',
                  ),
                  _buildDynamicScreenTile(
                    context,
                    'Music Control',
                    Icons.music_note,
                    'Control your music playback',
                    Colors.purple,
                    'Control your music playback',
                  ),
                  _buildDynamicScreenTile(
                    context,
                    'Calendar',
                    Icons.calendar_today,
                    'View your schedule',
                    Colors.blue,
                    'View and manage your schedule',
                  ),
                  _buildDynamicScreenTile(
                    context,
                    'Transcription',
                    Icons.record_voice_over,
                    'transcribe',
                    Colors.orange,
                    'Convert speech to text',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'NOTES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDynamicScreenTile(
                    context,
                    'Create Note',
                    Icons.note_add,
                    'Create a new note',
                    Colors.grey,
                    'Create and manage your notes',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/notes');
                    },
                  ),
                  const Divider(height: 32),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      'SETTINGS',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.settings, color: theme.primaryColor),
                    ),
                    title: const Text('Settings'),
                    subtitle: const Text('Customize your experience'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.help_outline, color: theme.primaryColor),
                    ),
                    title: const Text('Help'),
                    subtitle: const Text('Get assistance and support'),
                    onTap: () {
                      Navigator.pop(context);
                      // Show help dialog
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'CAIPO Wearable v1.0',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey : Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicScreenTile(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    Color color,
    String subtitle,
    {VoidCallback? onTap}
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap ?? () {
        Navigator.pop(context);
        final screen = DynamicScreenManager.getScreenForCommand(description);
        if (screen != null) {
          onDynamicScreenSelected(screen);
        }
      },
    );
  }
} 