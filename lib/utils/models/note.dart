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
  ///   {"insert":"Hello\n"},
  ///   {"insert":{"attachment":"12345"}}
  /// ]
  @HiveField(2)
  final String document;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime updatedAt;

  /// Attachment ID -> Base64 image data.
  @HiveField(5)
  final Map<String, String> attachments;

  /// Whether the note is pinned.
  @HiveField(6)
  final bool isPinned;

  /// Used to preserve the user's manual ordering.
  @HiveField(7)
  final int sortOrder;

  const Note({
    required this.id,
    required this.title,
    required this.document,
    required this.createdAt,
    required this.updatedAt,
    this.attachments = const {},
    this.isPinned = false,
    this.sortOrder = 0,
  });

  Note copyWith({
    String? id,
    String? title,
    String? document,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, String>? attachments,
    bool? isPinned,
    int? sortOrder,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      document: document ?? this.document,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attachments: attachments ?? this.attachments,
      isPinned: isPinned ?? this.isPinned,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}