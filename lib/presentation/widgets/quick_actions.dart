import 'package:flutter/material.dart';
import '../screens/dynamic/base_dynamic_screen.dart';
import '../../data/services/dynamic_screen_manager.dart';

class QuickActions extends StatelessWidget {
  final Function(BaseDynamicScreen) onDynamicScreenSelected;

  const QuickActions({
    super.key,
    required this.onDynamicScreenSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildQuickActionButton(
            context,
            'Activity',
            Icons.directions_run,
            'show activity',
            Colors.green,
          ),
          _buildQuickActionButton(
            context,
            'Music',
            Icons.music_note,
            'play music',
            Colors.purple,
          ),
          _buildQuickActionButton(
            context,
            'Calendar',
            Icons.calendar_today,
            'show calendar',
            Colors.blue,
          ),
          _buildQuickActionButton(
            context,
            'Record',
            Icons.record_voice_over,
            'transcribe',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String label,
    IconData icon,
    String command,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final screen = DynamicScreenManager.getScreenForCommand(command);
            if (screen != null) {
              onDynamicScreenSelected(screen);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 