import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 9)
class Habit {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final HabitType type;

  @HiveField(3)
  final double target;

  @HiveField(4)
  final HabitFrequency frequency;

  @HiveField(5)
  final List<HabitScheduledDays> scheduledDays;

  @HiveField(6)
  final int sortOrder;

  @HiveField(7)
  bool isArchived;

  @HiveField(8)
  final DateTime createdAt;

  Habit({
    required this.id,
    required this.name,
    required this.type,
    required this.target,
    required this.frequency,
    required this.scheduledDays,
    required this.sortOrder,
    this.isArchived = false,
    required this.createdAt,
  });
}

@HiveType(typeId: 10)
enum HabitType {
  @HiveField(0)
  boolean,

  @HiveField(1)
  quantity,

  @HiveField(2)
  duration,
}

@HiveType(typeId: 11)
enum HabitFrequency {
  @HiveField(0)
  daily,

  @HiveField(1)
  weekly,
}

@HiveType(typeId: 12)
enum HabitScheduledDays {
  @HiveField(0)
  monday,

  @HiveField(1)
  tuesday,

  @HiveField(2)
  wednesday,

  @HiveField(3)
  thursday,

  @HiveField(4)
  friday,

  @HiveField(5)
  saturday,

  @HiveField(6)
  sunday,
}
