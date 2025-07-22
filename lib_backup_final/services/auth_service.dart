import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseService _databaseService = DatabaseService();
  
  User? get user => _auth.currentUser;
  
  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      notifyListeners();
    });
  }

  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword(
    String email, 
    String password, 
    String name
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      if (user != null) {
        UserModel userModel = UserModel(
          uid: user.uid,
          email: email,
          name: name,
          createdAt: DateTime.now(),
          isProfileComplete: false, // Profile setup required
        );
        
        // Create user profile in Firestore
        await _databaseService.createUserProfile(userModel.toMap());
        
        print('✅ User registered successfully: $email');
        return userModel;
      }
    } catch (e) {
      print('Registration error: $e');
      throw e; // Throw error to handle in UI
    }
    return null;
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(
    String email, 
    String password
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      if (user != null) {
        // Get user profile from Firestore
        final userData = await _databaseService.getUserProfile(user.uid);
        if (userData != null) {
          print('✅ User signed in successfully: $email');
          return UserModel.fromMap(userData);
        }
      }
    } catch (e) {
      print('Sign in error: $e');
      throw e; // Throw error to handle in UI
    }
    return null;
  }

  // Get current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      if (_auth.currentUser != null) {
        final userData = await _databaseService.getUserProfile(_auth.currentUser!.uid);
        if (userData != null) {
          return UserModel.fromMap(userData);
        }
      }
    } catch (e) {
      print('Error getting current user profile: $e');
    }
    return null;
  }

  // Update user profile
  Future<bool> updateUserProfile(UserModel userModel) async {
    try {
      await _databaseService.updateUserProfile(userModel.toMap(), userModel.uid);
      print('✅ User profile updated successfully');
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Check if user profile is complete
  Future<bool> isProfileComplete() async {
    try {
      if (_auth.currentUser != null) {
        final userData = await _databaseService.getUserProfile(_auth.currentUser!.uid);
        if (userData != null) {
          return userData['isProfileComplete'] ?? false;
        }
      }
    } catch (e) {
      print('Error checking profile completion: $e');
    }
    return false;
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent to: $email');
      return true;
    } catch (e) {
      print('Password reset error: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('✅ User signed out successfully');
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // Delete account (with confirmation)
  Future<bool> deleteAccount(String password) async {
    try {
      User? user = _auth.currentUser;
      if (user != null && user.email != null) {
        // Re-authenticate before deletion
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        
        await user.reauthenticateWithCredential(credential);
        
        // Delete user data from Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        
        // Delete user account
        await user.delete();
        
        print('✅ User account deleted successfully');
        return true;
      }
    } catch (e) {
      print('Account deletion error: $e');
    }
    return false;
  }

  // Get authentication error message
  String getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  // Check if email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Send email verification
  Future<bool> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        print('✅ Email verification sent');
        return true;
      }
    } catch (e) {
      print('Email verification error: $e');
    }
    return false;
  }

  // Reload user to get updated verification status
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
      notifyListeners();
    } catch (e) {
      print('Error reloading user: $e');
    }
  }
}