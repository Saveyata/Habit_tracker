import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit_tracker/utils/theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool loading = false;

  /// Firebase sends reset email
  Future<void> _sendResetEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter your email")));
      return;
    }

    setState(() => loading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password reset email sent. Check your inbox."),
        ),
      );

      Navigator.pop(context); // back to login
    } on FirebaseAuthException catch (e) {
      String message = "Something went wrong";

      if (e.code == 'user-not-found') {
        message = "No account found for this email";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email address";
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _logo(),
            const SizedBox(height: 24),
            _input("Email", controller: emailController),
            const SizedBox(height: 12),
            _gradientButton("Send Reset Link", _sendResetEmail),
          ],
        ),
      ),
    );
  }

  Widget _logo() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [primary, Color(0xFF8F8CFF)]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Icon(Icons.lock_reset, size: 50, color: Colors.white),
    );
  }

  Widget _input(String hint, {TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _gradientButton(String text, VoidCallback onTap) {
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [primary, Color(0xFF8F8CFF)]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: loading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
        ),
      ),
    );
  }
}
