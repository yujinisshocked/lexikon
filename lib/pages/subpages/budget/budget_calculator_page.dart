import 'package:flutter/material.dart';

class BudgetCalculatorPage extends StatelessWidget {
  const BudgetCalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Calculator'),
      ),
      body: const Center(
        child: Text('Budget Calculator Page'),
      ),
    );
  }
}