import 'package:flutter/material.dart';
import '../../widgets/chat_message.dart';
import '../../widgets/gradient_scaffold.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isRecording = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final accentColor = Theme.of(context).colorScheme.primary;

    return GradientScaffold(
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              children: [
                ChatMessage(
                  message: "Hello, I'm CAIPO, your AI assistant. How can I help you today?",
                  isAI: true,
                  quickActions: [
                    'Tell me about yourself',
                    'What can you help me with?',
                    'How do I record audio?',
                  ],
                  onQuickActionTap: (action) {
                    // Handle quick action tap
                    print('Quick action tapped: $action');
                  },
                  timestamp: DateTime.now(),
                ),
              ],
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        Colors.black.withOpacity(0.8),
                        Colors.black.withOpacity(0.6),
                      ]
                    : [
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0.8),
                      ],
              ),
              border: Border(
                top: BorderSide(
                  color: isDarkMode
                      ? Colors.grey.shade800.withOpacity(0.5)
                      : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Add attachment button
                IconButton(
                  onPressed: () {
                    // Handle attachment
                  },
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                  ),
                ),
                // Message input field
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDarkMode
                            ? [
                                Colors.grey.shade900.withOpacity(0.8),
                                Colors.grey.shade900.withOpacity(0.6),
                              ]
                            : [
                                Colors.grey.shade200.withOpacity(0.8),
                                Colors.grey.shade200.withOpacity(0.6),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.grey.shade800.withOpacity(0.5)
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Message CAIPO...',
                        hintStyle: TextStyle(
                          color: isDarkMode ? Colors.white38 : Colors.black38,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      maxLines: null,
                    ),
                  ),
                ),
                // Voice input button
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isRecording = !_isRecording;
                    });
                  },
                  icon: Icon(
                    _isRecording ? Icons.stop_circle : Icons.mic_none,
                    color: _isRecording ? accentColor : (isDarkMode ? Colors.white70 : Colors.grey.shade700),
                  ),
                ),
                // Send button
                IconButton(
                  onPressed: () {
                    // Handle send message
                  },
                  icon: Icon(
                    Icons.send,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom navigation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        Colors.black.withOpacity(0.9),
                        Colors.black.withOpacity(0.7),
                      ]
                    : [
                        Colors.white.withOpacity(0.95),
                        Colors.white.withOpacity(0.85),
                      ],
              ),
              border: Border(
                top: BorderSide(
                  color: isDarkMode
                      ? Colors.grey.shade800.withOpacity(0.5)
                      : Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.chat_bubble_outline,
                  label: 'Chat',
                  isSelected: true,
                  isDarkMode: isDarkMode,
                  accentColor: accentColor,
                ),
                _buildNavItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  isSelected: false,
                  isDarkMode: isDarkMode,
                  accentColor: accentColor,
                ),
                _buildNavItem(
                  icon: Icons.logout,
                  label: 'Logout',
                  isSelected: false,
                  isDarkMode: isDarkMode,
                  accentColor: accentColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required bool isDarkMode,
    required Color accentColor,
  }) {
    return InkWell(
      onTap: () {
        // Handle navigation
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor.withOpacity(0.2),
                    accentColor.withOpacity(0.1),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(
                  color: accentColor.withOpacity(0.3),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? accentColor
                  : (isDarkMode ? Colors.white54 : Colors.black54),
              size: 20,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? accentColor
                      : (isDarkMode ? Colors.white54 : Colors.black54),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 