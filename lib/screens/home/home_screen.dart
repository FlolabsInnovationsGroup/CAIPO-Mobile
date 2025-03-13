import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../ai/openai_service.dart'; // Import OpenAI Service
import '../../theme_provider.dart'; // Ensure theme switching works
import '../../widgets/gradient_scaffold.dart';
import '../../data/services/firebase_service.dart'; // Import Firebase Service

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
                  color: isDarkMode ? const Color(0xFF1E1E2E) : Colors.white,
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
                    Expanded(child: _buildMessageList()),
                    _buildInputField(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/record'),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.mic),
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
            ? Colors.blueAccent.withAlpha(179)
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
          ? Colors.black.withAlpha(204)
          : Colors.white,
      selectedItemColor: Colors.blueAccent.withAlpha(isDarkMode ? 230 : 255),
      unselectedItemColor: isDarkMode 
          ? Colors.grey.shade500 
          : Colors.grey.shade600,
      currentIndex: 0,
      onTap: (index) async {
        switch (index) {
          case 1:
            Navigator.pushNamed(context, '/settings');
            break;
          case 2:
            // Show confirmation dialog before logout
            final shouldLogout = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );
            
            if (shouldLogout == true) {
              await FirebaseService.signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  '/auth', 
                  (route) => false
                );
              }
            }
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble),
          label: "Chat",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: "Settings",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.logout),
          label: "Logout",
        ),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                fillColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
                filled: true,
              ),
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.blueAccent,
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser
                  ? Colors.blueAccent
                  : isDarkMode 
                      ? const Color(0xFF1E1E2E) 
                      : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
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
                        ? Colors.grey[300] 
                        : Colors.black87,
              ),
            ),
          ),
        );
      },
    );
  }
}