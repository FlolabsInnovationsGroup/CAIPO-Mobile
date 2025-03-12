import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../theme_provider.dart';
import 'dart:developer' as developer;

class AuthScreen extends StatefulWidget {
  final bool signUpMode;
  const AuthScreen({super.key, this.signUpMode = false});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  bool isSignUp = false;
  bool isLoading = false;
  bool agreeToTerms = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;
  String? emailError;
  String? passwordError;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    isSignUp = widget.signUpMode;
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  void handleAuth() async {
    if (isSignUp && !agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must agree to the terms before signing up.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      if (isSignUp) {
        final userCredential = await FirebaseService.createUserWithEmail(
          emailController.text.trim(),
          passwordController.text.trim(),
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          dateOfBirth: dobController.text.trim(),
        );

        if (userCredential != null) {
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create account. Please try again.')),
          );
        }
      } else {
        final userCredential = await FirebaseService.signInWithEmail(
          emailController.text.trim(),
          passwordController.text.trim(),
        );

        if (userCredential != null) {
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid email or password. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> handleGoogleSignIn() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() => isLoading = true);

    try {
      developer.log('Attempting Google sign-in...', name: "AuthScreen");

      final userCredential = await FirebaseService.signInWithGoogle();
      developer.log('Sign-in result: $userCredential', name: "AuthScreen");

      if (userCredential != null && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Google sign-in was cancelled or failed')),
        );
      }
    } catch (e) {
      developer.log('Google sign-in error: $e', name: "AuthScreen");
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Google sign-in failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailPattern.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return GradientScaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _fadeInAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/logo.png', height: 80),
                    const SizedBox(height: 16),
                    Text(
                      isSignUp ? 'Create Account' : 'Log In',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (isSignUp) ...[
                      buildInputField(controller: firstNameController, hintText: 'First Name', icon: Icons.person),
                      const SizedBox(height: 12),
                      buildInputField(controller: lastNameController, hintText: 'Last Name', icon: Icons.person),
                      const SizedBox(height: 12),
                    ],

                    buildInputField(controller: emailController, hintText: 'Enter your email', icon: Icons.email, error: emailError),
                    const SizedBox(height: 12),

                    buildInputField(controller: passwordController, hintText: 'Enter password', icon: Icons.lock, obscureText: !isPasswordVisible, suffixIcon: IconButton(
                      icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                    )),
                    const SizedBox(height: 12),

                    ElevatedButton(
                      onPressed: isLoading ? null : handleAuth,
                      child: isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(isSignUp ? 'Sign Up' : 'Login'),
                    ),
                    const SizedBox(height: 24),

                    Text('Or sign in with', style: TextStyle(color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700, fontSize: 16)),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        socialButton(FontAwesomeIcons.google, handleGoogleSignIn),
                        const SizedBox(width: 16),
                        socialButton(FontAwesomeIcons.apple, () {
                          // TODO: Implement Apple sign in
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Apple sign-in coming soon')),
                          );
                        }),
                        const SizedBox(width: 16),
                        socialButton(FontAwesomeIcons.facebook, () {
                          // TODO: Implement Facebook sign in
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Facebook sign-in coming soon')),
                          );
                        }),
                        const SizedBox(width: 16),
                        socialButton(FontAwesomeIcons.linkedin, () {
                          // TODO: Implement LinkedIn sign in
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('LinkedIn sign-in coming soon')),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isSignUp ? 'Already have an account?' : 'Don\'t have an account?',
                          style: TextStyle(color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700),
                        ),
                        TextButton(
                          onPressed: () => setState(() => isSignUp = !isSignUp),
                          child: Text(
                            isSignUp ? 'Log In' : 'Sign Up',
                            style: TextStyle(color: Colors.blueAccent.withAlpha(isDarkMode ? 204 : 255), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
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

  Widget buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    String? error,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        errorText: error,
        suffixIcon: suffixIcon,
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget socialButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: FaIcon(icon, color: Colors.white, size: 24),
        onPressed: onPressed,
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    dobController.dispose();
    super.dispose();
  }
}
