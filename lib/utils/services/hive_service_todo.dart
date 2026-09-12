part of 'hive_service.dart';

// ---------------------------------------------------------------------------
// Todo Extension for HiveService
// ---------------------------------------------------------------------------

extension HiveServiceTodo on HiveService {
  static Future<void> addTodo(Todo todo) async {
    final box = HiveService.getBox<Todo>('LEXIKON_TODOS');
    await box.put(todo.id, todo);
  }

  static List<Todo> getAllTodos() {
    final box = HiveService.getBox<Todo>('LEXIKON_TODOS');
    final todos = box.values.toList();

    // Keep the user's manual ordering.
    todos.sort(
      (a, b) => a.sortOrder.compareTo(b.sortOrder),
    );

    return todos;
  }

  static Todo? getTodoById(String todoId) {
    final box = HiveService.getBox<Todo>('LEXIKON_TODOS');
    return box.get(todoId);
  }

  static Future<void> updateTodo(Todo todo) async {
    final box = HiveService.getBox<Todo>('LEXIKON_TODOS');
    await box.put(todo.id, todo);
  }

  static Future<void> deleteTodo(String todoId) async {
    final box = HiveService.getBox<Todo>('LEXIKON_TODOS');
    await box.delete(todoId);
  }
}