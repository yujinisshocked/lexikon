// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 9;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as HabitType,
      target: fields[3] as double,
      frequency: fields[4] as HabitFrequency,
      scheduledDays: (fields[5] as List).cast<HabitScheduledDays>(),
      sortOrder: fields[6] as int,
      isArchived: fields[7] as bool,
      createdAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.target)
      ..writeByte(4)
      ..write(obj.frequency)
      ..writeByte(5)
      ..write(obj.scheduledDays)
      ..writeByte(6)
      ..write(obj.sortOrder)
      ..writeByte(7)
      ..write(obj.isArchived)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HabitTypeAdapter extends TypeAdapter<HabitType> {
  @override
  final int typeId = 10;

  @override
  HabitType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitType.boolean;
      case 1:
        return HabitType.quantity;
      case 2:
        return HabitType.duration;
      default:
        return HabitType.boolean;
    }
  }

  @override
  void write(BinaryWriter writer, HabitType obj) {
    switch (obj) {
      case HabitType.boolean:
        writer.writeByte(0);
        break;
      case HabitType.quantity:
        writer.writeByte(1);
        break;
      case HabitType.duration:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HabitFrequencyAdapter extends TypeAdapter<HabitFrequency> {
  @override
  final int typeId = 11;

  @override
  HabitFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitFrequency.daily;
      case 1:
        return HabitFrequency.weekly;
      default:
        return HabitFrequency.daily;
    }
  }

  @override
  void write(BinaryWriter writer, HabitFrequency obj) {
    switch (obj) {
      case HabitFrequency.daily:
        writer.writeByte(0);
        break;
      case HabitFrequency.weekly:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HabitScheduledDaysAdapter extends TypeAdapter<HabitScheduledDays> {
  @override
  final int typeId = 12;

  @override
  HabitScheduledDays read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitScheduledDays.monday;
      case 1:
        return HabitScheduledDays.tuesday;
      case 2:
        return HabitScheduledDays.wednesday;
      case 3:
        return HabitScheduledDays.thursday;
      case 4:
        return HabitScheduledDays.friday;
      case 5:
        return HabitScheduledDays.saturday;
      case 6:
        return HabitScheduledDays.sunday;
      default:
        return HabitScheduledDays.monday;
    }
  }

  @override
  void write(BinaryWriter writer, HabitScheduledDays obj) {
    switch (obj) {
      case HabitScheduledDays.monday:
        writer.writeByte(0);
        break;
      case HabitScheduledDays.tuesday:
        writer.writeByte(1);
        break;
      case HabitScheduledDays.wednesday:
        writer.writeByte(2);
        break;
      case HabitScheduledDays.thursday:
        writer.writeByte(3);
        break;
      case HabitScheduledDays.friday:
        writer.writeByte(4);
        break;
      case HabitScheduledDays.saturday:
        writer.writeByte(5);
        break;
      case HabitScheduledDays.sunday:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitScheduledDaysAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
