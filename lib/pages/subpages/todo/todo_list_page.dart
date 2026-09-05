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

  Future<void> _pickReminder(Todo todo) async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
      initialDate: todo.reminderAt ?? now,
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: todo.reminderAt != null
          ? TimeOfDay.fromDateTime(todo.reminderAt!)
          : TimeOfDay.now(),
    );

    if (time == null || !mounted) return;

    final reminder = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    // Don't allow reminders in the past.
    if (!reminder.isAfter(DateTime.now())) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose a future time.'),
        ),
      );

      return;
    }

    await ref.read(todoControllerProvider.notifier).setReminder(
          todo,
          reminder,
        );
  }  

  Future<void> _showTodoMenu(Todo todo) async {
    final hasReminder = todo.reminderAt != null;

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.alarm_outlined),
                title: const Text('Reminder'),
                subtitle: Text(
                  hasReminder
                      ? _formatReminder(todo.reminderAt!)
                      : 'No reminder',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  _showReminderMenu(todo);
                },
              ),
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

  Future<void> _showReminderMenu(Todo todo) async {
    final hasReminder = todo.reminderAt != null;

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.alarm_outlined),
                title: Text(
                  hasReminder
                      ? 'Change reminder'
                      : 'Set reminder',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickReminder(todo);
                },
              ),

              if (hasReminder)
                ListTile(
                  leading: const Icon(Icons.alarm_off_outlined),
                  title: const Text('Remove reminder'),
                  onTap: () {
                    Navigator.pop(context);

                    ref
                        .read(todoControllerProvider.notifier)
                        .clearReminder(todo);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatReminder(DateTime reminder) {
    final now = DateTime.now();

    final isToday = reminder.year == now.year &&
        reminder.month == now.month &&
        reminder.day == now.day;

    final tomorrow = now.add(const Duration(days: 1));

    final isTomorrow = reminder.year == tomorrow.year &&
        reminder.month == tomorrow.month &&
        reminder.day == tomorrow.day;

    final time = TimeOfDay.fromDateTime(reminder).format(context);

    if (isToday) {
      return 'Today, $time';
    }

    if (isTomorrow) {
      return 'Tomorrow, $time';
    }

    return '${reminder.day}/${reminder.month}, $time';
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