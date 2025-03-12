import 'dart:io';
import 'dart:typed_data';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:desktop_webview_auth/desktop_webview_auth.dart';
import 'package:desktop_webview_auth/google.dart';
import '../firebase_options.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'dart:convert';

class FirebaseService {
  static bool _initialized = false;
  
  static Future<void> initialize() async {
    if (_isFirebaseSupported()) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        _initialized = true;
        developer.log("Firebase initialized successfully", name: "FirebaseService", error: _getPlatformName());
      } catch (e) {
        developer.log("Failed to initialize Firebase", name: "FirebaseService", error: "${_getPlatformName()}: $e");
        // We'll still continue, but with degraded functionality
      }
    } else {
      developer.log("Firebase not fully supported", name: "FirebaseService", error: "${_getPlatformName()}, using alternative implementations");
    }
  }
  
  static String _getPlatformName() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }
  
  static bool _isFirebaseSupported() {
    // Remove the platform check since Firebase now supports Windows
    return true;
  }
  
  static bool isFeatureAvailable(String feature) {
    if (!_initialized || !_isFirebaseSupported()) return false;
    
    switch (feature) {
      case 'auth':
        try {
          FirebaseAuth.instance.app;
          return true;
        } catch (e) {
          return false;
        }
      case 'firestore':
        try {
          FirebaseFirestore.instance.app;
          return true;
        } catch (e) {
          return false;
        }
      case 'storage':
        try {
          FirebaseStorage.instance.app;
          return true;
        } catch (e) {
          return false;
        }
      default:
        return false;
    }
  }
  
  // Auth methods
  static Future<UserCredential?> signInWithEmail(String email, String password) async {
    if (!_isFirebaseSupported()) return null;
    try {
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      developer.log('Error signing in with email', name: "FirebaseService", error: "$e");
      return null;
    }
  }
  
  static Future<UserCredential?> createUserWithEmail(
    String email, 
    String password, 
    {String? firstName, 
    String? lastName, 
    String? dateOfBirth}
  ) async {
    if (!_isFirebaseSupported()) return null;
    
    try {
      // Create the user with email and password
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Store additional user data in Firestore if available
      if (userCredential.user != null && (firstName != null || lastName != null || dateOfBirth != null)) {
        final userData = {
          'email': email,
          if (firstName != null) 'firstName': firstName,
          if (lastName != null) 'lastName': lastName,
          if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
          'createdAt': DateTime.now().toIso8601String(),
        };
        
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userData);
      }
      
      return userCredential;
    } catch (e) {
      developer.log('Error creating user', name: "FirebaseService", error: "$e");
      return null;
    }
  }
  
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      developer.log('Starting Google Sign In...', name: "FirebaseService");
      
      if (kIsWeb) {
        // For Web, use Firebase Auth directly with popup
        try {
          developer.log('Using web authentication flow', name: "FirebaseService");
          
          final provider = GoogleAuthProvider();
          provider.addScope('https://www.googleapis.com/auth/userinfo.email');
          provider.addScope('https://www.googleapis.com/auth/userinfo.profile');
          provider.setCustomParameters({
            'prompt': 'select_account'
          });

          return await FirebaseAuth.instance.signInWithPopup(provider);
        } catch (e) {
          developer.log('Web Google Sign In failed', name: "FirebaseService", error: e.toString());
          rethrow;
        }
      } else if (Platform.isWindows) {
        // For Windows desktop, use googleapis_auth for direct OAuth flow
        try {
          developer.log('Using direct OAuth flow for Windows', name: "FirebaseService");
          
          // Use the web client ID since Windows uses the web configuration
          final clientId = '523970252754-kbqbfqumm4ma57o70o4egtihhsoak4jv.apps.googleusercontent.com';
          final scopes = [
            'email',
            'profile',
            'openid',
            'https://www.googleapis.com/auth/userinfo.email',
            'https://www.googleapis.com/auth/userinfo.profile'
          ];

          // Create a local HTTP server for the OAuth callback
          final redirectUrl = 'http://localhost:54433/oauth2callback';
          final server = await HttpServer.bind('localhost', 54433);
          
          developer.log('Local redirect server started at $redirectUrl', name: "FirebaseService");
          
          // Create an OAuth2 client
          final client = await clientViaUserConsent(
            ClientId(clientId, redirectUrl),
            scopes,
            (url) async {
              developer.log('Please open this URL in your browser: $url', name: "FirebaseService");
              await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              
              // Wait for the OAuth response
              await for (final request in server) {
                if (request.uri.path == '/oauth2callback') {
                  request.response.headers.contentType = ContentType.html;
                  request.response.writeln('You can close this window now.');
                  await request.response.close();
                  await server.close();
                  break;
                }
              }
            },
          );

          // Get user info and ID token
          final userInfo = await client.get(Uri.parse('https://www.googleapis.com/oauth2/v1/userinfo'));
          final tokenInfo = await client.get(Uri.parse('https://oauth2.googleapis.com/tokeninfo'));
          
          final userData = jsonDecode(userInfo.body);
          final tokenData = jsonDecode(tokenInfo.body);

          developer.log('Got user info: ${userInfo.body}', name: "FirebaseService");
          developer.log('Got token info: ${tokenInfo.body}', name: "FirebaseService");

          // Create Firebase credential
          final credential = GoogleAuthProvider.credential(
            accessToken: client.credentials.accessToken.data,
            idToken: tokenData['id_token'],
          );

          // Sign in to Firebase with the credential
          final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
          developer.log('Windows authentication successful', name: "FirebaseService");
          return userCredential;
        } catch (e) {
          developer.log('Windows authentication failed', name: "FirebaseService", error: e.toString());
          rethrow;
        }
      } else {
        // Implementation for other platforms (Android, iOS, macOS)
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: [
            'email',
            'profile',
          ],
        );

        // First, try to sign in silently
        GoogleSignInAccount? googleUser;
        try {
          googleUser = await googleSignIn.signInSilently();
          developer.log('Silent sign-in attempt completed', name: "FirebaseService");
        } catch (e) {
          developer.log('Silent sign-in failed, trying interactive', name: "FirebaseService", error: e.toString());
        }

        // If silent sign-in fails, try interactive sign-in
        if (googleUser == null) {
          try {
            googleUser = await googleSignIn.signIn();
            developer.log('Interactive sign-in attempt completed', name: "FirebaseService");
          } catch (e) {
            developer.log('Interactive sign-in failed', name: "FirebaseService", error: e.toString());
            rethrow;
          }
        }

        if (googleUser == null) {
          developer.log('Google Sign In was cancelled by user', name: "FirebaseService");
          return null;
        }

        developer.log('Google Sign In successful: ${googleUser.email}', name: "FirebaseService");

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        developer.log('Got Google Auth tokens', name: "FirebaseService");

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the credential
        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        developer.log('Firebase sign in successful', name: "FirebaseService");
        
        return userCredential;
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error signing in with Google', 
        name: "FirebaseService", 
        error: e.toString(),
        stackTrace: stackTrace
      );
      rethrow;
    }
  }
  
  static Future<void> signOut() async {
    if (!_isFirebaseSupported()) return;
    try {
      await FirebaseAuth.instance.signOut();
      // Also sign out from Google if using Google Sign-In
      await GoogleSignIn().signOut();
    } catch (e) {
      developer.log('Error signing out', name: "FirebaseService", error: "$e");
    }
  }
  
  static User? getCurrentUser() {
    if (!_isFirebaseSupported()) return null;
    return FirebaseAuth.instance.currentUser;
  }
  
  // Firestore methods
  static Future<void> saveUserData(String userId, Map<String, dynamic> data) async {
    if (!_isFirebaseSupported()) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set(
        data,
        SetOptions(merge: true),
      );
    } catch (e) {
      developer.log('Error saving user data', name: "FirebaseService", error: "$e");
    }
  }
  
  static Future<Map<String, dynamic>?> getUserData(String userId) async {
    if (!_isFirebaseSupported()) return null;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      developer.log('Error getting user data', name: "FirebaseService", error: "$e");
      return null;
    }
  }
  
  // Storage methods
  static Future<String?> uploadFile(String path, List<int> bytes, {String? contentType}) async {
    if (!_isFirebaseSupported()) return null;
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      
      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {'uploaded': DateTime.now().toIso8601String()},
      );
      
      await ref.putData(Uint8List.fromList(bytes), metadata);
      return await ref.getDownloadURL();
    } catch (e) {
      developer.log('Error uploading file', name: "FirebaseService", error: "$e");
      return null;
    }
  }
  
  static Future<List<int>?> downloadFile(String path) async {
    if (!_isFirebaseSupported()) return null;
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      final bytes = await ref.getData();
      return bytes;
    } catch (e) {
      developer.log('Error downloading file', name: "FirebaseService", error: "$e");
      return null;
    }
  }
  
  // For Windows/Linux, implement alternative solutions
  static Future<bool> signInWithEmailAlternative(String email, String password) async {
    // This would be your Windows/Linux implementation
    // Could use local storage, REST API calls, etc.
    return true; // Mock success for now
  }
  
  static Future<bool> createUserWithEmailAlternative(
    String email, 
    String password, 
    {String? firstName, 
    String? lastName, 
    String? dateOfBirth}
  ) async {
    // Windows/Linux implementation
    return true; // Mock success for now
  }
  
  static Future<Map<String, dynamic>?> getUserDataAlternative(String userId) async {
    // Windows/Linux implementation
    return {
      'email': 'user@example.com',
      'firstName': 'Test',
      'lastName': 'User',
    };
  }
}