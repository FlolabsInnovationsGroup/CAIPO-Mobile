import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../services/firebase_service.dart';

class AuthScreen extends StatefulWidget {
  final bool signUpMode;
  const AuthScreen({super.key, this.signUpMode = false});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF001F3F), Color(0xFF000000)],
          ),
        ),
        child: Center(
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
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
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
                        ),
                        const Expanded(
                          child: Text('I agree to the Terms & Privacy Policy', style: TextStyle(color: Colors.white70)),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: isLoading ? null : handleAuth,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(isSignUp ? 'Sign Up' : 'Login',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(height: 24),

                  const Text('Or sign in with', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      socialButton(FontAwesomeIcons.google, () async {
                        setState(() => isLoading = true);
                        try {
                          final userCredential = await FirebaseService.signInWithGoogle();
                          if (userCredential != null && mounted) {
                            Navigator.pushReplacementNamed(context, '/home');
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
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
                      Text(isSignUp ? 'Already have an account?' : 'Don\'t have an account?',
                          style: const TextStyle(color: Colors.white70)),
                      TextButton(
                        onPressed: () => setState(() => isSignUp = !isSignUp),
                        child: Text(isSignUp ? 'Log In' : 'Sign Up', style: const TextStyle(color: Colors.blueAccent)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputField({required TextEditingController controller, required String hintText, required IconData icon, bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white24,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white70),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget socialButton(IconData icon, VoidCallback onPressed) {
    return IconButton(icon: FaIcon(icon, color: Colors.white, size: 32), onPressed: onPressed);
  }
}