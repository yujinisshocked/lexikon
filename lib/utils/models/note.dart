import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  /// Quill Delta JSON.
  ///
  /// Example:
  /// [
  ///   {"insert":"Hello world\n"},
  ///   {"insert":{"attachment":"abc123"}},
  ///   {"insert":"More text\n"}
  /// ]
  @HiveField(2)
  final String document;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime updatedAt;

  /// Attachment ID -> Base64 image data.
  ///
  /// The Quill document only contains the attachment ID.
  @HiveField(5)
  final Map<String, String> attachments;

  Note({
    required this.id,
    required this.title,
    required this.document,
    required this.createdAt,
    required this.updatedAt,
    this.attachments = const {},
  });
}