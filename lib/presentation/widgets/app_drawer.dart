import 'package:flutter/material.dart';
import '../screens/dynamic/base_dynamic_screen.dart';
import '../../data/services/dynamic_screen_manager.dart';

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
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage:
                    userAvatarUrl != null ? NetworkImage(userAvatarUrl!) : null,
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
                  _buildDynamicScreenTile(
                    context,
                    'Activity Tracking',
                    Icons.directions_run,
                    'show activity',
                    Colors.green,
                  ),
                  _buildDynamicScreenTile(
                    context,
                    'Music Control',
                    Icons.music_note,
                    'play music',
                    Colors.purple,
                  ),
                  _buildDynamicScreenTile(
                    context,
                    'Calendar',
                    Icons.calendar_today,
                    'show calendar',
                    Colors.blue,
                  ),
                  _buildDynamicScreenTile(
                    context,
                    'Transcription',
                    Icons.record_voice_over,
                    'transcribe',
                    Colors.orange,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Help'),
                    onTap: () {
                      Navigator.pop(context);
                      // Show help dialog
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
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
    String command,
    Color color,
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
      onTap: () {
        Navigator.pop(context);
        final screen = DynamicScreenManager.getScreenForCommand(command);
        if (screen != null) {
          onDynamicScreenSelected(screen);
        }
      },
    );
  }
}
