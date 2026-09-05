import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexikon/utils/models/todo.dart';
import 'package:lexikon/utils/repositories/todo_repository.dart';
// import 'package:lexikon/utils/services/notification_service.dart';

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository();
});

final todoControllerProvider =
    StateNotifierProvider<TodoController, List<Todo>>((ref) {
  final repository = ref.watch(todoRepositoryProvider);

  return TodoController(repository);
});

class TodoController extends StateNotifier<List<Todo>> {
  TodoController(this._repository) : super([]) {
    loadTodos();
  }

  final TodoRepository _repository;

  void loadTodos() {
    final todos = _repository.getAllTodos();

    todos.sort(
      (a, b) => a.sortOrder.compareTo(b.sortOrder),
    );

    state = todos;
  }

  Future<void> addTodo(Todo todo) async {
    final sortOrder = _repository.getNextSortOrder();

    final orderedTodo = todo.copyWith(
      sortOrder: sortOrder,
    );

    await _repository.addTodo(orderedTodo);

    loadTodos();
  }

  Future<void> updateTodo(Todo todo) async {
    await _repository.updateTodo(todo);
    loadTodos();
  }

  Future<void> deleteTodo(Todo todo) async {
    // if (todo.reminderAt != null) {
    //   await NotificationService.instance.cancelReminder(todo.id);
    // }

    await _repository.deleteTodo(todo.id);

    loadTodos();
  }
  Future<void> toggleTodo(Todo todo) async {
    final newStatus = todo.status == TodoStatus.completed
        ? TodoStatus.incomplete
        : TodoStatus.completed;

    await updateTodo(
      todo.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> setStatus(
    Todo todo,
    TodoStatus status,
  ) async {
    await updateTodo(
      todo.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> setReminder(
    Todo todo,
    DateTime reminderAt,
  ) async {
    final updatedTodo = todo.copyWith(
      reminderAt: reminderAt,
      status: TodoStatus.pending,
      updatedAt: DateTime.now(),
    );

    await updateTodo(updatedTodo);

    // await NotificationService.instance.scheduleReminder(
    //   id: updatedTodo.id,
    //   text: updatedTodo.text,
    //   reminderAt: reminderAt,
    // );
  } 

  Future<void> clearReminder(Todo todo) async {
    await updateTodo(
      todo.copyWith(
        reminderAt: null,
        updatedAt: DateTime.now(),
      ),
    );

    // await NotificationService.instance.cancelReminder(
    //   todo.id,
    // );
  }
}