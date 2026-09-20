import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 1)
class Todo {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final DateTime updatedAt;

  @HiveField(4)
  final TodoStatus status;

  @HiveField(5)
  final int sortOrder;

  const Todo({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    this.status = TodoStatus.incomplete,
    this.sortOrder = 0,
  });

  Todo copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    DateTime? updatedAt,
    TodoStatus? status,
    int? sortOrder,
  }) {
    return Todo(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

@HiveType(typeId: 2)
enum TodoStatus {
  @HiveField(0)
  incomplete,

  @HiveField(1)
  pending,

  @HiveField(2)
  completed,
}