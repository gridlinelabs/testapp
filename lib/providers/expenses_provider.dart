import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense_model.dart';
import '../services/firestore_service.dart';
import 'groups_provider.dart';

/// Expenses for selected group
final groupExpensesProvider =
    StreamProvider.family<List<ExpenseModel>, String>((ref, groupId) {
  return ref.watch(firestoreServiceProvider).watchGroupExpenses(groupId);
});

/// Currently being edited expense
final editingExpenseProvider = StateProvider<ExpenseModel?>((ref) => null);

/// Expense management notifier
class ExpensesNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _firestoreService;

  ExpensesNotifier(this._firestoreService) : super(const AsyncValue.data(null));

  Future<void> addExpense(ExpenseModel expense) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _firestoreService.addExpense(expense));
  }

  Future<void> updateExpense(
      ExpenseModel oldExpense, ExpenseModel newExpense) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _firestoreService.updateExpense(oldExpense, newExpense));
  }

  Future<void> deleteExpense(ExpenseModel expense) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _firestoreService.deleteExpense(expense));
  }

  Future<void> settleDebt({
    required String groupId,
    required String fromUserId,
    required String toUserId,
    required double amount,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _firestoreService.settleDebt(
          groupId: groupId,
          fromUserId: fromUserId,
          toUserId: toUserId,
          amount: amount,
        ));
  }
}

final expensesNotifierProvider =
    StateNotifierProvider<ExpensesNotifier, AsyncValue<void>>((ref) {
  return ExpensesNotifier(ref.watch(firestoreServiceProvider));
});

/// Compute split amounts for equal split
List<ExpenseSplit> computeEqualSplits({
  required double totalAmount,
  required List<String> memberIds,
  required Map<String, String> memberNames,
}) {
  final perPerson = totalAmount / memberIds.length;
  return memberIds
      .map((id) => ExpenseSplit(
            userId: id,
            userName: memberNames[id] ?? '',
            amount: double.parse(perPerson.toStringAsFixed(2)),
          ))
      .toList();
}
