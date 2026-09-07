import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  // These are our connections to Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // This watches login state — if user logs in or out, app knows instantly
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── REGISTER ───────────────────────────────────────────────
  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // Step 1: Create account in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Step 2: Get the unique ID Firebase gave this user
      String uid = result.user!.uid;

      // Step 3: Build our UserModel with all the details
      UserModel newUser = UserModel(
        uid: uid,
        name: name,
        email: email,
        role: role,
        createdAt: DateTime.now(),
      );

      // Step 4: Save user details to Firestore database
      await _firestore.collection('users').doc(uid).set(newUser.toMap());

      return null; // null means success — no error
    } catch (e) {
      return e.toString(); // return the error message
    }
  }

  // ─── LOGIN ──────────────────────────────────────────────────
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // null means success
    } catch (e) {
      return _friendlyError(e.toString());
    }
  }

  // ─── LOGOUT ─────────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ─── GET CURRENT USER DATA ──────────────────────────────────
  Future<UserModel?> getCurrentUserData() async {
    try {
      String? uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ─── FRIENDLY ERROR MESSAGES ────────────────────────────────
  String _friendlyError(String error) {
    if (error.contains('user-not-found')) {
      return 'No account found with this email.';
    } else if (error.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (error.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (error.contains('user-disabled')) {
      return 'This account has been disabled.';
    } else if (error.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }
}
