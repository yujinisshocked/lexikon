import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexikon/utils/models/note.dart';
import 'package:lexikon/utils/repositories/note_repository.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository();
});

final noteControllerProvider =
    StateNotifierProvider<NoteController, List<Note>>((ref) {
  return NoteController(
    ref.read(noteRepositoryProvider),
  );
});

class NoteController extends StateNotifier<List<Note>> {
  final NoteRepository _noteRepository;

  NoteController(this._noteRepository) : super([]) {
    _loadNotes();
  }

  void _loadNotes() {
    state = _noteRepository.getAllNotes();
  }

  Note? getNoteById(String noteId) {
    return _noteRepository.getNoteById(noteId);
  }

  Future<void> addNote(Note note) async {
    await _noteRepository.addNote(note);
    _loadNotes();
  }

  Future<void> updateNote(Note note) async {
    await _noteRepository.updateNote(note);
    _loadNotes();
  }

  Future<void> deleteNote(String noteId) async {
    await _noteRepository.deleteNote(noteId);
    _loadNotes();
  }

  Future<void> clearAllNotes() async {
    await _noteRepository.clearAllNotes();
    _loadNotes();
  }
}