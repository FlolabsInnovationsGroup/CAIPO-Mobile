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
    _initializeAnimations();
    _checkAuthStatus();
  }
  
  void _initializeAnimations() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    // Use the animation speed from theme if animations are enabled
    final animDuration = themeProvider.useAnimations 
        ? Duration(milliseconds: (5000 * (themeProvider.animationSpeedName == 'slow' ? 1.5 : themeProvider.animationSpeedName == 'fast' ? 0.7 : 1.0)).round()) 
        : const Duration(seconds: 5);
    
    _animationController = AnimationController(
      vsync: this,
      duration: animDuration,
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
    final size = MediaQuery.of(context).size;

    return GradientScaffold(
      usePatternOverlay: true, // Add subtle texture for depth
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo with advanced animations
                _buildAnimatedLogo(themeProvider),
                const SizedBox(height: 20),
                
                // App name with shine animation
                _buildAppName(themeProvider),
                const SizedBox(height: 10),
                
                // Tagline with feature rotation
                _buildTaglineAndFeatures(themeProvider, size),
                const SizedBox(height: 40),
                
                // Login button with enhanced animations
                _buildLoginButton(themeProvider),
                const SizedBox(height: 20),
                
                // Sign up button with enhanced animations
                _buildSignUpButton(themeProvider),
                
                // Footer information
                const SizedBox(height: 50),
                
                // Version info with additional links
                _buildFooterSection(themeProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAnimatedLogo(ThemeProvider themeProvider) {
    return ScaleTransition(
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
                  color: themeProvider.accentColor.withOpacity(0.3),
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
    );
  }
  
  Widget _buildAppName(ThemeProvider themeProvider) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [
                themeProvider.accentColor.withOpacity(0.7),
                Colors.white,
                themeProvider.accentColor.withOpacity(0.7),
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              tileMode: TileMode.clamp,
            ).createShader(bounds);
          },
          child: Text(
            'CAIPO by FLOMAD',
            style: themeProvider.displaySmall.copyWith(
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTaglineAndFeatures(ThemeProvider themeProvider, Size size) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Text(
            'Your personalized AI companion',
            style: themeProvider.titleLarge.copyWith(
              color: themeProvider.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 10),
          AnimatedOpacity(
            opacity: _showFeatures ? 1.0 : 0.0,
            duration: themeProvider.animationDurationMedium,
            child: Container(
              height: 24,
              width: size.width * 0.8,
              alignment: Alignment.center,
              child: AnimatedSwitcher(
                duration: themeProvider.animationDurationMedium,
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
                  style: themeProvider.titleMedium.copyWith(
                    color: themeProvider.accentColor.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoginButton(ThemeProvider themeProvider) {
    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHoveringLogin = true),
        onExit: (_) => setState(() => _isHoveringLogin = false),
        child: AnimatedContainer(
          duration: themeProvider.animationDurationShort,
          width: MediaQuery.of(context).size.width * 0.8,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(themeProvider.borderRadius),
            boxShadow: [
              BoxShadow(
                color: themeProvider.accentColor.withOpacity(0.3),
                spreadRadius: _isHoveringLogin ? 2 : 1,
                blurRadius: _isHoveringLogin ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                themeProvider.accentColor.withOpacity(0.9),
                themeProvider.accentColor,
              ],
            ),
          ),
          transform: Matrix4.identity()..scale(_isHoveringLogin ? 1.02 : 1.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleNavigation(),
              borderRadius: BorderRadius.circular(themeProvider.borderRadius),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: themeProvider.animationDurationShort,
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
                      style: themeProvider.titleLarge.copyWith(
                        color: Colors.white,
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
    );
  }
  
  Widget _buildSignUpButton(ThemeProvider themeProvider) {
    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHoveringSignup = true),
        onExit: (_) => setState(() => _isHoveringSignup = false),
        child: AnimatedContainer(
          duration: themeProvider.animationDurationShort,
          transform: Matrix4.identity()..scale(_isHoveringSignup ? 1.02 : 1.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _isHoveringSignup
                  ? themeProvider.accentColor
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
                      duration: themeProvider.animationDurationShort,
                      width: _isHoveringSignup ? 24 : 0,
                      child: _isHoveringSignup
                          ? Icon(
                              Icons.person_add,
                              color: themeProvider.textColor,
                              size: 18,
                            )
                          : null,
                    ),
                    Text(
                      'Get Started',
                      style: themeProvider.titleMedium.copyWith(
                        color: _isHoveringSignup
                            ? themeProvider.accentColor
                            : themeProvider.secondaryTextColor,
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
    );
  }
  
  Widget _buildFooterSection(ThemeProvider themeProvider) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Version 1.0.0',
            style: themeProvider.bodySmall.copyWith(
              color: themeProvider.secondaryTextColor,
            ),
          ),
          const SizedBox(width: 16),
          _buildFooterLink('Privacy', context, themeProvider),
          const SizedBox(width: 16),
          _buildFooterLink('Terms', context, themeProvider),
          const SizedBox(width: 16),
          _buildFooterLink('Help', context, themeProvider),
        ],
      ),
    );
  }
  
  Widget _buildFooterLink(String text, BuildContext context, ThemeProvider themeProvider) {
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
        style: themeProvider.bodySmall.copyWith(
          color: themeProvider.accentColor.withOpacity(0.8),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
