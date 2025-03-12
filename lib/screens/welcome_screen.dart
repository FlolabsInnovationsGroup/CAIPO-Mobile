import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth/auth_screen.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _buttonScaleAnimation;
  
  bool _isHoveringLogin = false;
  bool _isHoveringSignup = false;
  
  final List<String> _features = [
    "Voice Recording & Transcription",
    "AI-Powered Analysis",
    "Personalized Insights",
    "Secure Cloud Storage"
  ];
  
  int _currentFeatureIndex = 0;
  bool _showFeatures = false;

  bool _shouldShowOnboarding = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeIn),
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 0.9, curve: Curves.elasticOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
    ));
    
    _buttonScaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOutBack),
    );
    
    // Start animations immediately when screen is shown
    _animationController.forward();
    
    // Start feature cycling after animations complete
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _showFeatures = true;
        });
        _startFeatureCycling();
      }
    });

    // Check authentication status when screen is shown
    _checkAuthStatus();
  }
  
  void _startFeatureCycling() {
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _currentFeatureIndex = (_currentFeatureIndex + 1) % _features.length;
        });
        _startFeatureCycling();
      }
    });
  }

  Future<void> _checkAuthStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool("hasSeenOnboarding") ?? false;

    if (mounted) {
      setState(() {
        _shouldShowOnboarding = !hasSeenOnboarding;
        _isLoggedIn = currentUser != null;
      });
    }
  }

  void _handleNavigation({bool isSignUp = false}) async {
    if (_shouldShowOnboarding) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else if (_isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              AuthScreen(signUpMode: isSignUp),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.2),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeOutCubic))
                    .animate(animation),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
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
    final size = MediaQuery.of(context).size;

    return GradientScaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo with advanced animations
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Hero(
                      tag: 'app_logo',
                      child: Container(
                        height: 120,
                        width: 120,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withAlpha(isDarkMode ? 40 : 60),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/logo.png',
                          height: 100,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // App name with shine animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          colors: [
                            Colors.blueAccent.shade100,
                            Colors.white,
                            Colors.blueAccent.shade100,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          tileMode: TileMode.clamp,
                        ).createShader(bounds);
                      },
                      child: Text(
                        'CAIPO by FLOMAD',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                
                // Tagline with feature rotation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        'Your personalized AI companion',
                        style: TextStyle(
                          color: isDarkMode 
                              ? Colors.grey.shade300 
                              : Colors.grey.shade700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      AnimatedOpacity(
                        opacity: _showFeatures ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 400),
                        child: Container(
                          height: 24,
                          width: size.width * 0.8,
                          alignment: Alignment.center,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.0, 0.2),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              _features[_currentFeatureIndex],
                              key: ValueKey<int>(_currentFeatureIndex),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blueAccent.shade100,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                
                // Login button with enhanced animations
                ScaleTransition(
                  scale: _buttonScaleAnimation,
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _isHoveringLogin = true),
                    onExit: (_) => setState(() => _isHoveringLogin = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withAlpha(isDarkMode ? 40 : 60),
                            spreadRadius: _isHoveringLogin ? 2 : 1,
                            blurRadius: _isHoveringLogin ? 12 : 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blueAccent.shade700,
                            Colors.blueAccent,
                          ],
                        ),
                      ),
                      transform: Matrix4.identity()..scale(_isHoveringLogin ? 1.02 : 1.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _handleNavigation(),
                          borderRadius: BorderRadius.circular(12),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: _isHoveringLogin ? 30 : 0,
                                  child: _isHoveringLogin
                                      ? const Icon(
                                          Icons.login,
                                          color: Colors.white,
                                          size: 20,
                                        )
                                      : null,
                                ),
                                Text(
                                  'LOG IN',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(isDarkMode ? 242 : 255),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Sign up button with enhanced animations
                ScaleTransition(
                  scale: _buttonScaleAnimation,
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _isHoveringSignup = true),
                    onExit: (_) => setState(() => _isHoveringSignup = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      transform: Matrix4.identity()..scale(_isHoveringSignup ? 1.02 : 1.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: _isHoveringSignup
                              ? Colors.blueAccent
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _handleNavigation(isSignUp: true),
                          borderRadius: BorderRadius.circular(30),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24, 
                              vertical: 12
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: _isHoveringSignup ? 24 : 0,
                                  child: _isHoveringSignup
                                      ? Icon(
                                          Icons.person_add,
                                          color: isDarkMode 
                                              ? Colors.white 
                                              : Colors.black87,
                                          size: 18,
                                        )
                                      : null,
                                ),
                                Text(
                                  'Get Started',
                                  style: TextStyle(
                                    color: _isHoveringSignup
                                        ? Colors.blueAccent
                                        : isDarkMode 
                                            ? Colors.grey.shade300 
                                            : Colors.grey.shade700,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Footer information
                const SizedBox(height: 50),
                
                // Version info with additional links
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.7, 1.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          color: isDarkMode 
                              ? Colors.grey.shade500 
                              : Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildFooterLink('Privacy', context),
                      const SizedBox(width: 16),
                      _buildFooterLink('Terms', context),
                      const SizedBox(width: 16),
                      _buildFooterLink('Help', context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFooterLink(String text, BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(text),
            content: Text('$text content will be available soon.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
      child: Text(
        text,
        style: TextStyle(
          color: Colors.blueAccent.withAlpha(204),
          fontSize: 12,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
