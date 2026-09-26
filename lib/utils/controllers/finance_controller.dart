import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexikon/utils/models/models.dart';
import 'package:lexikon/utils/repositories/finance_repository.dart';


// Financial Records Controller --

class FinanceRecordsController
    extends StateNotifier<List<FinanceRecordsDetails>> {
  final FinanceTrackerRepository repository;

  FinanceRecordsController(this.repository) : super([]);

  void loadRecords() {
    state = repository.getAllRecords();
  }

  Future<void> saveRecord(FinanceRecordsDetails record) async {
    await repository.saveRecord(record);
    loadRecords();
  }

  Future<void> deleteRecord(String id) async {
    await repository.deleteRecord(id);
    loadRecords();
  }
}

final financeRecordsControllerProvider =
    StateNotifierProvider<
      FinanceRecordsController,
      List<FinanceRecordsDetails>
    >((ref) {
      final repository = ref.read(financeTrackerRepositoryProvider);

      return FinanceRecordsController(repository)..loadRecords();
    });

// -- Financial Records Controller

// Financial Category Budget Controller --

class FinanceCategoryBudgetController
    extends StateNotifier<List<FinanceCategoryBudget>> {
  final FinanceTrackerRepository repository;

  FinanceCategoryBudgetController(this.repository) : super([]);

  void loadBudgets() {
    state = repository.getAllCategoryBudgets();
  }

  Future<void> saveBudget(FinanceCategoryBudget budget) async {
    await repository.saveCategoryBudget(budget);
    loadBudgets();
  }

  Future<void> deleteBudget(FinanceCategory category) async {
    await repository.deleteCategoryBudget(category);
    loadBudgets();
  }
}

final financeCategoryBudgetControllerProvider =
    StateNotifierProvider<
      FinanceCategoryBudgetController,
      List<FinanceCategoryBudget>
    >((ref) {
      final repository = ref.read(financeTrackerRepositoryProvider);

      return FinanceCategoryBudgetController(repository)..loadBudgets();
    });

// -- Financial Category Budget Controller
