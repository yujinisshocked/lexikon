import 'package:flutter/material.dart';
import 'package:lexikon/utils/models/note.dart';

class NotesTileWidget extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onPin;

  const NotesTileWidget({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
    required this.onPin,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(note.id),

      direction: DismissDirection.horizontal,

      // -----------------------------------------------------------------------
      // Swipe right → Pin
      // -----------------------------------------------------------------------

      background: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        padding: const EdgeInsets.only(
          left: 20,
        ),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          note.isPinned
              ? Icons.push_pin_outlined
              : Icons.push_pin,
          color: Colors.white,
        ),
      ),

      // -----------------------------------------------------------------------
      // Swipe left → Delete
      // -----------------------------------------------------------------------

      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        padding: const EdgeInsets.only(
          right: 20,
        ),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),

      confirmDismiss: (direction) async {
        // RIGHT → PIN
        if (direction ==
            DismissDirection.startToEnd) {
          onPin();

          // Do NOT remove the tile.
          return false;
        }

        // LEFT → DELETE
        if (direction ==
            DismissDirection.endToStart) {
          return true;
        }

        return false;
      },

      onDismissed: (direction) {
        if (direction ==
            DismissDirection.endToStart) {
          onDelete();
        }
      },

      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              // ----------------------------------------------------------------
              // Blue pinned indicator
              // ----------------------------------------------------------------

              AnimatedContainer(
                duration:
                    const Duration(milliseconds: 200),
                width: note.isPinned ? 4 : 0,
                height: 64,
                color: Colors.blue,
              ),

              // ----------------------------------------------------------------
              // Note content
              // ----------------------------------------------------------------

              Expanded(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),

                  title: Row(
                    children: [
                      if (note.isPinned) ...[
                        const Icon(
                          Icons.push_pin,
                          size: 15,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 6),
                      ],

                      Expanded(
                        child: Text(
                          note.title,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  subtitle: Padding(
                    padding:
                        const EdgeInsets.only(top: 4),
                    child: Text(
                      _formatDate(note.updatedAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),

              // ----------------------------------------------------------------
              // Drag handle
              // ----------------------------------------------------------------

              const Padding(
                padding: EdgeInsets.only(
                  right: 8,
                ),
                child: Icon(
                  Icons.drag_handle,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}