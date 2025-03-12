import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/auth_screen.dart'; // Navigate to login after onboarding

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/onboarding1.png",
      "title": "Welcome to CAIPO.ai",
      "description": "Your AI-powered personal assistant for productivity, business, and more.",
    },
    {
      "image": "assets/onboarding2.png",
      "title": "Record & Manage",
      "description": "Easily record, store, and access your voice and video files anytime, anywhere.",
    },
    {
      "image": "assets/onboarding3.png",
      "title": "AI-Powered Insights",
      "description": "Transcribe, analyze, and optimize your recordings with advanced AI tools.",
    },
  ];

  void _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("hasSeenOnboarding", true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingData.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return _buildOnboardingPage(
                onboardingData[index]["image"]!,
                onboardingData[index]["title"]!,
                onboardingData[index]["description"]!,
              );
            },
          ),

          // Page Indicator & Navigation Buttons
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                _buildPageIndicator(),
                const SizedBox(height: 20),
                _buildNavigationButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(String image, String title, String description) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(image, height: 250),
        const SizedBox(height: 30),
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(onboardingData.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          height: 10,
          width: _currentPage == index ? 20 : 10,
          decoration: BoxDecoration(
            color: _currentPage == index ? Colors.blueAccent : Colors.grey,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: _completeOnboarding,
          child: const Text("Skip", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_currentPage == onboardingData.length - 1) {
              _completeOnboarding();
            } else {
              _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.ease);
            }
          },
          child: Text(_currentPage == onboardingData.length - 1 ? "Finish" : "Next"),
        ),
      ],
    );
  }
}
