import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexikon/pages/subpages/todo/todo_bubble.dart';
import 'package:lexikon/pages/subpages/todo/todo_date_separator.dart';
import 'package:lexikon/utils/controllers/todo_controller.dart';
import 'package:lexikon/utils/models/todo.dart';


class TodoPage extends ConsumerStatefulWidget {
  const TodoPage({super.key});

  @override
  ConsumerState<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends ConsumerState<TodoPage> {
  final TextEditingController _textController = TextEditingController();

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  bool _isSearching = false;
  final TextEditingController _searchController =
      TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _sendTodo() {
    final text = _textController.text.trim();

    if (text.isEmpty) return;

    final now = DateTime.now();

    final todo = Todo(
      id: now.microsecondsSinceEpoch.toString(),
      text: text,
      createdAt: now,
      updatedAt: now,
    );

    ref.read(todoControllerProvider.notifier).addTodo(todo);

    _textController.clear();
  }

  Future<void> _deleteTodo(Todo todo) async {
    final controller =
        ref.read(todoControllerProvider.notifier);

    await controller.deleteTodo(todo);

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: const Text('Todo deleted'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              controller.addTodo(todo);
            },
          ),
        ),
      );
  }


  Future<void> _showTodoMenu(Todo todo) async {

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);

                  _deleteTodo(todo);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allTodos = ref.watch(todoControllerProvider);

    final searchQuery = _searchController.text.trim().toLowerCase();

    final todos = searchQuery.isEmpty
        ? allTodos
        : allTodos.where((todo) {
            return todo.text.toLowerCase().contains(searchQuery);
          }).toList();

    return Scaffold(
      appBar: AppBar(
          title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search todos...',
                  border: InputBorder.none,
                ),
                onChanged: (_) {
                  setState(() {});
                },
              )
            : const Text('Lexikon'),
        
        actions: [
           IconButton(
            icon: Icon(
              _isSearching
                  ? Icons.close
                  : Icons.search,
            ),
            tooltip: _isSearching ? 'Close search' : 'Search',
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                }

                _isSearching = !_isSearching;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Todo messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];

                final showDate = index == 0 ||
                  !_isSameDay(
                    todo.createdAt,
                    todos[index - 1].createdAt,
                  );

                return Column(
                  children: [
                    if (showDate)
                    TodoDateSeparator(date: todo.createdAt),
                    TodoBubble(
                      todo: todo,

                      onTap: () {
                        final controller =
                            ref.read(todoControllerProvider.notifier);

                        final nextStatus = switch (todo.status) {
                          TodoStatus.incomplete => TodoStatus.pending,
                          TodoStatus.pending => TodoStatus.incomplete,
                          TodoStatus.completed => TodoStatus.completed,
                        };

                        controller.setStatus(todo, nextStatus);
                      },

                      onDoubleTap: () {
                        final controller =
                            ref.read(todoControllerProvider.notifier);

                        final nextStatus = switch (todo.status) {
                          TodoStatus.incomplete => TodoStatus.completed,
                          TodoStatus.pending => TodoStatus.completed,
                          TodoStatus.completed => TodoStatus.incomplete,
                        };

                        controller.setStatus(todo, nextStatus);
                      },

                      onLongPress: () {
                        _showTodoMenu(todo);
                      },
                    ),
                  ],
                );
              },
            ),          
          ),

          // Message input
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendTodo(),
                      decoration: const InputDecoration(
                        hintText: 'What needs to be done?',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendTodo,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}