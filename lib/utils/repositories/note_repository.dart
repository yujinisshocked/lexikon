import 'package:lexikon/utils/models/note.dart';
import 'package:lexikon/utils/services/hive_service.dart';

class NoteRepository {
  Future<void> addNote(Note note) async {
    await HiveServiceNotes.addNote(note);
  }

  List<Note> getAllNotes() {
    return HiveServiceNotes.getAllNotes();
  }

  Note? getNoteById(String noteId) {
    return HiveService.readData<Note>(
      'LEXIKON_NOTES',
      noteId,
    );
  }

  Future<void> updateNote(Note note) async {
    await HiveService.writeData<Note>(
      'LEXIKON_NOTES',
      note.id,
      note,
    );
  }

  Future<void> deleteNote(String noteId) async {
    await HiveServiceNotes.deleteNote(noteId);
  }

  Future<void> clearAllNotes() async {
    await HiveService.clearBox('LEXIKON_NOTES');
  }
}