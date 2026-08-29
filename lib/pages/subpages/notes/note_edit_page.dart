import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexikon/utils/models/note.dart';
import 'package:lexikon/utils/controllers/note_controller.dart';

class NoteEditPage extends ConsumerStatefulWidget {
  const NoteEditPage({super.key});

  @override
  ConsumerState<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends ConsumerState<NoteEditPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _noteId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final noteId = ModalRoute.of(context)?.settings.arguments as String?;
    if (noteId != null) {
      _noteId = noteId;
      _loadNote(noteId);
    }
  }

  Future<void> _loadNote(String noteId) async {
    final note = ref.read(noteControllerProvider.notifier).getNoteById(noteId);
    if (note != null) {
      _titleController.text = note.title;
      _contentController.text = note.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final title = _titleController.text;
    final content = _contentController.text;

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and content cannot be empty')),
      );
      return;
    }

    final note = Note(
      id: _noteId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      createdAt: _noteId != null
          ? ref.read(noteControllerProvider.notifier).getNoteById(_noteId!)!.createdAt
          : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (_noteId != null) {
      await ref.read(noteControllerProvider.notifier).updateNote(note);
    } else {
      await ref.read(noteControllerProvider.notifier).addNote(note);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note saved successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_noteId != null ? 'Edit Note' : 'Create Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveNote,
              child: const Text('Save Note'),
            ),
          ],
        ),
      ),
    );
  }
}