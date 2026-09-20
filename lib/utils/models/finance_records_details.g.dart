// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_records_details.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FinanceRecordsDetailsAdapter extends TypeAdapter<FinanceRecordsDetails> {
  @override
  final int typeId = 5;

  @override
  FinanceRecordsDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FinanceRecordsDetails(
      id: fields[0] as String,
      createdAt: fields[1] as String,
      type: fields[2] as FinanceType,
      amount: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, FinanceRecordsDetails obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.amount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinanceRecordsDetailsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FinanceTypeAdapter extends TypeAdapter<FinanceType> {
  @override
  final int typeId = 6;

  @override
  FinanceType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FinanceType.income;
      case 1:
        return FinanceType.expense;
      case 2:
        return FinanceType.debt;
      default:
        return FinanceType.income;
    }
  }

  @override
  void write(BinaryWriter writer, FinanceType obj) {
    switch (obj) {
      case FinanceType.income:
        writer.writeByte(0);
        break;
      case FinanceType.expense:
        writer.writeByte(1);
        break;
      case FinanceType.debt:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinanceTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FinanceCategoryAdapter extends TypeAdapter<FinanceCategory> {
  @override
  final int typeId = 7;

  @override
  FinanceCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FinanceCategory.needs;
      case 1:
        return FinanceCategory.wants;
      case 2:
        return FinanceCategory.investments;
      case 3:
        return FinanceCategory.savings;
      default:
        return FinanceCategory.needs;
    }
  }

  @override
  void write(BinaryWriter writer, FinanceCategory obj) {
    switch (obj) {
      case FinanceCategory.needs:
        writer.writeByte(0);
        break;
      case FinanceCategory.wants:
        writer.writeByte(1);
        break;
      case FinanceCategory.investments:
        writer.writeByte(2);
        break;
      case FinanceCategory.savings:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinanceCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
