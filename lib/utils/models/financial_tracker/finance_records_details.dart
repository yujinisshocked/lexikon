import 'package:hive/hive.dart';

part 'finance_records_details.g.dart';

// Records for each transaction
@HiveType(typeId: 5)
class FinanceRecordsDetails extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String createdAt;

  @HiveField(2)
  FinanceType type;

  @HiveField(3)
  double amount;

  @HiveField(4)
  FinanceCategory category;

  @HiveField(5)
  String description;

  FinanceRecordsDetails({
    required this.id,
    required this.createdAt,
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
  });
}

@HiveType(typeId: 6)
enum FinanceType {
  @HiveField(0)
  income,

  @HiveField(1)
  expense,

  @HiveField(2)
  debt,
}

@HiveType(typeId: 7)
enum FinanceCategory {
  @HiveField(0)
  needs,

  @HiveField(1)
  wants,

  @HiveField(2)
  investments,

  @HiveField(3)
  savings,
}
