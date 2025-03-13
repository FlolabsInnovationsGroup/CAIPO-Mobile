import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme_provider.dart';

class RecentRecordingsSheet extends StatefulWidget {
  final Function(String) onRecordingSelected;
  final ScrollController scrollController;
  
  const RecentRecordingsSheet({
    super.key,
    required this.onRecordingSelected,
    required this.scrollController,
  });

  @override
  State<RecentRecordingsSheet> createState() => _RecentRecordingsSheetState();
}

class _RecentRecordingsSheetState extends State<RecentRecordingsSheet> {
  List<Map<String, dynamic>> _recordings = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadRecordings();
  }
  
  Future<void> _loadRecordings() async {
    // Simulated loading of recordings
    // In a real app, you would load this from your storage
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _recordings = [
        {
          'name': 'Meeting Notes',
          'path': '/path/to/recording_1.aac',
          'date': DateTime.now().subtract(const Duration(hours: 2)),
          'duration': 120, // seconds
        },
        {
          'name': 'Interview',
          'path': '/path/to/recording_2.aac',
          'date': DateTime.now().subtract(const Duration(days: 1)),
          'duration': 1800, // seconds
        },
        {
          'name': 'Lecture',
          'path': '/path/to/recording_3.aac',
          'date': DateTime.now().subtract(const Duration(days: 3)),
          'duration': 3600, // seconds
        },
      ];
      _isLoading = false;
    });
  }
  
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}m ${remainingSeconds}s';
    } else {
      return '${minutes}m ${remainingSeconds}s';
    }
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${DateFormat('h:mm a').format(date)}';
    } else if (difference.inDays < 7) {
      return '${DateFormat('EEEE').format(date)}, ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // Handle and title
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Recent Recordings',
                  style: themeProvider.titleLarge,
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // List of recordings
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: themeProvider.accentColor,
                    ),
                  )
                : ListView.builder(
                    controller: widget.scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _recordings.length,
                    itemBuilder: (context, index) {
                      final recording = _recordings[index];
                      final date = recording['date'] as DateTime;
                      
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: themeProvider.accentColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.mic,
                            color: themeProvider.accentColor,
                          ),
                        ),
                        title: Text(
                          recording['name'] as String,
                          style: themeProvider.bodyLarge,
                        ),
                        subtitle: Text(
                          '${_formatDuration(recording['duration'] as int)} • ${_formatDate(date)}',
                          style: themeProvider.bodySmall.copyWith(
                            color: themeProvider.secondaryTextColor,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: themeProvider.secondaryIconColor,
                        ),
                        onTap: () => widget.onRecordingSelected(recording['path'] as String),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 