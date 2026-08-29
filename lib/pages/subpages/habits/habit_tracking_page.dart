import 'package:flutter/material.dart';

class HabitTrackingPage extends StatelessWidget {
  const HabitTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracking'),
      ),
      body: const Center(
        child: Text('Habit Tracking Page'),
      ),
    );
  }
}