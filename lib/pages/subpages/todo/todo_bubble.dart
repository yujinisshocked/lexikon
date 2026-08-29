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
      TodoStatus.incomplete => theme.colorScheme.primary,
      TodoStatus.pending => theme.colorScheme.secondary,
      TodoStatus.completed => theme.colorScheme.surfaceContainerHighest,
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

                if (todo.reminderAt != null) ...[
                  const SizedBox(height: 6),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.alarm_outlined,
                        size: 14,
                        color: foregroundColor.withValues(alpha: 0.75),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _formatReminder(todo.reminderAt!),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: foregroundColor.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 4),

                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _formatTime(todo.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: foregroundColor.withValues(alpha: 0.65),
                    ),
                  ),
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

  String _formatReminder(DateTime reminder) {
    final now = DateTime.now();

    final isToday = reminder.year == now.year &&
        reminder.month == now.month &&
        reminder.day == now.day;

    final tomorrow = now.add(const Duration(days: 1));

    final isTomorrow = reminder.year == tomorrow.year &&
        reminder.month == tomorrow.month &&
        reminder.day == tomorrow.day;

    final time = _formatTime(reminder);

    if (isToday) {
      return 'Today, $time';
    }

    if (isTomorrow) {
      return 'Tomorrow, $time';
    }

    return '${reminder.day}/${reminder.month}, $time';
  }
}