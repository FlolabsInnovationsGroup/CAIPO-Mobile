import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'dart:developer' as developer;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn;

  AuthService() {
    // Only specify clientId for web or Windows platforms
    _googleSignIn = GoogleSignIn(
      clientId: kIsWeb || Platform.isWindows ? 
        '523970252754-itgqfajnln8go2oht0jp07h9i5kk8jt6.apps.googleusercontent.com' : null,
      scopes: [
        'email',
        'profile',
      ],
    );
    developer.log('GoogleSignIn initialized', name: 'AuthService');
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      developer.log('Starting Google Sign In process', name: 'AuthService');
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        developer.log('Google Sign In was cancelled by user', name: 'AuthService');
        return null;
      }

      developer.log('Google Sign In successful for user: ${googleUser.email}', name: 'AuthService');
      developer.log('User ID: ${googleUser.id}', name: 'AuthService');
      developer.log('Display Name: ${googleUser.displayName}', name: 'AuthService');
      
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      developer.log('Got Google Auth tokens', name: 'AuthService');
      developer.log('Access Token available: ${googleAuth.accessToken != null}', name: 'AuthService');
      developer.log('ID Token available: ${googleAuth.idToken != null}', name: 'AuthService');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      developer.log('Created Firebase credential', name: 'AuthService');

      // Sign in to Firebase with the credential
      developer.log('Attempting to sign in with Firebase using Google credential', name: 'AuthService');
      final userCredential = await _auth.signInWithCredential(credential);
      developer.log('Firebase sign-in completed', name: 'AuthService');
      developer.log('User UID: ${userCredential.user?.uid}', name: 'AuthService');
      developer.log('User email verified: ${userCredential.user?.emailVerified}', name: 'AuthService');
      developer.log('User display name: ${userCredential.user?.displayName}', name: 'AuthService');
      
      // Check if the user is actually signed in
      final currentUser = _auth.currentUser;
      developer.log('Current Firebase user after sign-in: ${currentUser?.uid}', name: 'AuthService');
      
      return userCredential;
    } catch (e, stackTrace) {
      developer.log('Error signing in with Google: $e', name: 'AuthService', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      developer.log('User signed out successfully', name: 'AuthService');
    } catch (e) {
      developer.log('Error signing out: $e', name: 'AuthService', error: e);
    }
  }
} 