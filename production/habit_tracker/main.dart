import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:io';

import 'package:habit_tracker/screens/habit_dashboard.dart';
import 'package:habit_tracker/screens/login_screen.dart';
import 'package:habit_tracker/screens/signup_screen.dart';
import 'package:habit_tracker/screens/forgot_password_screen.dart';
import 'package:habit_tracker/screens/auth_screen.dart';
import 'package:habit_tracker/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!Platform.isWindows) {
    await Firebase.initializeApp();
  }
  runApp(const HabitApp());
}

class HabitApp extends StatelessWidget {
  const HabitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      routes: {
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/forgot': (_) => const ForgotPasswordScreen(),
      },
      home: const Root(),
    );
  }
}

/// Checks auth state
class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  bool? loggedIn;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  void _checkLogin() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    setState(() {
      loggedIn = isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loggedIn == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return loggedIn! ? const DashboardScreen() : const LoginScreen();
  }
}
