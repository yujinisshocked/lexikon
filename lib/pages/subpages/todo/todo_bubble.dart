import 'package:flutter/material.dart';

import 'package:lexikon/utils/models/todo.dart';

class TodoBubble extends StatelessWidget {
  const TodoBubble({
    super.key,
    required this.todo,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
  });

  final Todo todo;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final backgroundColor = switch (todo.status) {
      TodoStatus.incomplete => Colors.blue,
      TodoStatus.pending => Colors.amber,
      TodoStatus.completed => Colors.green,
    };

    final foregroundColor = switch (todo.status) {
      TodoStatus.incomplete => theme.colorScheme.onPrimary,
      TodoStatus.pending => theme.colorScheme.onSecondary,
      TodoStatus.completed => theme.colorScheme.onSurface,
    };

    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.text,
                  textAlign: TextAlign.left,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: foregroundColor,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  spacing: 4,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _formatTime(todo.createdAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: foregroundColor.withValues(alpha: 0.65),
                        ),
                      ),
                    ),
                    // if (todo.status == TodoStatus.completed)
                    Icon(
                      todo.status == TodoStatus.completed ? 
                        Icons.check : todo.status == TodoStatus.pending ?
                        Icons.pause_sharp : null,
                      size: 14,
                      color: todo.status == TodoStatus.pending ? Colors.white : Colors.black,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour == 0
        ? 12
        : time.hour > 12
            ? time.hour - 12
            : time.hour;

    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }
}