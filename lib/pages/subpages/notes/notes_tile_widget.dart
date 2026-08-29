import 'package:flutter/material.dart';
import 'package:lexikon/utils/models/note.dart';
import 'package:lexikon/utils/services/hive_service.dart';

class NotesTileWidget extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final Function(Note) onDelete;

  const NotesTileWidget({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        onDelete(note);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ListTile(
          title: Text(
            note.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${note.createdAt.day}/${note.createdAt.month}/${note.createdAt.year}',
            style: const TextStyle(fontSize: 12.0),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}