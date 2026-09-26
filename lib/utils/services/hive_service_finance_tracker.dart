part of 'hive_service.dart';

class HiveServiceFinanceTracker {
  static const String recordsBox = 'LEXIKON_FINANCIAL';
  static const String categoryBudgetBox = 'LEXIKON_FINANCE_CATEGORY_BUDGET';

  // Financial Records --

  static Future<void> saveRecord(FinanceRecordsDetails record) async {
    await HiveService.getBox<FinanceRecordsDetails>(recordsBox)
        .put(record.id, record);
  }

  static FinanceRecordsDetails? getRecord(String id) {
    return HiveService.getBox<FinanceRecordsDetails>(recordsBox).get(id);
  }

  static List<FinanceRecordsDetails> getAllRecords() {
    return HiveService.getBox<FinanceRecordsDetails>(recordsBox).values
        .toList();
  }

  static Future<void> deleteRecord(String id) async {
    await HiveService.getBox<FinanceRecordsDetails>(recordsBox).delete(id);
  }

  // -- Financial Records

  // Financial Category Budgets --

  static Future<void> saveCategoryBudget(FinanceCategoryBudget budget) async {
    await HiveService.getBox<FinanceCategoryBudget>(categoryBudgetBox)
        .put(budget.category.name, budget);
  }

  static FinanceCategoryBudget? getCategoryBudget(FinanceCategory category) {
    return HiveService.getBox<FinanceCategoryBudget>(categoryBudgetBox)
        .get(category.name);
  }

  static List<FinanceCategoryBudget> getAllCategoryBudgets() {
    return HiveService.getBox<FinanceCategoryBudget>(categoryBudgetBox).values
        .toList();
  }

  static Future<void> deleteCategoryBudget(FinanceCategory category) async {
    await HiveService.getBox<FinanceCategoryBudget>(categoryBudgetBox)
        .delete(category.name);
  }

  // -- Financial Category Budgets
}
