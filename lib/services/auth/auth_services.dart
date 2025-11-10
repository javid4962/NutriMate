import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // 🟢 Sign Up with Email & Password + Send Verification Email
  // 🟢 Sign Up with Email & Password + Send Verification Email
  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        // Send verification email
        await user.sendEmailVerification();
        print("✅ Verification email sent to ${user.email}");

        // Create Firestore user document immediately
        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        await userDoc.set({
          'uid': user.uid,
          'email': user.email,
          'isEmailVerified': user.emailVerified, // false at this stage
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        }, SetOptions(merge: true));
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // 🟠 Sign In with Email & Password + Verification Check
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      // ✅ Force refresh user state
      await userCredential.user?.reload();
      final refreshedUser = _firebaseAuth.currentUser;

      if (refreshedUser != null && refreshedUser.emailVerified) {
        // Update Firestore flag
        await FirebaseFirestore.instance
            .collection('users')
            .doc(refreshedUser.uid)
            .update({'isEmailVerified': true});
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }


  // 🟣 Check if current user is verified
  Future<bool> isEmailVerified() async {
    User? user = _firebaseAuth.currentUser;
    await user?.reload();
    return user?.emailVerified ?? false;
  }

  // 🔴 Sign Out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      print("✅ User signed out successfully");
    } catch (e) {
      throw Exception("Error signing out: ${e.toString()}");
    }
  }

  // 🧠 Error Mapper
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return "Invalid email format.";
      case 'user-disabled':
        return "This user account has been disabled.";
      case 'user-not-found':
        return "No user found with this email.";
      case 'wrong-password':
        return "Incorrect password.";
      case 'email-already-in-use':
        return "This email is already registered.";
      case 'weak-password':
        return "Password should be at least 6 characters.";
      default:
        return "Authentication error: ${e.message}";
    }
  }
}
