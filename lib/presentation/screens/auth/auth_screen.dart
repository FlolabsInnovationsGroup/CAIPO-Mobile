import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../data/services/firebase_service.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../providers/theme_provider.dart';
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
    _initializeAnimations();
  }
  
  void _initializeAnimations() {
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

  Future<void> handleAuth() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
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
  
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (isSignUp && value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    return null;
  }
  
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

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
                child: _buildAuthContent(themeProvider),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAuthContent(ThemeProvider themeProvider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo and header
        Hero(
          tag: 'app_logo',
          child: Image.asset('assets/logo.png', height: 80),
        ),
        const SizedBox(height: 16),
        Text(
          isSignUp ? 'Create Account' : 'Log In',
          style: themeProvider.displaySmall,
        ),
        const SizedBox(height: 20),

        // Sign up fields
        if (isSignUp) ...[
          _buildInputField(
            controller: firstNameController, 
            hintText: 'First Name', 
            icon: Icons.person, 
            validator: _validateName,
            themeProvider: themeProvider,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: lastNameController, 
            hintText: 'Last Name', 
            icon: Icons.person,
            validator: _validateName,
            themeProvider: themeProvider,
          ),
          const SizedBox(height: 12),
        ],

        // Email and password fields
        _buildInputField(
          controller: emailController, 
          hintText: 'Enter your email', 
          icon: Icons.email, 
          error: emailError,
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
          themeProvider: themeProvider,
        ),
        const SizedBox(height: 12),
        _buildInputField(
          controller: passwordController, 
          hintText: 'Enter password', 
          icon: Icons.lock, 
          obscureText: !isPasswordVisible, 
          error: passwordError,
          validator: _validatePassword,
          themeProvider: themeProvider,
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: themeProvider.secondaryIconColor,
            ),
            onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
          ),
        ),
        
        // Terms checkbox for sign up
        if (isSignUp) ...[
          const SizedBox(height: 12),
          _buildTermsCheckbox(themeProvider),
        ],
        
        const SizedBox(height: 20),

        // Main action button
        _buildAuthButton(themeProvider),
        const SizedBox(height: 24),

        // Social signin section
        _buildSocialSignInSection(themeProvider),
        
        const SizedBox(height: 30),

        // Toggle between login and signup
        _buildToggleAuthModeRow(themeProvider),
      ],
    );
  }
  
  Widget _buildTermsCheckbox(ThemeProvider themeProvider) {
    return Row(
      children: [
        Checkbox(
          value: agreeToTerms,
          onChanged: (value) => setState(() => agreeToTerms = value ?? false),
          activeColor: themeProvider.accentColor,
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: 'I agree to the ',
              style: themeProvider.bodyMedium,
              children: [
                TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(
                    color: themeProvider.accentColor,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: themeProvider.accentColor,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthButton(ThemeProvider themeProvider) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : handleAuth,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeProvider.accentColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(themeProvider.borderRadius),
          ),
          elevation: 3,
        ),
        child: isLoading 
            ? SizedBox(
                width: 24, 
                height: 24, 
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ) 
            : Text(
                isSignUp ? 'Sign Up' : 'Login',
                style: themeProvider.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
  
  Widget _buildSocialSignInSection(ThemeProvider themeProvider) {
    return Column(
      children: [
        Text(
          'Or sign in with', 
          style: themeProvider.bodyMedium.copyWith(
            color: themeProvider.secondaryTextColor,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(FontAwesomeIcons.google, handleGoogleSignIn, themeProvider),
            const SizedBox(width: 16),
            _buildSocialButton(
              FontAwesomeIcons.apple, 
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Apple sign-in coming soon')),
                );
              },
              themeProvider,
            ),
            const SizedBox(width: 16),
            _buildSocialButton(
              FontAwesomeIcons.facebook, 
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Facebook sign-in coming soon')),
                );
              },
              themeProvider,
            ),
            const SizedBox(width: 16),
            _buildSocialButton(
              FontAwesomeIcons.linkedin, 
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('LinkedIn sign-in coming soon')),
                );
              },
              themeProvider,
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildToggleAuthModeRow(ThemeProvider themeProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isSignUp ? 'Already have an account?' : 'Don\'t have an account?',
          style: themeProvider.bodyMedium.copyWith(
            color: themeProvider.secondaryTextColor,
          ),
        ),
        TextButton(
          onPressed: () => setState(() => isSignUp = !isSignUp),
          style: TextButton.styleFrom(
            foregroundColor: themeProvider.accentColor,
          ),
          child: Text(
            isSignUp ? 'Log In' : 'Sign Up',
            style: themeProvider.bodyMedium.copyWith(
              color: themeProvider.accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required ThemeProvider themeProvider,
    String? error,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: themeProvider.bodyLarge,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: themeProvider.bodyMedium.copyWith(
          color: themeProvider.disabledTextColor,
        ),
        errorText: error,
        prefixIcon: Icon(
          icon, 
          color: themeProvider.secondaryIconColor,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: themeProvider.inputBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(themeProvider.borderRadius),
          borderSide: BorderSide(color: themeProvider.inputBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(themeProvider.borderRadius),
          borderSide: BorderSide(color: themeProvider.inputBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(themeProvider.borderRadius),
          borderSide: BorderSide(color: themeProvider.accentColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(themeProvider.borderRadius),
          borderSide: BorderSide(color: themeProvider.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(themeProvider.borderRadius),
          borderSide: BorderSide(color: themeProvider.errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, VoidCallback onPressed, ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.cardBackground.withOpacity(0.3),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FaIcon(
              icon, 
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
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
