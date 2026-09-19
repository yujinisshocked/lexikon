import 'package:flutter/material.dart';
import 'package:lexikon/pages/subpages/budget/budget_calculator_page.dart';
import 'package:lexikon/pages/subpages/financial/financial_tracker_page.dart';
import 'package:lexikon/pages/subpages/habits/habit_tracking_page.dart';
import 'package:lexikon/pages/subpages/notes/note_list_page.dart';
import 'package:lexikon/pages/subpages/scheduling/scheduling_page.dart';
import 'package:lexikon/pages/subpages/shopping/shopping_list_edit_page.dart';
import 'package:lexikon/pages/subpages/todo/todo_list_page.dart';

class VariablesHelpers {
  
  // Ammend New Features Here
  final List<Map<String, dynamic>> features = [
    {'icon': Icons.note, 'label': 'Note Taking', 'route': '/note-list', 'page' : NoteListPage()},
    {'icon': Icons.track_changes, 'label': 'Habit Tracking', 'route': '/habit-tracking', 'page': HabitTrackingPage()},
    {'icon': Icons.schedule, 'label': 'Scheduling', 'route': '/scheduling', 'page': SchedulingPage()},
    {'icon': Icons.checklist, 'label': 'To-Do List', 'route': '/todo-list', 'page': TodoPage()},
    {'icon': Icons.shopping_cart, 'label': 'Shopping List', 'route': '/shopping-list', 'page': ShoppingListEditPage()},
    {'icon': Icons.calculate, 'label': 'Budget Calculator', 'route': '/budget-calculator', 'page': BudgetCalculatorPage()},
    {'icon': Icons.monetization_on, 'label': 'Financial Tracker', 'route': '/financial-tracker', 'page': FinancialTrackerPage()},
  ];


}