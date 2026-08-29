import 'package:flutter/material.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  // List of features with their respective icons and labels
  final List<Map<String, dynamic>> features = [
    {'icon': Icons.note, 'label': 'Note Taking'},
    {'icon': Icons.track_changes, 'label': 'Habit Tracking'},
    {'icon': Icons.schedule, 'label': 'Scheduling'},
    {'icon': Icons.checklist, 'label': 'To-Do List'},
    {'icon': Icons.shopping_cart, 'label': 'Shopping List'},
    {'icon': Icons.calculate, 'label': 'Budget Calculator'},
    {'icon': Icons.monetization_on, 'label': 'Financial Tracker'},
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
                // TODO: Handle feature navigation here
              debugPrint('${features[index]['label']} tapped');
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

