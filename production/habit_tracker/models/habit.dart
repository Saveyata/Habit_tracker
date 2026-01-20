class Habit {
  final String name;
  final String icon;
  final String frequency;
  bool completedToday;
  int streak; // add this

  Habit({
    required this.name,
    required this.icon,
    required this.frequency,
    this.completedToday = false,
    this.streak = 0, // default 0
  });
}
