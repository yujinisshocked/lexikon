import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lexikon/mainview.dart';

void main() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Open Hive boxes
  await Hive.openBox('LEXIKON_SETTINGS');
  await Hive.openBox('LEXIKON_NOTES');
  await Hive.openBox('LEXIKON_HABITS');
  await Hive.openBox('LEXIKON_TODOLIST');
  await Hive.openBox('LEXIKON_SHOPPING');
  await Hive.openBox('LEXIKON_BUDGET');
  await Hive.openBox('LEXIKON_FINANCIAL');
  runApp(const Lexikon());
}

class Lexikon extends StatelessWidget {
  const Lexikon({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainView(),
    );
  }
}

