import 'package:flutter/material.dart';
import 'package:habit_tracker/screens/profile_screen.dart';
import 'package:habit_tracker/screens/settings_screen.dart';
import 'package:habit_tracker/utils/theme.dart';
import '../screens/auth_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userEmail = '';
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    final user = AuthService.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email ?? '';
        userName = user.email?.split('@')[0] ?? 'User';
      });
    }
  }

  void _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: primary,
        actions: [
          PopupMenuButton<int>(
            icon: CircleAvatar(
              backgroundColor: primary,
              child: Text(
                userName.isNotEmpty ? userName[0] : "U",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            onSelected: (value) {
              switch (value) {
                case 0:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                  break;
                case 1:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                  break;
                case 2:
                  _logout();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: -1,
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(userEmail, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 0, child: Text("Profile")),
              const PopupMenuItem(value: 1, child: Text("Settings")),
              const PopupMenuItem(value: 2, child: Text("Logout")),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: const Center(child: Text("Welcome to Dashboard")),
    );
  }
}
