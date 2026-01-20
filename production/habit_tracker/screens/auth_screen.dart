import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth? _auth = Platform.isWindows
      ? null
      : FirebaseAuth.instance;

  // ---------------- SIGNUP ----------------
  static Future<User?> signup(String email, String password) async {
    if (Platform.isWindows) {
      throw "Authentication is disabled on Windows";
    }

    try {
      final cred = await _auth!.createUserWithEmailAndPassword(
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
    if (Platform.isWindows) {
      throw "Authentication is disabled on Windows";
    }

    try {
      final cred = await _auth!.signInWithEmailAndPassword(
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
    if (Platform.isWindows) return;
    await _auth!.signOut();
  }

  // ---------------- CHECK IF LOGGED IN ----------------
  static User? get currentUser =>
      Platform.isWindows ? null : _auth!.currentUser;

  static bool isLoggedIn() {
    if (Platform.isWindows) return false;
    return _auth!.currentUser != null;
  }

  // ---------------- PASSWORD RESET ----------------
  static Future<void> sendPasswordResetEmail(String email) async {
    if (Platform.isWindows) {
      throw "Password reset is disabled on Windows";
    }

    try {
      await _auth!.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Password reset failed";
    }
  }

  // ---------------- UPDATE PASSWORD ----------------
  static Future<void> updatePassword(String newPassword) async {
    if (Platform.isWindows) {
      throw "Password update is disabled on Windows";
    }

    try {
      final user = _auth!.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      } else {
        throw "No logged-in user";
      }
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Password update failed";
    }
  }
}
