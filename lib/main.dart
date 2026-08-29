import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexikon/mainview.dart';
import 'package:lexikon/utils/services/hive_service.dart';
import 'package:lexikon/utils/models/note.dart';

void main() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Initialize Hive adapters
  await HiveService.initializeAdapters();

  // Open Hive boxes
  await Hive.openBox('LEXIKON_SETTINGS');
  await Hive.openBox<Note>('LEXIKON_NOTES');
  await Hive.openBox('LEXIKON_HABITS');
  await Hive.openBox('LEXIKON_TODOLIST');
  await Hive.openBox('LEXIKON_SHOPPING');
  await Hive.openBox('LEXIKON_BUDGET');
  await Hive.openBox('LEXIKON_FINANCIAL');

  runApp(const ProviderScope(child: Lexikon()));
}

class Lexikon extends ConsumerWidget {
  const Lexikon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainView(),
    );
  }
}

