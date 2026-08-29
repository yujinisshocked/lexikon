import 'package:lexikon/utils/models/todo.dart';
import 'package:lexikon/utils/services/hive_service.dart';

class TodoRepository {
  Future<void> addTodo(Todo todo) async {
    await HiveService.addTodo(todo);
  }

  List<Todo> getAllTodos() {
    return HiveService.getAllTodos();
  }

  Todo? getTodoById(String todoId) {
    return HiveService.getTodoById(todoId);
  }

  Future<void> updateTodo(Todo todo) async {
    await HiveService.updateTodo(todo);
  }

  Future<void> deleteTodo(String todoId) async {
    await HiveService.deleteTodo(todoId);
  }

  int getNextSortOrder() {
    final todos = getAllTodos();

    if (todos.isEmpty) {
      return 0;
    }

    return todos
            .map((todo) => todo.sortOrder)
            .reduce((a, b) => a > b ? a : b) +
        1;
  }
}