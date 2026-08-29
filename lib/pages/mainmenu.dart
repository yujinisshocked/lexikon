import 'package:flutter/material.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  // List of features with their respective icons and labels
  final List<Map<String, dynamic>> features = [
    {'icon': Icons.note, 'label': 'Note Taking', 'route': '/note-list'},
    {'icon': Icons.track_changes, 'label': 'Habit Tracking', 'route': '/habit-tracking'},
    {'icon': Icons.schedule, 'label': 'Scheduling', 'route': '/scheduling'},
    {'icon': Icons.checklist, 'label': 'To-Do List', 'route': '/todo-list'},
    {'icon': Icons.shopping_cart, 'label': 'Shopping List', 'route': '/shopping-list'},
    {'icon': Icons.calculate, 'label': 'Budget Calculator', 'route': '/budget-calculator'},
    {'icon': Icons.monetization_on, 'label': 'Financial Tracker', 'route': '/financial-tracker'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
              // Handle feature navigation
              final route = features[index]['route'];
                Navigator.pushNamed(context, route);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  features[index]['icon'],
                  size: 40.0,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 8.0),
                Text(
                  features[index]['label'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14.0),
                ),
              ],
        ),
    );
        },
      ),
    );
  }
}

