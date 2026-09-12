import 'package:lexikon/utils/models/todo.dart';
import 'package:lexikon/utils/services/hive_service.dart';

class TodoRepository {
  Future<void> addTodo(Todo todo) async {
    await HiveServiceTodo.addTodo(todo);
  }

  List<Todo> getAllTodos() {
    return HiveServiceTodo.getAllTodos();
  }

  Todo? getTodoById(String todoId) {
    return HiveServiceTodo.getTodoById(todoId);
  }

  Future<void> updateTodo(Todo todo) async {
    await HiveServiceTodo.updateTodo(todo);
  }

  Future<void> deleteTodo(String todoId) async {
    await HiveServiceTodo.deleteTodo(todoId);
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