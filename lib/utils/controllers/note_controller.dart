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

  Future<void> _loadNotes() async {
    _refreshState();
  }

  void _refreshState() {
    final notes = _noteRepository.getAllNotes();

    notes.sort((a, b) {
      // Pinned notes always come first.
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }

      // Then sort by manual order.
      return a.sortOrder.compareTo(b.sortOrder);
    });

    state = notes;
  }

  Note? getNoteById(String noteId) {
    return _noteRepository.getNoteById(noteId);
  }

  Future<void> addNote(Note note) async {
    await _noteRepository.addNote(note);
    _refreshState();
  }

  Future<void> updateNote(Note note) async {
    await _noteRepository.updateNote(note);
    _refreshState();
  }

  Future<void> deleteNote(String noteId) async {
    await _noteRepository.deleteNote(noteId);
    _refreshState();
  }

  Future<void> clearAllNotes() async {
    await _noteRepository.clearAllNotes();
    _refreshState();
  }

  // ---------------------------------------------------------------------------
  // Pinning
  // ---------------------------------------------------------------------------

  int get pinnedCount {
    return state.where((note) => note.isPinned).length;
  }

  bool canPin(Note note) {
    return note.isPinned || pinnedCount < 3;
  }

  Future<bool> togglePin(Note note) async {
    // Trying to pin a fourth note.
    if (!note.isPinned && pinnedCount >= 3) {
      return false;
    }

    final updatedNote = note.copyWith(
      isPinned: !note.isPinned,
    );

    await _noteRepository.updateNote(updatedNote);
    _refreshState();

    return true;
  }

  // ---------------------------------------------------------------------------
  // Reordering
  // ---------------------------------------------------------------------------

  Future<void> reorderNotes(
    int oldIndex,
    int newIndex,
  ) async {
    final reordered = List<Note>.from(state);

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final note = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, note);

    // Persist the new sequence.
    final updatedNotes = <Note>[];

    for (int i = 0; i < reordered.length; i++) {
      updatedNotes.add(
        reordered[i].copyWith(
          sortOrder: i,
        ),
      );
    }

    // Write everything to Hive.
    for (final note in updatedNotes) {
      await _noteRepository.updateNote(note);
    }

    _refreshState();
  }
}