import 'package:flutter/material.dart';
import '../screens/auth_screen.dart';
import '../utils/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), backgroundColor: primary),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: primary,
              child: Text(
                user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(color: Colors.white, fontSize: 40),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              user?.email ?? "No Email",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            Text(
              "User UID: ${user?.uid ?? "N/A"}",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
