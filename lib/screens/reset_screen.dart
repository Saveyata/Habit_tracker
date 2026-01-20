import 'package:flutter/material.dart';
import 'package:habit_tracker/screens/login_screen.dart';
import 'package:habit_tracker/utils/theme.dart';
import 'package:habit_tracker/screens/auth_screen.dart'; // your Firebase AuthService

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  bool loading = false;

  void _resetPassword() async {
    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => loading = true);

    try {
      await AuthService.updatePassword(
        password,
      ); // Firebase version throws exception if fails
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password updated successfully")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update password: $e")));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _logo(),
            const SizedBox(height: 24),
            _input(
              "New Password",
              controller: passwordController,
              isPass: true,
            ),
            const SizedBox(height: 12),
            _input(
              "Confirm Password",
              controller: confirmController,
              isPass: true,
            ),
            const SizedBox(height: 12),
            _gradientButton("Reset Password", _resetPassword),
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

  Widget _input(
    String hint, {
    TextEditingController? controller,
    bool isPass = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
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
