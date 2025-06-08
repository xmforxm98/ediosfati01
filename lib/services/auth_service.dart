import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:innerfive/models/user_data.dart';

class AuthService {
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
  Future<User?> signUpWithEmailAndPassword(
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
      }
      return user;
    } catch (e) {
      print("Simple Sign Up Error: $e");
      return null;
    }
  }

  // Sign In with Email and Password
  Future<User?> signInWithEmailAndPassword(
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
      }
      return user;
    } catch (e) {
      print("Sign In Error: $e");
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Update user profile data in Firestore
  Future<void> updateUserProfile(String userId, UserData userData) async {
    final displayName =
        '${userData.firstName ?? ''} ${userData.lastName ?? ''}'.trim();

    final Map<String, dynamic> profileData = {
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
}
