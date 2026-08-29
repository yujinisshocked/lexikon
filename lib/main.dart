import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexikon/mainview.dart';
import 'package:lexikon/utils/models/todo.dart';
import 'package:lexikon/utils/services/hive_service.dart';
import 'package:lexikon/utils/models/note.dart';
import 'package:lexikon/pages/subpages/notes/note_list_page.dart';
import 'package:lexikon/pages/subpages/notes/note_edit_page.dart';
import 'package:lexikon/pages/subpages/habits/habit_tracking_page.dart';
import 'package:lexikon/pages/subpages/scheduling/scheduling_page.dart';
import 'package:lexikon/pages/subpages/todo/todo_list_page.dart';
import 'package:lexikon/pages/subpages/shopping/shopping_list_page.dart';
import 'package:lexikon/pages/subpages/budget/budget_calculator_page.dart';
import 'package:lexikon/pages/subpages/financial/financial_tracker_page.dart';
import 'package:lexikon/utils/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize Hive adapters
  await HiveService.initializeAdapters();

  // Open Hive boxes
  await Hive.openBox('LEXIKON_SETTINGS');
  await Hive.openBox<Note>('LEXIKON_NOTES');
  await Hive.openBox('LEXIKON_HABITS');
  await Hive.openBox<Todo>('LEXIKON_TODOS');
  await Hive.openBox('LEXIKON_SHOPPING');
  await Hive.openBox('LEXIKON_BUDGET');
  await Hive.openBox('LEXIKON_FINANCIAL');

  await NotificationService.instance.initialize();

  runApp(const ProviderScope(child: Lexikon()));
}

class Lexikon extends ConsumerWidget {
  const Lexikon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainView(),
      routes: {
        '/note-list': (context) => const NoteListPage(),
        '/note-edit': (context) => const NoteEditPage(),
        '/habit-tracking': (context) => const HabitTrackingPage(),
        '/scheduling': (context) => const SchedulingPage(),
        '/todo-list': (context) => const TodoPage(),
        '/shopping-list': (context) => const ShoppingListPage(),
        '/budget-calculator': (context) => const BudgetCalculatorPage(),
        '/financial-tracker': (context) => const FinancialTrackerPage(),
      },
    );
  }
}

