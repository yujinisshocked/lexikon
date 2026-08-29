import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  /// Serialized Flutter Quill document.
  ///
  /// The entire note body is stored here, including:
  /// - text
  /// - formatting
  /// - headings
  /// - lists
  /// - code blocks
  /// - embedded images
  @HiveField(2)
  final String document;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.document,
    required this.createdAt,
    required this.updatedAt,
  });
}