import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../firebase_options.dart';

class FirebaseService {
  static bool _initialized = false;
  
  static Future<void> initialize() async {
    if (_isFirebaseSupported()) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        _initialized = true;
        print("Firebase initialized successfully for ${_getPlatformName()}");
      } catch (e) {
        print("Failed to initialize Firebase for ${_getPlatformName()}: $e");
        // We'll still continue, but with degraded functionality
      }
    } else {
      print("Firebase not fully supported on ${_getPlatformName()}, using alternative implementations");
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
    // Firebase is supported on Android, iOS, Web, macOS
    // It has limited/problematic support on Windows/Linux
    return kIsWeb || Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
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
      print('Error signing in with email: $e');
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
      print('Error creating user: $e');
      return null;
    }
  }
  
  static Future<UserCredential?> signInWithGoogle() async {
    if (!_isFirebaseSupported()) return null;
    
    try {
      // Google Sign-In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }
  
  static Future<void> signOut() async {
    if (!_isFirebaseSupported()) return;
    try {
      await FirebaseAuth.instance.signOut();
      // Also sign out from Google if using Google Sign-In
      await GoogleSignIn().signOut();
    } catch (e) {
      print('Error signing out: $e');
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
      print('Error saving user data: $e');
    }
  }
  
  static Future<Map<String, dynamic>?> getUserData(String userId) async {
    if (!_isFirebaseSupported()) return null;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('Error getting user data: $e');
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
      print('Error uploading file: $e');
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
      print('Error downloading file: $e');
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