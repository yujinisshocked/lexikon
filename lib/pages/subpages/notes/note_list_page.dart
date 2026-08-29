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
  Note? deletedNote;

  Future<void> _deleteNote(Note note) async {
    setState(() {
      deletedNote = note;
    });

    await ref.read(noteControllerProvider.notifier).deleteNote(note.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Note deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await ref.read(noteControllerProvider.notifier).addNote(note);
            setState(() {
              deletedNote = null;
            });
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(noteControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return NotesTileWidget(
            note: note,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/note-edit',
                arguments: note.id,
              );
            },
            onDelete: _deleteNote,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/note-edit');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

