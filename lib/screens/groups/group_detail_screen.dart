import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../design/buttons.dart';
import '../../models/expense_model.dart';
import '../../models/group_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expenses_provider.dart';
import '../../providers/groups_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/expenses/balance_summary.dart';
import '../../widgets/expenses/expense_item.dart';
import '../expenses/add_expense_screen.dart';

class GroupDetailScreen extends ConsumerWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    final expensesAsync = ref.watch(groupExpensesProvider(groupId));
    final authUser = ref.watch(authStateProvider).valueOrNull;
    final currentUserId = authUser?.uid ?? '';

    return FutureBuilder<GroupModel?>(
      future: firestoreService.getGroup(groupId),
      builder: (context, groupSnap) {
        final group = groupSnap.data;
        if (group == null) {
          return const Scaffold(
            body: Center(child: AppLoadingIndicator()),
          );
        }

        final balances = {
          for (final m in group.members) m.userId: m.balance,
        };
        final userNames = {
          for (final m in group.members) m.userId: m.name,
        };
        final settlements = calculateMinimalTransactions(balances, userNames);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // Custom app bar with gradient
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () =>
                        _showGroupOptions(context, ref, group),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.base, 0, AppSpacing.base, AppSpacing.base),
                        child: Row(
                          children: [
                            Text(
                              group.categoryEmoji,
                              style: const TextStyle(fontSize: 28),
                            ),
                            AppSpacing.wMd,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    group.name,
                                    style: AppTypography.headlineSmall.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '${group.memberCount} members',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Balance card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: BalanceSummaryCard(
                    group: group,
                    currentUserId: currentUserId,
                    onSettleUp: () => _showSettleUp(context, ref, settlements,
                        group, currentUserId),
                  ),
                ),
              ),

              // Settlements
              if (settlements.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.base),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Suggested Payments',
                            style: AppTypography.titleSmall),
                        AppSpacing.hSm,
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppSpacing.borderRadiusLg,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: SettlementsView(
                            transactions: settlements,
                            currentUserId: currentUserId,
                            onSettle: (t) => _confirmSettle(
                                context, ref, t, groupId),
                          ),
                        ),
                        AppSpacing.hBase,
                      ],
                    ),
                  ),
                ),

              // Expenses header
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Expenses', style: AppTypography.titleMedium),
                      TextButton.icon(
                        onPressed: () => _showAddExpense(context, group),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Expenses list
              expensesAsync.when(
                loading: () => const SliverToBoxAdapter(
                    child: AppLoadingIndicator()),
                error: (e, _) => SliverToBoxAdapter(
                  child: AppErrorState(message: e.toString()),
                ),
                data: (expenses) {
                  if (expenses.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: AppEmptyState(
                        title: 'No expenses yet',
                        message: 'Add your first expense to get started',
                        icon: Text('🧾', style: TextStyle(fontSize: 48)),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final expense = expenses[i];
                        return Column(
                          children: [
                            ExpenseItem(
                              expense: expense,
                              currentUserId: currentUserId,
                              onTap: () => _showExpenseDetail(
                                  context, ref, expense, group),
                            ),
                            if (i < expenses.length - 1)
                              const Divider(
                                  height: 1, indent: AppSpacing.base + 44 + AppSpacing.md),
                          ],
                        );
                      },
                      childCount: expenses.length,
                    ),
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddExpense(context, group),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text('Add Expense',
                style: AppTypography.labelLarge.copyWith(color: Colors.white)),
          ),
        );
      },
    );
  }

  void _showAddExpense(BuildContext context, GroupModel group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddExpenseSheet(group: group),
    );
  }

  void _showGroupOptions(
      BuildContext context, WidgetRef ref, GroupModel group) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading:
                const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
            title: const Text('Scan Receipt'),
            onTap: () {
              Navigator.pop(context);
              context.push('/scanner/${group.id}');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_outline, color: AppColors.primary),
            title: const Text('Manage Members'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppColors.error),
            title: const Text('Leave Group',
                style: TextStyle(color: AppColors.error)),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showSettleUp(
    BuildContext context,
    WidgetRef ref,
    List<SettlementTransaction> settlements,
    GroupModel group,
    String currentUserId,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: AppSpacing.paddingAll16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settle Up', style: AppTypography.titleLarge),
            AppSpacing.hBase,
            SettlementsView(
              transactions: settlements,
              currentUserId: currentUserId,
              onSettle: (t) {
                Navigator.pop(context);
                _confirmSettle(context, ref, t, group.id);
              },
            ),
            AppSpacing.hBase,
          ],
        ),
      ),
    );
  }

  void _confirmSettle(
    BuildContext context,
    WidgetRef ref,
    SettlementTransaction t,
    String groupId,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Settlement'),
        content: Text(
          'Mark payment of \$${t.amount.toStringAsFixed(2)} to ${t.toUserName} as complete?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(expensesNotifierProvider.notifier).settleDebt(
                    groupId: groupId,
                    fromUserId: t.fromUserId,
                    toUserId: t.toUserId,
                    amount: t.amount,
                  );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showExpenseDetail(
    BuildContext context,
    WidgetRef ref,
    ExpenseModel expense,
    GroupModel group,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExpenseDetailSheet(expense: expense, group: group),
    );
  }
}

class _ExpenseDetailSheet extends ConsumerWidget {
  final ExpenseModel expense;
  final GroupModel group;

  const _ExpenseDetailSheet({required this.expense, required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      padding: AppSpacing.paddingAll16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: AppSpacing.borderRadiusFull,
              ),
            ),
          ),
          AppSpacing.hBase,
          Row(
            children: [
              Text(expense.categoryEmoji,
                  style: const TextStyle(fontSize: 32)),
              AppSpacing.wMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expense.title, style: AppTypography.titleLarge),
                    Text(
                      '${expense.paidByName} paid · ${expense.categoryLabel}',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                '\$${expense.amount.toStringAsFixed(2)}',
                style: AppTypography.amountMedium,
              ),
            ],
          ),
          AppSpacing.hBase,
          const Divider(),
          AppSpacing.hBase,
          Text('Split breakdown', style: AppTypography.titleSmall),
          AppSpacing.hMd,
          ...expense.splits.map((split) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(split.userName, style: AppTypography.bodyMedium),
                    Text(
                      '\$${split.amount.toStringAsFixed(2)}',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )),
          if (expense.notes != null) ...[
            AppSpacing.hBase,
            const Divider(),
            AppSpacing.hBase,
            Text('Notes', style: AppTypography.titleSmall),
            AppSpacing.hXs,
            Text(expense.notes!, style: AppTypography.bodyMedium),
          ],
          AppSpacing.hXl,
          AppButton(
            label: 'Delete Expense',
            variant: AppButtonVariant.danger,
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(expensesNotifierProvider.notifier)
                  .deleteExpense(expense);
            },
          ),
          AppSpacing.hBase,
        ],
      ),
    );
  }
}
