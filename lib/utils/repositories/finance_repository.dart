import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexikon/utils/models/models.dart';
import 'package:lexikon/utils/services/hive_service.dart';

class FinanceTrackerRepository {
  // Financial Records --

  Future<void> saveRecord(FinanceRecordsDetails record) async {
    await HiveServiceFinanceTracker.saveRecord(record);
  }

  FinanceRecordsDetails? getRecord(String id) {
    return HiveServiceFinanceTracker.getRecord(id);
  }

  List<FinanceRecordsDetails> getAllRecords() {
    return HiveServiceFinanceTracker.getAllRecords();
  }

  Future<void> deleteRecord(String id) async {
    await HiveServiceFinanceTracker.deleteRecord(id);
  }

  // -- Financial Records

  // Financial Category Budgets --

  Future<void> saveCategoryBudget(FinanceCategoryBudget budget) async {
    await HiveServiceFinanceTracker.saveCategoryBudget(budget);
  }

  FinanceCategoryBudget? getCategoryBudget(FinanceCategory category) {
    return HiveServiceFinanceTracker.getCategoryBudget(category);
  }

  List<FinanceCategoryBudget> getAllCategoryBudgets() {
    return HiveServiceFinanceTracker.getAllCategoryBudgets();
  }

  Future<void> deleteCategoryBudget(FinanceCategory category) async {
    await HiveServiceFinanceTracker.deleteCategoryBudget(category);
  }

  // -- Financial Category Budgets
}

final financeTrackerRepositoryProvider = Provider<FinanceTrackerRepository>((
  ref,
) {
  return FinanceTrackerRepository();
});
