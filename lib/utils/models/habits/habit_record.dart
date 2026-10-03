import 'package:hive/hive.dart';

part 'habit_record.g.dart';

@HiveType(typeId: 13)
class HabitRecord {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String habitId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final bool completed;

  @HiveField(4)
  final double value;

  const HabitRecord({
    required this.id,
    required this.habitId,
    required this.date,
    required this.completed,
    required this.value,
  });
}
