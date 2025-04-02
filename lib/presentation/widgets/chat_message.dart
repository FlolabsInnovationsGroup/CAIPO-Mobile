import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final String message;
  final bool isAI;
  final List<String> quickActions;
  final Function(String) onQuickActionTap;
  final DateTime timestamp;

  const ChatMessage({
    super.key,
    required this.message,
    this.isAI = false,
    this.quickActions = const [],
    required this.onQuickActionTap,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final accentColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isAI)
                Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor.withOpacity(0.8),
                        accentColor.withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.smart_toy,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isAI
                              ? [
                                  accentColor.withOpacity(isDarkMode ? 0.15 : 0.1),
                                  accentColor.withOpacity(isDarkMode ? 0.1 : 0.05),
                                ]
                              : isDarkMode
                                  ? [
                                      Colors.grey.shade800.withOpacity(0.8),
                                      Colors.grey.shade800.withOpacity(0.6),
                                    ]
                                  : [
                                      Colors.grey.shade200.withOpacity(0.8),
                                      Colors.grey.shade200.withOpacity(0.6),
                                    ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isAI
                              ? accentColor.withOpacity(0.2)
                              : isDarkMode
                                  ? Colors.grey.shade700.withOpacity(0.5)
                                  : Colors.grey.shade300.withOpacity(0.5),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isAI
                                ? accentColor.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode ? Colors.white : Colors.black87,
                              height: 1.5,
                            ),
                          ),
                          if (quickActions.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: quickActions.map((action) {
                                return InkWell(
                                  onTap: () => onQuickActionTap(action),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          accentColor.withOpacity(0.2),
                                          accentColor.withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: accentColor.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      action,
                                      style: TextStyle(
                                        color: accentColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, top: 4),
                      child: Text(
                        _formatTimestamp(timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
} 