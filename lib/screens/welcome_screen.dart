import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth/auth_screen.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../theme_provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return GradientScaffold(
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with slight bounce animation
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 1200),
                  tween: Tween<double>(begin: 0.9, end: 1.0),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Image.asset(
                        'assets/logo.png',
                        height: 100,
                        // Remove the color tinting for now to debug
                        // color: isDarkMode ? Colors.white : null,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'CAIPO by FLOMAD',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                    shadows: [
                      Shadow(
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your personalized AI companion',
                  style: TextStyle(
                    color: isDarkMode 
                        ? Colors.grey.shade300 
                        : Colors.grey.shade700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),

                // Enhanced login button with hover effect
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withAlpha(isDarkMode ? 51 : 77),
                        spreadRadius: isDarkMode ? 1 : 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AuthScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent.withAlpha(isDarkMode ? 204 : 255),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'LOG IN',
                      style: TextStyle(
                        color: Colors.white.withAlpha(isDarkMode ? 242 : 255),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Enhanced Get Started button
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AuthScreen(signUpMode: true),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24, 
                      vertical: 12
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.transparent,
                    foregroundColor: isDarkMode 
                        ? Colors.white.withAlpha(204)
                        : Colors.black87.withAlpha(179),
                    shadowColor: Colors.transparent,
                  ),
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      color: isDarkMode 
                          ? Colors.grey.shade300 
                          : Colors.grey.shade700,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                // Optional: Add version number or additional info
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: isDarkMode 
                          ? Colors.grey.shade500 
                          : Colors.grey.shade600,
                      fontSize: 12,
                    ),
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
