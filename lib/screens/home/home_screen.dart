import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../ai/openai_service.dart'; // Import OpenAI Service
import '../../theme_provider.dart'; // Ensure theme switching works

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addBotMessage("Hello! How can I assist you today?");
  }

  void _addBotMessage(String message) {
    setState(() {
      _messages.add({'sender': 'AI', 'message': message});
    });
  }

  Future<void> _sendMessage() async {
    final userMessage = _messageController.text;
    if (userMessage.isNotEmpty) {
      setState(() {
        _messages.add({'sender': 'You', 'message': userMessage});
        _messageController.clear();
        _isTyping = true;
      });

      try {
        final openAIService = OpenAIService();
        final aiResponse = await openAIService.queryOpenAI(userMessage);
        setState(() => _addBotMessage(aiResponse));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }

      setState(() => _isTyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDarkMode),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [const Color(0xFF0A0F1F), const Color(0xFF152238)]
                        : [const Color(0xFFE3E3E3), const Color(0xFFF5F5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode ? Colors.black54 : Colors.grey.shade300,
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _messages.length + (_isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _messages.length && _isTyping) {
                            return _typingIndicator();
                          }
                          final message = _messages[index];
                          final isUser = message['sender'] == 'You';

                          return Align(
                            alignment:
                                isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Colors.blueAccent.withOpacity(0.9)
                                    : const Color(0xFF1E1E2E),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${message['message']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isUser ? Colors.white : Colors.grey[300],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    _buildInputField(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [const Color(0xFF0A0F1F), const Color(0xFF152238)]
              : [Colors.deepPurple, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good Morning!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _typingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: SpinKitThreeBounce(
        color: Colors.blueAccent,
        size: 20.0,
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      onTap: (index) {
        if (index == 1) {
          Navigator.pushNamed(context, '/settings');
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: "Chat"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blueAccent, size: 28),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}