import 'package:hive/hive.dart';
import 'package:lexikon/utils/models/note.dart';
import 'package:lexikon/utils/models/todo.dart';

class HiveService {
  // Initialize Hive adapters
  static Future<void> initializeAdapters() async {
    Hive.registerAdapter(NoteAdapter());
    Hive.registerAdapter(TodoAdapter()); 
    Hive.registerAdapter(TodoStatusAdapter());
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

  // Add a note to the notes box
  static Future<void> addNote(Note note) async {
    final box = getBox<Note>('LEXIKON_NOTES');
    await box.put(note.id, note);
  }

  // Get all notes from the notes box
  static List<Note> getAllNotes() {
    final box = getBox<Note>('LEXIKON_NOTES');
    return box.values.toList();
  }

  // Delete a note from the notes box
  static Future<void> deleteNote(String noteId) async {
    final box = getBox<Note>('LEXIKON_NOTES');
    await box.delete(noteId);
  }

  // ---------------------------------------------------------------------------
  // Todo
  // ---------------------------------------------------------------------------

  static Future<void> addTodo(Todo todo) async {
    final box = getBox<Todo>('LEXIKON_TODOS');
    await box.put(todo.id, todo);
  }

  static List<Todo> getAllTodos() {
    final box = getBox<Todo>('LEXIKON_TODOS');

    final todos = box.values.toList();

    // Keep the user's manual ordering.
    todos.sort(
      (a, b) => a.sortOrder.compareTo(b.sortOrder),
    );

    return todos;
  }

  static Todo? getTodoById(String todoId) {
    final box = getBox<Todo>('LEXIKON_TODOS');
    return box.get(todoId);
  }

  static Future<void> updateTodo(Todo todo) async {
    final box = getBox<Todo>('LEXIKON_TODOS');
    await box.put(todo.id, todo);
  }

  static Future<void> deleteTodo(String todoId) async {
    final box = getBox<Todo>('LEXIKON_TODOS');
    await box.delete(todoId);
  }

}