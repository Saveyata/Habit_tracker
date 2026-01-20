// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ---------------- SIGNUP ----------------
  static Future<User?> signup(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Signup failed";
    }
  }

  // ---------------- LOGIN ----------------
  static Future<User?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Login failed";
    }
  }

  // ---------------- LOGOUT ----------------
  static Future<void> logout() async {
    await _auth.signOut();
  }

  // ---------------- CHECK CURRENT USER ----------------
  static User? get currentUser => _auth.currentUser;

  // ---------------- CHECK IF LOGGED IN ----------------
  static Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  // ---------------- PASSWORD RESET ----------------
  static Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ---------------- UPDATE PASSWORD ----------------
  static Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    } else {
      throw "No logged-in user";
    }
  }
}
