import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lexikon/utils/models/note.dart';
import 'package:lexikon/utils/models/settings.dart';
import 'package:lexikon/utils/models/shopping_list/shopping_item.dart';
import 'package:lexikon/utils/models/shopping_list/shopping_list.dart';
import 'package:lexikon/utils/models/todo.dart';

part 'hive_service_todo.dart';
part 'hive_service_notes.dart';
part 'hive_service_shopping_lists.dart';
part 'hive_service_shopping_items.dart';
part 'hive_service_settings.dart';

class HiveService {
  // Initialize Hive adapters
  static Future<void> initializeAdapters() async {
    Hive.registerAdapter(NoteAdapter());
    Hive.registerAdapter(TodoAdapter()); 
    Hive.registerAdapter(TodoStatusAdapter());
    Hive.registerAdapter(ShoppingListAdapter());
    Hive.registerAdapter(ShoppingItemAdapter());
  }

  // Get a Hive box by name
  static Box<T> getBox<T>(String boxName) {
    return Hive.box<T>(boxName);
  }

  // Write data to a Hive box
  static Future<void> writeData<T>(
    String boxName,
    String key,
    T value,
  ) async {
    final box = getBox<T>(boxName);
    await box.put(key, value);
  }

  // Read data from a Hive box
  static T? readData<T>(String boxName, String key) {
    final box = getBox<T>(boxName);
    return box.get(key);
  }

  // Delete data from a Hive box
  static Future<void> deleteData(String boxName, String key) async {
    final box = getBox(boxName);
    await box.delete(key);
  }

  // Clear all data from a Hive box
  static Future<void> clearBox(String boxName) async {
    final box = getBox(boxName);
    await box.clear();
  }

  // Check if a key exists in a Hive box
  static bool containsKey(String boxName, String key) {
    final box = getBox(boxName);
    return box.containsKey(key);
  }

  // Get all keys from a Hive box
  static List<dynamic> getAllKeys(String boxName) {
    final box = getBox(boxName);
    return box.keys.toList();
  }

  // Get all values from a Hive box
  static List<dynamic> getAllValues(String boxName) {
    final box = getBox(boxName);
    return box.values.toList();
  }
}