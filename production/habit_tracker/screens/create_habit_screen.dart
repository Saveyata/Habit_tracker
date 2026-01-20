import 'package:flutter/material.dart';
import 'package:habit_tracker/models/habit.dart';

class CreateHabitScreen extends StatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final TextEditingController habitController = TextEditingController();

  String selectedIcon = 'water';
  String frequency = 'daily';

  final List<Map<String, dynamic>> habitIcons = [
    {'key': 'water', 'icon': Icons.water_drop, 'label': 'Water'},
    {'key': 'exercise', 'icon': Icons.fitness_center, 'label': 'Exercise'},
    {'key': 'reading', 'icon': Icons.menu_book, 'label': 'Reading'},
    {'key': 'coffee', 'icon': Icons.coffee, 'label': 'Coffee'},
    {'key': 'sleep', 'icon': Icons.bed, 'label': 'Sleep'},
    {'key': 'health', 'icon': Icons.favorite, 'label': 'Health'},
    {'key': 'cycling', 'icon': Icons.directions_bike, 'label': 'Cycling'},
    {'key': 'nutrition', 'icon': Icons.apple},
    {'key': 'music', 'icon': Icons.music_note},
    {'key': 'art', 'icon': Icons.brush},
    {'key': 'photo', 'icon': Icons.camera_alt},
  ];

  @override
  void dispose() {
    habitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create New Habit")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Habit Name",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: habitController,
              decoration: InputDecoration(
                hintText: "e.g. Drink water",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Choose an Icon",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: habitIcons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final item = habitIcons[index];
                final isSelected = selectedIcon == item['key'];

                return GestureDetector(
                  onTap: () => setState(() => selectedIcon = item['key']),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                      ),
                    ),
                    child: Icon(item['icon'], color: Colors.blue),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            const Text(
              "Frequency",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            _frequencyTile("Daily", "daily", "+10 pts"),
            _frequencyTile("Weekly", "weekly", "+20 pts"),

            const SizedBox(height: 30),

            /// 🔥 CREATE HABIT BUTTON (WORKING)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _createHabit,
                child: const Text(
                  "Create Habit",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createHabit() {
    if (habitController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter habit name")));
      return;
    }

    final habit = Habit(
      name: habitController.text.trim(),
      icon: selectedIcon,
      frequency: frequency,
    );

    Navigator.pop(context, habit); // 🔥 RETURN TO DASHBOARD
  }

  Widget _frequencyTile(String title, String value, String points) {
    final isSelected = frequency == value;

    return GestureDetector(
      onTap: () => setState(() => frequency = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: frequency,
              onChanged: (_) => setState(() => frequency = value),
            ),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(points, style: const TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}
