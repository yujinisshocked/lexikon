part of 'hive_service.dart';

extension HiveServiceNotes on HiveService {
  // Add a note to the notes box
  static Future<void> addNote(Note note) async {
    final box = HiveService.getBox<Note>('LEXIKON_NOTES');
    await box.put(note.id, note);
  }

  // Get all notes from the notes box
  static List<Note> getAllNotes() {
    final box = HiveService.getBox<Note>('LEXIKON_NOTES');
    return box.values.toList();
  }

  // Delete a note from the notes box
  static Future<void> deleteNote(String noteId) async {
    final box = HiveService.getBox<Note>('LEXIKON_NOTES');
    await box.delete(noteId);
  }

}