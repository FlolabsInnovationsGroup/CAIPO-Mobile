import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../ai/openai_service.dart'; // Import OpenAI Service
import '../../theme_provider.dart'; // Ensure theme switching works
import '../../widgets/gradient_scaffold.dart';

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

    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? Colors.black.withOpacity(0.4) 
                      : Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode 
                          ? Colors.black12 
                          : Colors.grey.shade300,
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(child: _buildMessageList()),
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

  Widget _buildHeader(BuildContext context) {
    // Use the theme provider's headerGradient instead of defining one here
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: themeProvider.headerGradient,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SpinKitThreeBounce(
        color: isDarkMode 
            ? Colors.blueAccent.withOpacity(0.7) 
            : Colors.blueAccent,
        size: 20.0,
      ),
    );
  }

  Widget _buildBottomNavBar() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    return BottomNavigationBar(
      backgroundColor: isDarkMode 
          ? Colors.black.withOpacity(0.8) 
          : Colors.white,
      selectedItemColor: Colors.blueAccent.withOpacity(isDarkMode ? 0.9 : 1.0),
      unselectedItemColor: isDarkMode 
          ? Colors.grey.shade500 
          : Colors.grey.shade600,
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: TextStyle(
                  color: isDarkMode 
                      ? Colors.grey.shade400 
                      : Colors.grey.shade600,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: isDarkMode 
                        ? Colors.grey.shade800 
                        : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: isDarkMode 
                        ? Colors.grey.shade800 
                        : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Colors.blueAccent.withOpacity(isDarkMode ? 0.7 : 1.0),
                  ),
                ),
                fillColor: isDarkMode 
                    ? Colors.grey.shade900 
                    : Colors.grey.shade100,
                filled: true,
              ),
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.blueAccent.withOpacity(isDarkMode ? 0.8 : 1.0),
            radius: 24,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 22),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    return ListView.builder(
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isTyping) {
          return _typingIndicator();
        }
        final message = _messages[index];
        final isUser = message['sender'] == 'You';

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isUser
                  ? Colors.blueAccent.withOpacity(isDarkMode ? 0.8 : 1.0)
                  : isDarkMode 
                      ? Colors.grey.shade900 
                      : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              '${message['message']}',
              style: TextStyle(
                fontSize: 16,
                color: isUser 
                    ? Colors.white 
                    : isDarkMode 
                        ? Colors.grey.shade100 
                        : Colors.black87,
              ),
            ),
          ),
        );
      },
    );
  }
}