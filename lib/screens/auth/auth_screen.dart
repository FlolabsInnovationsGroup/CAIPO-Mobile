import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../theme_provider.dart';

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
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    isSignUp = widget.signUpMode;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeInAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
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
        // Sign up flow
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
        // Login flow
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

  Future<void> selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dobController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    return GradientScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: FadeTransition(
            opacity: _fadeInAnimation,
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
                  GestureDetector(
                    onTap: () => selectDate(context),
                    child: AbsorbPointer(
                      child: buildInputField(controller: dobController, hintText: 'Date of Birth', icon: Icons.calendar_today),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                buildInputField(controller: emailController, hintText: 'Enter your email', icon: Icons.email),
                const SizedBox(height: 12),

                buildInputField(controller: passwordController, hintText: 'Enter password', icon: Icons.lock, obscureText: true),
                const SizedBox(height: 12),

                if (isSignUp)
                  Row(
                    children: [
                      Checkbox(
                        value: agreeToTerms,
                        onChanged: (value) {
                          setState(() => agreeToTerms = value!);
                        },
                        checkColor: Colors.white,
                        activeColor: Colors.blueAccent.withAlpha(isDarkMode ? 204 : 255),
                      ),
                      Expanded(
                        child: Text(
                          'I agree to the Terms & Privacy Policy',
                          style: TextStyle(
                            color: isDarkMode 
                                ? Colors.grey.shade300 
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: isLoading ? null : handleAuth,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)
                    ),
                    backgroundColor: Colors.blueAccent.withAlpha(isDarkMode ? 204 : 255),
                    elevation: isDarkMode ? 2 : 4,
                    shadowColor: Colors.blue.withAlpha(isDarkMode ? 77 : 102),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isSignUp ? 'Sign Up' : 'Login',
                          style: const TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.white
                          ),
                        ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Or sign in with', 
                  style: TextStyle(
                    color: isDarkMode 
                        ? Colors.grey.shade300 
                        : Colors.grey.shade700, 
                    fontSize: 16
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    socialButton(FontAwesomeIcons.google, () async {
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      setState(() => isLoading = true);
                      try {
                        final userCredential = await FirebaseService.signInWithGoogle();
                        if (userCredential != null && mounted) {
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      } catch (e) {
                        if (mounted) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(content: Text('Google sign-in failed: ${e.toString()}')),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => isLoading = false);
                      }
                    }),
                    const SizedBox(width: 20),
                    socialButton(FontAwesomeIcons.facebook, () {}),
                    const SizedBox(width: 20),
                    socialButton(FontAwesomeIcons.apple, () {}),
                    const SizedBox(width: 20),
                    socialButton(FontAwesomeIcons.linkedin, () {}),
                  ],
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isSignUp ? 'Already have an account?' : 'Don\'t have an account?',
                      style: TextStyle(
                        color: isDarkMode 
                            ? Colors.grey.shade300 
                            : Colors.grey.shade700,
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => isSignUp = !isSignUp),
                      child: Text(
                        isSignUp ? 'Log In' : 'Sign Up',
                        style: TextStyle(
                          color: Colors.blueAccent.withAlpha(isDarkMode ? 204 : 255),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
    bool obscureText = false
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black87,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDarkMode 
            ? Colors.black.withAlpha(77)
            : Colors.white.withAlpha(230),
        hintText: hintText,
        hintStyle: TextStyle(
          color: isDarkMode 
              ? Colors.grey.shade400 
              : Colors.grey.shade600,
        ),
        prefixIcon: Icon(
          icon, 
          color: isDarkMode 
              ? Colors.grey.shade300 
              : Colors.grey.shade700,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode 
                ? Colors.grey.shade800 
                : Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode 
                ? Colors.grey.shade800 
                : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.blueAccent.withAlpha(isDarkMode ? 179 : 255),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget socialButton(IconData icon, VoidCallback onPressed) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode 
            ? Colors.white.withAlpha(26)
            : Colors.grey.shade200,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withAlpha(51)
                : Colors.grey.withAlpha(77),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: FaIcon(
          icon, 
          color: isDarkMode ? Colors.white : Colors.black87, 
          size: 24
        ),
        onPressed: onPressed,
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}