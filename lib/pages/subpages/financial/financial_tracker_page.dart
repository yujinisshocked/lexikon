import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexikon/utils/controllers/finance_controller.dart';
import 'package:lexikon/utils/models/models.dart';

class FinancialTrackerPage extends ConsumerStatefulWidget {
  const FinancialTrackerPage({super.key});

  @override
  ConsumerState<FinancialTrackerPage> createState() =>
      _FinancialTrackerPageState();
}

class _FinancialTrackerPageState extends ConsumerState<FinancialTrackerPage> {
  // Temp budget defaults --

  final Map<FinanceCategory, double> defaultBudgets = {
    FinanceCategory.needs: 50,
    FinanceCategory.wants: 20,
    FinanceCategory.investments: 20,
    FinanceCategory.savings: 10,
  };

  // -- Temp budget defaults

  // Month --

  DateTime selectedMonth = DateTime.now();

  void previousMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
    });
  }

  void nextMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
    });
  }

  // -- Month

  // Financial Records --

  DateTime? parseDate(String value) {
    return DateTime.tryParse(value);
  }

  List<FinanceRecordsDetails> get monthRecords {
    final records = ref.watch(financeRecordsControllerProvider);

    final filtered = records.where((record) {
      final date = parseDate(record.createdAt);

      if (date == null) {
        return false;
      }

      return date.year == selectedMonth.year &&
          date.month == selectedMonth.month;
    }).toList();

    filtered.sort((a, b) {
      final dateA = parseDate(a.createdAt);
      final dateB = parseDate(b.createdAt);

      if (dateA == null || dateB == null) {
        return 0;
      }

      return dateB.compareTo(dateA);
    });

    return filtered;
  }

  double get totalIncome {
    return monthRecords
        .where((record) => record.type == FinanceType.income)
        .fold(0, (sum, record) => sum + record.amount);
  }

  double get totalExpenses {
    return monthRecords
        .where((record) => record.type == FinanceType.expense)
        .fold(0, (sum, record) => sum + record.amount);
  }

  double get totalDebt {
    return monthRecords
        .where((record) => record.type == FinanceType.debt)
        .fold(0, (sum, record) => sum + record.amount);
  }

  double categoryAmount(FinanceCategory category) {
    return monthRecords
        .where(
          (record) =>
              record.type == FinanceType.expense && record.category == category,
        )
        .fold(0, (sum, record) => sum + record.amount);
  }

  // -- Financial Records

  // Financial Category Budgets --

  double categoryBudget(FinanceCategory category) {
    final budgets = ref.watch(financeCategoryBudgetControllerProvider);

    final budget = budgets.cast<FinanceCategoryBudget?>().firstWhere(
      (budget) => budget?.category == category,
      orElse: () => null,
    );

    return budget?.percentage ?? defaultBudgets[category] ?? 0;
  }

  double categoryPercentage(FinanceCategory category) {
    if (totalIncome <= 0) {
      return 0;
    }

    return (categoryAmount(category) / totalIncome) * 100;
  }

  // -- Financial Category Budgets

  // Category Colors --

  Color getCategoryColor(BuildContext context, FinanceCategory category) {
    final colorScheme = Theme.of(context).colorScheme;

    final actual = categoryPercentage(category);
    final budget = categoryBudget(category);

    if (actual >= budget) {
      return colorScheme.error;
    }

    if (actual >= budget * 0.8) {
      return colorScheme.error.withValues(alpha: 0.65);
    }

    switch (category) {
      case FinanceCategory.needs:
        return colorScheme.primary;

      case FinanceCategory.wants:
        return Colors.orange;

      case FinanceCategory.investments:
        return Colors.green;

      case FinanceCategory.savings:
        return Colors.purple;
    }
  }

  // -- Category Colors

  // Formatting --

  String categoryName(FinanceCategory category) {
    switch (category) {
      case FinanceCategory.needs:
        return 'Needs';

      case FinanceCategory.wants:
        return 'Wants';

      case FinanceCategory.investments:
        return 'Investments';

      case FinanceCategory.savings:
        return 'Savings';
    }
  }

  String typeName(FinanceType type) {
    switch (type) {
      case FinanceType.income:
        return 'Income';

      case FinanceType.expense:
        return 'Expense';

      case FinanceType.debt:
        return 'Debt';
    }
  }

  String formatMonth(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.year}';
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }

  // -- Formatting

  // Add Transaction --

  void showAddTransactionSheet() {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    FinanceType selectedType = FinanceType.expense;
    FinanceCategory selectedCategory = FinanceCategory.needs;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Amount --

                      Text(
                        'Add Transaction',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: amountController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          prefixText: 'RM ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),

                      // -- Amount
                      const SizedBox(height: 20),

                      // Type --
                      Text(
                        'Type',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),

                      const SizedBox(height: 8),

                      SegmentedButton<FinanceType>(
                        segments: const [
                          ButtonSegment(
                            value: FinanceType.expense,
                            label: Text(
                              'Expense',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          ButtonSegment(
                            value: FinanceType.debt,
                            label: Text(
                              'Debt',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          ButtonSegment(
                            value: FinanceType.income,
                            label: Text(
                              'Income',
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                        selected: {selectedType},
                        onSelectionChanged: (selection) {
                          setSheetState(() {
                            selectedType = selection.first;
                          });
                        },
                      ),

                      // -- Type
                      const SizedBox(height: 20),

                      // Category --
                      if (selectedType != FinanceType.income)
                        Text(
                          'Category',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),

                      if (selectedType != FinanceType.income)
                        const SizedBox(height: 8),

                      if (selectedType != FinanceType.income)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final category in FinanceCategory.values)
                              ChoiceChip(
                                label: Text(categoryName(category)),
                                selected: selectedCategory == category,
                                onSelected: (_) {
                                  setSheetState(() {
                                    selectedCategory = category;
                                  });
                                },
                              ),
                          ],
                        ),

                      // -- Category
                      const SizedBox(height: 20),

                      // Description --
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                      ),

                      // -- Description
                      const SizedBox(height: 20),

                      // Actions --
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(sheetContext);
                              },
                              child: const Text('Cancel'),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: FilledButton(
                              onPressed: () async {
                                final amount = double.tryParse(
                                  amountController.text.trim(),
                                );

                                if (amount == null || amount <= 0) {
                                  return;
                                }

                                final record = FinanceRecordsDetails(
                                  id: DateTime.now().microsecondsSinceEpoch
                                      .toString(),
                                  createdAt: DateTime.now().toIso8601String(),
                                  type: selectedType,
                                  amount: amount,
                                  category: selectedCategory,
                                  description: descriptionController.text,
                                );

                                await ref
                                    .read(
                                      financeRecordsControllerProvider.notifier,
                                    )
                                    .saveRecord(record);

                                if (sheetContext.mounted) {
                                  Navigator.pop(sheetContext);
                                }
                              },
                              child: const Text('Add'),
                            ),
                          ),
                        ],
                      ),

                      // -- Actions
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // -- Add Transaction

  // Transactions --

  List<FinanceRecordsDetails> recordsForDate(DateTime date) {
    return monthRecords.where((record) {
      final recordDate = parseDate(record.createdAt);

      if (recordDate == null) {
        return false;
      }

      return recordDate.year == date.year &&
          recordDate.month == date.month &&
          recordDate.day == date.day;
    }).toList();
  }

  List<DateTime> transactionDates() {
    final dates = <DateTime>{};

    for (final record in monthRecords) {
      final date = parseDate(record.createdAt);

      if (date == null) {
        continue;
      }

      dates.add(DateTime(date.year, date.month, date.day));
    }

    final sortedDates = dates.toList();

    sortedDates.sort((a, b) => b.compareTo(a));

    return sortedDates;
  }

  // -- Transactions

  // UI --

  @override
  Widget build(BuildContext context) {
    final remaining = totalIncome - totalExpenses;

    return Scaffold(
      appBar: AppBar(title: const Text('Financial Tracker')),

      body: Column(
        children: [
          // Month --

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
            child: Row(
              children: [
                IconButton(
                  onPressed: previousMonth,
                  icon: const Icon(Icons.chevron_left),
                ),

                Expanded(
                  child: Center(
                    child: Text(
                      formatMonth(selectedMonth),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                IconButton(
                  onPressed: nextMonth,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),

          // -- Month

          // Budget Bar --
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 18,
                child: totalIncome <= 0
                    ? Container(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      )
                    : Row(
                        children: [
                          for (final category in FinanceCategory.values) ...[
                            if (categoryAmount(category) > 0)
                              Expanded(
                                flex: (categoryAmount(category) * 100)
                                    .round()
                                    .clamp(1, 1000000),
                                child: Container(
                                  color: getCategoryColor(context, category),
                                ),
                              ),

                            if (categoryAmount(category) > 0)
                              const SizedBox(width: 2),
                          ],

                          if (remaining > 0) ...[
                            const SizedBox(width: 2),

                            Expanded(
                              flex: (remaining * 100).round().clamp(1, 1000000),
                              child: Container(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          ),

          // -- Budget Bar
          const SizedBox(height: 12),

          // Budget Legend --
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                for (final category in FinanceCategory.values)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: getCategoryColor(context, category),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        categoryName(category),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // -- Budget Legend
          const SizedBox(height: 12),

          // Summary --
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('RM ${formatAmount(totalExpenses)} spent'),
                Text('RM ${formatAmount(remaining)} left'),
              ],
            ),
          ),

          // -- Summary
          const SizedBox(height: 16),

          // Transactions --
          Expanded(
            child: monthRecords.isEmpty
                ? Center(
                    child: Text(
                      'No transactions',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    children: [
                      for (final date in transactionDates()) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 4),
                          child: Text(
                            DateUtils.isSameDay(date, DateTime.now())
                                ? 'Today'
                                : DateUtils.isSameDay(
                                    date,
                                    DateTime.now().subtract(
                                      const Duration(days: 1),
                                    ),
                                  )
                                ? 'Yesterday'
                                : formatDate(date),
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),

                        for (final record in recordsForDate(date))
                          ListTile(
                            contentPadding: EdgeInsets.zero,

                            title: Text(
                              record.description,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight(800),
                              ),
                            ),

                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  typeName(record.type),
                                  style: TextStyle(
                                    color: record.type == FinanceType.income
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),

                                if (record.type != FinanceType.income)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: getCategoryColor(
                                            context,
                                            record.category,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        categoryName(record.category),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                              ],
                            ),

                            trailing: Text(
                              '${record.type == FinanceType.income ? '+' : '-'} '
                              'RM ${formatAmount(record.amount)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: record.type == FinanceType.income
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
          ),

          // -- Transactions
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: showAddTransactionSheet,
        child: const Icon(Icons.add),
      ),
    );
  }

  // -- UI
}
