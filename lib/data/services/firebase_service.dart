import 'dart:io';
import 'dart:typed_data';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/firebase_options.dart';

class FirebaseService {
  static bool _initialized = false;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  
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
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Error signing in with email: $e');
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
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName('$firstName $lastName');
        // You could store additional user data in Firestore here
      }
      
      return userCredential;
    } catch (e) {
      debugPrint('Error creating user: $e');
      return null;
    }
  }
  
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      return null;
    }
  }
  
  static Future<void> signOut() async {
    if (!_isFirebaseSupported()) return;
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      debugPrint('Error signing out: $e');
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