class Habit {
  String? id;
  final String name;
  final String icon;
  final String frequency;
  bool completedToday;
  int streak;
  List<DateTime> history; // new field for completed dates

  Habit({
    this.id,
    required this.name,
    required this.icon,
    required this.frequency,
    this.completedToday = false,
    this.streak = 0,
    List<DateTime>? history,
  }) : history = history ?? [];

  /// Convert to map for Firebase storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'frequency': frequency,
      'completedToday': completedToday,
      'streak': streak,
      'history': history.map((d) => d.toIso8601String()).toList(),
    };
  }

  /// Convert from Firebase map
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'] ?? '',
      icon: map['icon'] ?? 'star',
      frequency: map['frequency'] ?? 'daily',
      completedToday: map['completedToday'] ?? false,
      streak: map['streak'] ?? 0,
      history: map['history'] != null
          ? List<String>.from(
              map['history'],
            ).map((d) => DateTime.parse(d)).toList()
          : [],
    );
  }

  /// Mark today as complete
  void markComplete() {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    // Add to history if not already done
    if (!history.any((d) => d.isAtSameMomentAs(today))) {
      history.add(today);
    }

    completedToday = true;

    // Update streak
    if (history.length >= 2) {
      final yesterday = today.subtract(const Duration(days: 1));
      if (history.any((d) => d.isAtSameMomentAs(yesterday))) {
        streak += 1; // consecutive day
      } else {
        streak = 1; // reset streak
      }
    } else {
      streak = 1;
    }
  }

  /// Reset completedToday flag (call at midnight)
  void resetDay() {
    completedToday = false;
  }

  /// Check if completed on a specific date
  bool isCompletedOn(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return history.any(
      (h) => h.year == d.year && h.month == d.month && h.day == d.day,
    );
  }

  /// Get progress for current week (0 to 1)
  double weeklyProgress() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1)); // Monday
    final completedDays = history
        .where((d) => d.isAfter(weekStart.subtract(const Duration(days: 1))))
        .length;
    return completedDays / 7;
  }
}
