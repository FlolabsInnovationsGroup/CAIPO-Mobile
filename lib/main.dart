import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Load .env
import 'package:shared_preferences/shared_preferences.dart';
import 'services/firebase_service.dart'; // Import Firebase service
import 'theme_provider.dart';
import 'screens/settings/settings_page.dart';
import 'screens/home/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/support/onboarding_screen.dart';
import 'screens/home/recording_screen.dart';
import 'screens/ai/transcription_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform awareness
  await FirebaseService.initialize();
  
  await dotenv.load(fileName: ".env"); // Load environment variables

  // Check if the user has seen onboarding
  final bool hasSeenOnboarding = await _checkOnboardingStatus();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // Theme provider
      ],
      child: MyApp(hasSeenOnboarding: hasSeenOnboarding),
    ),
  );
}

// Check if user has already seen onboarding
Future<bool> _checkOnboardingStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool("hasSeenOnboarding") ?? false;
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CAIPO App',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
        cardTheme: CardTheme(
          color: Colors.white.withAlpha(230),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.black.withAlpha(179),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
      initialRoute: hasSeenOnboarding ? '/welcome' : '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/record': (context) => const RecordingScreen(),
        '/transcription': (context) => const TranscriptionScreen(audioFilePath: ""),
      },
    );
  }
}
