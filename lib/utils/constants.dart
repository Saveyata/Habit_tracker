import 'package:flutter/material.dart';
import 'package:habit_tracker/screens/login_screen.dart';
import 'package:habit_tracker/screens/signup_screen.dart';
import 'package:habit_tracker/screens/forgot_password_screen.dart';
import 'package:habit_tracker/screens/habit_dashboard.dart';
import 'package:habit_tracker/screens/create_habit_screen.dart';

Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const LoginScreen(),
  '/signup': (context) => const SignupScreen(),
  '/forgot': (context) => const ForgotPasswordScreen(),
  '/dashboard': (context) => const DashboardScreen(),
  '/create': (context) => const CreateHabitScreen(),
};
