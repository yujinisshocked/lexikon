import 'package:hive/hive.dart';
import 'package:lexikon/utils/models/financial_tracker/finance_records_details.dart';

part 'finance_budget.g.dart';

@HiveType(typeId: 8)
class FinanceCategoryBudget extends HiveObject {
  @HiveField(0)
  FinanceCategory category;

  @HiveField(1)
  double percentage;

  FinanceCategoryBudget({
    required this.category,
    required this.percentage,
  });
}