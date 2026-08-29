import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexikon/utils/models/note.dart';
import 'package:lexikon/utils/controllers/note_controller.dart';
import 'package:lexikon/pages/subpages/notes/notes_tile_widget.dart';

class NoteListPage extends ConsumerStatefulWidget {
  const NoteListPage({super.key});

  @override
  ConsumerState<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends ConsumerState<NoteListPage> {
  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  Future<void> _deleteNote(Note note) async {
    await ref
        .read(noteControllerProvider.notifier)
        .deleteNote(note.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Note deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await ref
                .read(noteControllerProvider.notifier)
                .addNote(note);
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Pin
  // ---------------------------------------------------------------------------

  Future<void> _togglePin(Note note) async {
    final controller =
        ref.read(noteControllerProvider.notifier);

    // Trying to pin more than three.
    if (!note.isPinned && controller.pinnedCount >= 3) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You can only pin up to 3 notes.',
          ),
        ),
      );

      return;
    }

    await controller.togglePin(note);

    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          note.isPinned
              ? 'Note unpinned'
              : 'Note pinned',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Open note
  // ---------------------------------------------------------------------------

  void _openNote(Note note) {
    Navigator.pushNamed(
      context,
      '/note-edit',
      arguments: note.id,
    );
  }

  // ---------------------------------------------------------------------------
  // Reorder
  // ---------------------------------------------------------------------------

  Future<void> _reorderNotes(
    int oldIndex,
    int newIndex,
  ) async {
    final notes = ref.read(noteControllerProvider);

    // Prevent dragging across the pinned/normal boundary.
    //
    // This keeps pinned notes pinned at the top.
    final pinnedCount =
        notes.where((note) => note.isPinned).length;

    final movingNote = notes[oldIndex];

    if (movingNote.isPinned) {
      if (newIndex > pinnedCount) {
        newIndex = pinnedCount;
      }
    } else {
      if (newIndex < pinnedCount) {
        newIndex = pinnedCount;
      }
    }

    await ref
        .read(noteControllerProvider.notifier)
        .reorderNotes(
          oldIndex,
          newIndex,
        );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(noteControllerProvider);

    final pinnedNotes =
        notes.where((note) => note.isPinned).toList();

    final normalNotes =
        notes.where((note) => !note.isPinned).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),

      body: notes.isEmpty
          ? const _EmptyNotesView()
          : ReorderableListView.builder(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 96,
              ),

              itemCount: notes.length,

              onReorder: _reorderNotes,

              proxyDecorator: (
                child,
                index,
                animation,
              ) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    final elevation =
                        Tween<double>(
                      begin: 0,
                      end: 8,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                      ),
                    );

                    return Material(
                      elevation: elevation.value,
                      borderRadius:
                          BorderRadius.circular(12),
                      child: child,
                    );
                  },
                  child: child,
                );
              },

              itemBuilder: (context, index) {
                final note = notes[index];

                final isLastPinned =
                    note.isPinned &&
                    index == pinnedNotes.length - 1;

                return Column(
                  key: ValueKey(note.id),
                  children: [
                    NotesTileWidget(
                      note: note,

                      onTap: () {
                        _openNote(note);
                      },

                      onDelete: () {
                        _deleteNote(note);
                      },

                      onPin: () {
                        _togglePin(note);
                      },
                    ),

                    // Divider between pinned and normal notes.
                    if (isLastPinned)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'Notes',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),

      floatingActionButton:
          FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/note-edit',
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// =============================================================================
// Empty state
// =============================================================================

class _EmptyNotesView extends StatelessWidget {
  const _EmptyNotesView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.note_outlined,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .outline,
            ),

            const SizedBox(height: 16),

            Text(
              'No notes yet',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge,
            ),

            const SizedBox(height: 8),

            Text(
              'Create a note to get started.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}