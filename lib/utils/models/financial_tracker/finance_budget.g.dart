// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_budget.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FinanceCategoryBudgetAdapter extends TypeAdapter<FinanceCategoryBudget> {
  @override
  final int typeId = 8;

  @override
  FinanceCategoryBudget read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FinanceCategoryBudget(
      category: fields[0] as FinanceCategory,
      percentage: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, FinanceCategoryBudget obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.category)
      ..writeByte(1)
      ..write(obj.percentage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinanceCategoryBudgetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
