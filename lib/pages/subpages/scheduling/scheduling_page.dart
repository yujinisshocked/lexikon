import 'package:flutter/material.dart';

class SchedulingPage extends StatelessWidget {
  const SchedulingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduling'),
      ),
      body: const Center(
        child: Text('Scheduling Page'),
      ),
    );
  }
}