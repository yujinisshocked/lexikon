import 'package:lexikon/utils/models/note.dart';
import 'package:lexikon/utils/services/hive_service.dart';

class NoteRepository {
  // Add a new note
  Future<void> addNote(Note note) async {
    await HiveService.addNote(note);
  }

  // Get all notes
  List<Note> getAllNotes() {
    return HiveService.getAllNotes();
  }

  // Get a note by ID
  Note? getNoteById(String noteId) {
    return HiveService.readData<Note>('LEXIKON_NOTES', noteId);
  }

  // Update a note
  Future<void> updateNote(Note note) async {
    await HiveService.writeData<Note>('LEXIKON_NOTES', note.id, note);
  }

  // Delete a note
  Future<void> deleteNote(String noteId) async {
    await HiveService.deleteNote(noteId);
  }

  // Clear all notes
  Future<void> clearAllNotes() async {
    await HiveService.clearBox('LEXIKON_NOTES');
  }
}