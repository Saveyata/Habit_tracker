import 'package:flutter/material.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/screens/create_habit_screen.dart';
import 'package:habit_tracker/utils/theme.dart';
import 'package:habit_tracker/screens/auth_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Habit> habits = [];
  int xp = 0;
  int level = 1;
  DateTime? lastUpdated;

  final List<String> motivationalMessages = [
    "Awesome! Keep it going! 🚀",
    "You're unstoppable! 💪",
    "Another step to success! 🌟",
    "Consistency is key! 🔑",
    "Way to crush it today! 🎯",
  ];

  // Use real AuthService info
  String userName = "";
  String userEmail = "";

  @override
  void initState() {
    super.initState();
    _listenAuth();
  }

  // ---------------- INITIALIZE DASHBOARD ----------------
  void _listenAuth() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (!mounted) return;

      if (user == null) {
        // User not logged in -> go to login screen
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        // User is logged in -> load habits
        setState(() {
          userName = user.displayName ?? "User";
          userEmail = user.email ?? "";
        });

        await _loadHabits();
        _resetHabitsIfNewDay();
      }
    });
  }

  // ---------------- LOAD HABITS FROM FIRESTORE ----------------
  Future<void> _loadHabits() async {
    final user = AuthService.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .get();

      final loadedHabits = snapshot.docs.map((doc) {
        return Habit.fromMap(doc.data())..id = doc.id;
      }).toList();

      setState(() {
        habits = loadedHabits;
        lastUpdated = DateTime.now();
      });
    }
  }

  // ---------------- RESET DAILY HABITS ----------------
  void _resetHabitsIfNewDay() {
    final now = DateTime.now();
    if (lastUpdated == null ||
        lastUpdated!.year != now.year ||
        lastUpdated!.month != now.month ||
        lastUpdated!.day != now.day) {
      setState(() {
        for (var habit in habits) {
          habit.completedToday = false;
        }
        lastUpdated = now;
      });
    }
  }

  // ---------------- LOGOUT ----------------
  void _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  // ---------------- SHOW PROFILE ----------------
  void _showProfile() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: primary,
              child: Text(
                userName.isNotEmpty ? userName[0] : "?",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(userEmail, style: const TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  // ---------------- SHOW SETTINGS ----------------
  void _showSettings() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Settings"),
        content: const Text("Customize your app settings here."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  // ---------------- MARK HABIT DONE ----------------
  void _markHabitDone(Habit habit) async {
    if (!habit.completedToday) {
      setState(() {
        habit.completedToday = true;
        habit.streak += 1;
        xp += 10;
        if (xp ~/ 100 + 1 > level) {
          level += 1;
          _showLevelUpDialog();
        }
      });

      final user = AuthService.currentUser;
      if (user != null && habit.id != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('habits')
            .doc(habit.id)
            .update(habit.toMap());
      }

      final msg = (motivationalMessages..shuffle()).first;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showLevelUpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Level Up! 🎉"),
        content: Text("Congratulations! You've reached Level $level."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // ---------------- OPEN CREATE HABIT ----------------
  Future<void> _openCreateHabit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateHabitScreen()),
    );

    if (result != null && result is Habit) {
      setState(() => habits.add(result));

      final user = AuthService.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('habits')
            .add(result.toMap());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = (xp % 100) / 100;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/habit_hero.png', height: 36, width: 36),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Habit Hero",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  "Build better habits, level up your life",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<int>(
            icon: CircleAvatar(
              backgroundColor: primary,
              child: Text(
                userName.isNotEmpty ? userName[0] : "?",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            onSelected: (value) {
              switch (value) {
                case 0:
                  _showProfile();
                  break;
                case 1:
                  _showSettings();
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // LEVEL CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Level $level",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _pointsChip("$xp pts"),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text("Progress to Next Level"),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    color: primary,
                    backgroundColor: const Color(0xFFE0E0FF),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${xp % 100} / 100 XP",
                    style: const TextStyle(color: Color(0xFF7A7A7A)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // HABITS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Your Habits",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _openCreateHabit,
                  icon: const Icon(Icons.add),
                  label: const Text("Add"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            habits.isEmpty ? _emptyHabitsCard() : _habitsList(),
          ],
        ),
      ),
    );
  }

  // ---------------- POINT CHIP ----------------
  Widget _pointsChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: primary, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ---------------- EMPTY HABITS ----------------
  Widget _emptyHabitsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.star_border, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            "No habits yet",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "Create your first habit to get started",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _gradientButton(text: "Add New Habit", onTap: _openCreateHabit),
        ],
      ),
    );
  }

  // ---------------- HABITS LIST ----------------
  Widget _habitsList() {
    return Column(
      children: habits.map((habit) {
        return GestureDetector(
          onTap: () => _markHabitDone(habit),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: primary.withOpacity(0.15),
                  child: Icon(_getIcon(habit.icon), color: primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        habit.frequency,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "Streak: ${habit.streak} 🔥",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                Checkbox(
                  value: habit.completedToday,
                  onChanged: (_) => _markHabitDone(habit),
                  activeColor: primary,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------------- GRADIENT BUTTON ----------------
  Widget _gradientButton({required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [primary, Color(0xFF8F8CFF)]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- ICON MAPPER ----------------
  IconData _getIcon(String key) {
    switch (key) {
      case 'water':
        return Icons.water_drop;
      case 'exercise':
        return Icons.fitness_center;
      case 'reading':
        return Icons.menu_book;
      case 'coffee':
        return Icons.coffee;
      case 'sleep':
        return Icons.bed;
      case 'health':
        return Icons.favorite;
      default:
        return Icons.star;
    }
  }
}
