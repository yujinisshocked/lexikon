import 'package:flutter/material.dart';

class FinancialTrackerPage extends StatelessWidget {
  const FinancialTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Tracker'),
      ),
      body: const Center(
        child: Text('Financial Tracker Page'),
      ),
    );
  }
}