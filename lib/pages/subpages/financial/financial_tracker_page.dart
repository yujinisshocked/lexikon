import 'package:flutter/material.dart';

class FinancialTrackerPage extends StatefulWidget {
  const FinancialTrackerPage({super.key});

  @override
  State<FinancialTrackerPage> createState() => _FinancialTrackerPageState();
}

class _FinancialTrackerPageState extends State<FinancialTrackerPage> {

  // Temp records

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Tracker'),
      ),

      // List of cash flow
      body: ListView.builder(
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          return Container();
        },
      ),

      floatingActionButton: IconButton(onPressed: () {}, icon: Icon(Icons.add)),
    );
  }
}