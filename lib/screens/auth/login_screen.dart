import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool rememberMe = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  void handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid credentials')),
      );
      return;
    }

    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => isLoading = false);

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _controller,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _controller,
                    child: Column(
                      children: [
                        Image.asset('assets/logo.png', height: 80),
                        const SizedBox(height: 16),
                        const Text(
                          'CAIPO',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const Text('AI Companion',
                            style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  buildInputField(
                    controller: emailController,
                    hintText: 'Enter your email/phone',
                    icon: Icons.email,
                  ),
                  const SizedBox(height: 16),
                  buildInputField(
                    controller: passwordController,
                    hintText: 'Enter password',
                    icon: Icons.lock,
                    obscureText: true,
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (value) {
                          setState(() => rememberMe = value!);
                        },
                        activeColor: Colors.blueAccent,
                      ),
                      const Text("Remember Me",
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                            color: Colors.blueAccent,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTapDown: (_) => setState(() => isLoading = true),
                    onTapUp: (_) => setState(() => isLoading = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      transform:
                          isLoading ? Matrix4.identity().scaled(0.98) : Matrix4.identity(),
                      child: ElevatedButton(
                        onPressed: isLoading ? null : handleLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.blueAccent,
                          elevation: 6,
                          shadowColor: Colors.blue.withOpacity(0.5),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Login',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Sign in with',
                      style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      socialButton(FontAwesomeIcons.google, () {}),
                      const SizedBox(width: 16),
                      socialButton(FontAwesomeIcons.apple, () {}),
                      const SizedBox(width: 16),
                      socialButton(FontAwesomeIcons.facebook, () {}),
                      const SizedBox(width: 16),
                      socialButton(FontAwesomeIcons.linkedin, () {}),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
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
    bool obscureText = false,
  }) {
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget socialButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: FaIcon(icon, color: Colors.white, size: 32),
      onPressed: onPressed,
    );
  }
}