import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'di/injection.dart';
import 'data/services/firebase_service.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/wearable_provider.dart';
import 'core/navigation/navigation_service.dart';
import 'core/utils/animation_constants.dart';
import 'presentation/screens/settings/settings_page.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/welcome/welcome_screen.dart';
import 'presentation/screens/auth/auth_screen.dart';
import 'presentation/screens/support/onboarding_screen.dart';
import 'presentation/screens/home/recording_screen.dart';
import 'presentation/screens/ai/transcription_screen.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/screens/notes/note_landing_screen.dart';
import 'presentation/screens/notes/create_note_screen.dart';
import 'presentation/screens/notes/recording_summary_screen.dart';

Future<void> main() async {
  // Catch Flutter errors and log them
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Here you could add custom error logging
  };
  
  // Catch async errors that aren't caught by Flutter's error zone
  runZonedGuarded(() async {
    // Ensure Flutter is initialized
    WidgetsFlutterBinding.ensureInitialized();
    
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Set system UI overlay style for a more immersive experience
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ));

    // Initialize services in parallel for faster startup
    await Future.wait([
      FirebaseService.initialize(),
      dotenv.load(fileName: ".env"),
      // Add other async initialization tasks here
    ]);

    // Configure dependency injection
    await configureDependencies();

    // Get providers and initialize them
    final themeProvider = getIt<ThemeProvider>();
    final wearableProvider = getIt<WearableProvider>();
    final settingsProvider = getIt<SettingsProvider>();
    
    themeProvider.initialize();
    await themeProvider.loadPreferences();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeProvider),
          ChangeNotifierProvider.value(value: wearableProvider),
          ChangeNotifierProvider.value(value: settingsProvider),
        ],
        child: const MyApp(),
      ),
    );
  }, (error, stackTrace) {
    // Handle any errors not caught by Flutter's error zone
    debugPrint('Uncaught error: $error');
    debugPrint(stackTrace.toString());
    // Here you could add custom error reporting
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'CAIPO Assistant',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.getThemeData(false),
      darkTheme: themeProvider.getThemeData(true),
      themeMode: themeProvider.themeMode,
      navigatorKey: NavigationService.navigatorKey,
      home: _buildHomeBasedOnAuth(),
      onGenerateRoute: (settings) {
        // Custom route generation with animations
        Widget page;
        switch (settings.name) {
          case '/onboarding':
            page = const OnboardingScreen();
            break;
          case '/welcome':
            page = const WelcomeScreen();
            break;
          case '/auth':
            page = const AuthScreen();
            break;
          case '/home':
            page = const HomeScreen();
            break;
          case '/settings':
            page = const SettingsScreen();
            break;
          case '/record':
            page = const RecordingScreen();
            break;
          case '/notes':
            page = const NoteLandingScreen();
            break;
          case '/notes/create':
            page = const CreateNoteScreen();
            break;
          case '/notes/recording':
            page = const RecordingSummaryScreen();
            break;
          case '/transcription':
            final args = settings.arguments as Map<String, dynamic>?;
            page = TranscriptionScreen(audioFilePath: args?['audioFilePath'] ?? "");
            break;
          default:
            page = const SplashScreen();
        }
        return AnimationConstants.slideTransition(page);
      },
      builder: (context, child) {
        // Apply font scaling for accessibility
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(MediaQuery.of(context).textScaleFactor.clamp(0.85, 1.3)),
          ),
          child: child!,
        );
      },
    );
  }
  
  Widget _buildHomeBasedOnAuth() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // User is already signed in, go directly to home
      debugPrint('User is already signed in: ${currentUser.uid}');
      return const HomeScreen();
    } else {
      // No user signed in, show splash screen
      debugPrint('No user signed in, showing splash screen');
      return const SplashScreen();
    }
  }
} 