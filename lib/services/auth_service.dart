import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:innerfive/models/user_data.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to listen to auth changes
  Stream<User?> get user => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign Up with Email and Password
  Future<User?> signUpAndCreateProfile({
    required String email,
    required String password,
    required UserData userData,
  }) async {
    try {
      // 1. Create user in Firebase Auth
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      final User? user = userCredential.user;

      if (user != null) {
        final displayName =
            '${userData.firstName ?? ''} ${userData.lastName ?? ''}'.trim();

        // 2. Update Firebase Auth profile
        await user.updateDisplayName(displayName);

        // 3. Create user document in Firestore with ALL data at once
        final Map<String, dynamic> userProfileData = {
          'uid': user.uid,
          'email': user.email,
          'nickname': userData.nickname,
          'displayName': displayName,
          'birthDate': '${userData.year}-${userData.month}-${userData.day}',
          'birthTime': '${userData.hour}:${userData.minute}',
          'gender': userData.gender?.toString().split('.').last,
          'city': userData.city,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        };

        await _firestore.collection('users').doc(user.uid).set(userProfileData);

        await user.reload();
        return _auth.currentUser;
      }
      return null;
    } catch (e) {
      print("Sign Up Error: $e");
      return null;
    }
  }

  // A simpler sign-up for creating an account without the full user data immediately.
  Future<Map<String, dynamic>> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        // Create a minimal user document in Firestore.
        // The full profile can be added later, e.g., via updateUserProfile.
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
        return {
          'success': true,
          'user': user,
          'message': 'Account created successfully'
        };
      }
      return {
        'success': false,
        'user': null,
        'message': 'Unknown error occurred'
      };
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Sign Up Error: ${e.code} - ${e.message}");
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage =
              'The password is too weak. Please use at least 6 characters.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email address.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        default:
          errorMessage = 'Sign up failed: ${e.message}';
      }
      return {'success': false, 'user': null, 'message': errorMessage};
    } catch (e) {
      print("General Sign Up Error: $e");
      return {
        'success': false,
        'user': null,
        'message': 'An unexpected error occurred. Please try again.'
      };
    }
  }

  // Sign In with Email and Password
  Future<Map<String, dynamic>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      final User? user = userCredential.user;

      if (user != null) {
        // Update last login time
        await _firestore.collection('users').doc(user.uid).set({
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return {'success': true, 'user': user, 'message': 'Sign in successful'};
      }
      return {
        'success': false,
        'user': null,
        'message': 'Unknown error occurred'
      };
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Sign In Error: ${e.code} - ${e.message}");
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email address.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage =
              'Too many failed login attempts. Please try again later.';
          break;
        case 'invalid-credential':
          errorMessage =
              'Invalid email or password. Please check your credentials.';
          break;
        default:
          errorMessage = 'Sign in failed: ${e.message}';
      }
      return {'success': false, 'user': null, 'message': errorMessage};
    } catch (e) {
      print("General Sign In Error: $e");
      return {
        'success': false,
        'user': null,
        'message': 'An unexpected error occurred. Please try again.'
      };
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      print('로그아웃 시작...');
      await _auth.signOut();
      print('로그아웃 완료');
      notifyListeners(); // Provider에게 상태 변경 알림
    } catch (e) {
      print('로그아웃 오류: $e');
      throw Exception('로그아웃 중 오류가 발생했습니다: $e');
    }
  }

  // Update user profile data in Firestore
  Future<void> updateUserProfile(String userId, UserData userData) async {
    final displayName =
        '${userData.firstName ?? ''} ${userData.lastName ?? ''}'.trim();

    final Map<String, dynamic> profileData = {
      'nickname': userData.nickname,
      'displayName': displayName,
      'birthDate': '${userData.year}-${userData.month}-${userData.day}',
      'birthTime': '${userData.hour}:${userData.minute}',
      'gender': userData.gender?.toString().split('.').last,
      'city': userData.city,
    };
    // Also update the Firebase Auth profile display name
    final user = _auth.currentUser;
    if (user != null && user.displayName != displayName) {
      await user.updateDisplayName(displayName);
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .set(profileData, SetOptions(merge: true));
  }

  // Get user profile data from Firestore
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final docSnapshot =
            await _firestore.collection('users').doc(user.uid).get();
        if (docSnapshot.exists) {
          return docSnapshot.data();
        }
      } catch (e) {
        print("Error getting user profile: $e");
        return null;
      }
    }
    return null;
  }

  // Helper to save user analysis data
  Future<void> saveUserData(String userId, Map<String, dynamic> data) async {
    try {
      print("Attempting to save user data for user: $userId");
      print("Data keys: ${data.keys.toList()}");

      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('readings')
          .add({
        'timestamp': FieldValue.serverTimestamp(),
        'userInput': data['userInput'],
        'report': data['report'],
      });

      print("Successfully saved data with document ID: ${docRef.id}");
    } catch (e, stackTrace) {
      print("Error saving user data: $e");
      print("Stack trace: $stackTrace");
      rethrow;
    }
  }

  Future<void> deleteUserAccount(String password) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in.');
    }

    try {
      // Re-authenticate the user
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(cred);

      // After successful re-authentication, delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Finally, delete the user from Firebase Authentication
      await user.delete();

      print('User account deleted successfully.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Incorrect password. Please try again.');
      } else {
        throw Exception(
            'An error occurred while deleting your account: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
