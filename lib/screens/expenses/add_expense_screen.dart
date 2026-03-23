import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../design/buttons.dart';
import '../../models/expense_model.dart';
import '../../models/group_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expenses_provider.dart';
import '../../widgets/common/app_text_field.dart';

class AddExpenseSheet extends ConsumerStatefulWidget {
  final GroupModel group;
  final List<ReceiptItem>? prefilledItems; // from scanner

  const AddExpenseSheet({
    super.key,
    required this.group,
    this.prefilledItems,
  });

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  ExpenseCategory _category = ExpenseCategory.other;
  SplitType _splitType = SplitType.equal;
  DateTime _date = DateTime.now();
  late String _paidById;
  late String _paidByName;
  bool _isSaving = false;

  // For custom splits
  Map<String, TextEditingController> _splitCtrlMap = {};

  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    _paidById = currentUser?.id ?? '';
    _paidByName = currentUser?.name ?? '';

    // Init custom split controllers
    for (final m in widget.group.members) {
      _splitCtrlMap[m.userId] = TextEditingController();
    }

    // Prefill from scanner
    if (widget.prefilledItems != null && widget.prefilledItems!.isNotEmpty) {
      final total =
          widget.prefilledItems!.fold(0.0, (s, i) => s + i.totalPrice);
      _amountCtrl.text = total.toStringAsFixed(2);
      _splitType = SplitType.byItem;
      _category = ExpenseCategory.food;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    for (final c in _splitCtrlMap.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<ExpenseSplit> _computeSplits() {
    final amount = double.tryParse(_amountCtrl.text) ?? 0.0;
    final members = widget.group.members;
    final nameMap = {for (final m in members) m.userId: m.name};

    if (_splitType == SplitType.equal) {
      final perPerson = amount / members.length;
      return members
          .map((m) => ExpenseSplit(
                userId: m.userId,
                userName: m.name,
                amount:
                    double.parse(perPerson.toStringAsFixed(2)),
              ))
          .toList();
    }

    if (_splitType == SplitType.custom) {
      return members.map((m) {
        final val =
            double.tryParse(_splitCtrlMap[m.userId]?.text ?? '') ?? 0.0;
        return ExpenseSplit(
          userId: m.userId,
          userName: m.name,
          amount: val,
        );
      }).toList();
    }

    // byItem — compute from receipt items
    if (_splitType == SplitType.byItem && widget.prefilledItems != null) {
      final splitMap = <String, double>{};
      for (final m in members) {
        splitMap[m.userId] = 0.0;
      }
      for (final item in widget.prefilledItems!) {
        if (item.assignedUserIds.isEmpty) {
          // split equally among all
          final share = item.totalPrice / members.length;
          for (final m in members) {
            splitMap[m.userId] = (splitMap[m.userId] ?? 0) + share;
          }
        } else {
          final share = item.totalPrice / item.assignedUserIds.length;
          for (final uid in item.assignedUserIds) {
            splitMap[uid] = (splitMap[uid] ?? 0) + share;
          }
        }
      }
      return splitMap.entries
          .map((e) => ExpenseSplit(
                userId: e.key,
                userName: nameMap[e.key] ?? '',
                amount: double.parse(e.value.toStringAsFixed(2)),
              ))
          .toList();
    }

    return [];
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountCtrl.text) ?? 0.0;
    if (amount <= 0) {
      _showSnack('Enter a valid amount');
      return;
    }

    setState(() => _isSaving = true);

    final splits = _computeSplits();
    final expense = ExpenseModel(
      id: '',
      groupId: widget.group.id,
      title: _titleCtrl.text.trim(),
      amount: amount,
      paidBy: _paidById,
      paidByName: _paidByName,
      splitType: _splitType,
      splits: splits,
      category: _category,
      date: _date,
      createdAt: DateTime.now(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      receiptItems: widget.prefilledItems,
      currencyCode: widget.group.currencyCode,
    );

    await ref.read(expensesNotifierProvider.notifier).addExpense(expense);

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.97,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXl)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: AppSpacing.md),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: AppSpacing.borderRadiusFull,
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base, AppSpacing.md, AppSpacing.base, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Add Expense', style: AppTypography.headlineSmall),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: AppSpacing.paddingAll16,
                  children: [
                    // Amount (large, prominent)
                    AmountTextField(
                      controller: _amountCtrl,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter amount';
                        if (double.tryParse(v) == null) return 'Invalid amount';
                        return null;
                      },
                    ),

                    AppSpacing.hBase,

                    AppTextField(
                      label: 'What was it for?',
                      hint: 'Dinner, Uber, Groceries...',
                      controller: _titleCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Description is required'
                          : null,
                    ),

                    AppSpacing.hBase,

                    // Category row
                    Text('Category', style: AppTypography.titleSmall),
                    AppSpacing.hSm,
                    SizedBox(
                      height: 44,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: ExpenseCategory.values.map((cat) {
                          final selected = _category == cat;
                          return GestureDetector(
                            onTap: () => setState(() => _category = cat),
                            child: Container(
                              margin:
                                  const EdgeInsets.only(right: AppSpacing.sm),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primarySurface
                                    : AppColors.grey100,
                                borderRadius: AppSpacing.borderRadiusFull,
                                border: Border.all(
                                    color: selected
                                        ? AppColors.primary
                                        : Colors.transparent),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(_catEmoji(cat),
                                      style: const TextStyle(fontSize: 16)),
                                  AppSpacing.wXs,
                                  Text(
                                    _catLabel(cat),
                                    style: AppTypography.labelMedium.copyWith(
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    AppSpacing.hBase,

                    // Paid by
                    Text('Paid by', style: AppTypography.titleSmall),
                    AppSpacing.hSm,
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: widget.group.members.map((m) {
                        final selected = _paidById == m.userId;
                        return ChoiceChip(
                          label: Text(m.name.split(' ').first),
                          selected: selected,
                          onSelected: (_) => setState(() {
                            _paidById = m.userId;
                            _paidByName = m.name;
                          }),
                          selectedColor: AppColors.primarySurface,
                          labelStyle: AppTypography.labelMedium.copyWith(
                            color: selected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        );
                      }).toList(),
                    ),

                    AppSpacing.hBase,

                    // Split type
                    Text('Split', style: AppTypography.titleSmall),
                    AppSpacing.hSm,
                    Row(
                      children: [
                        _SplitTypeChip(
                          label: 'Equal',
                          icon: Icons.people,
                          selected: _splitType == SplitType.equal,
                          onTap: () =>
                              setState(() => _splitType = SplitType.equal),
                        ),
                        AppSpacing.wSm,
                        _SplitTypeChip(
                          label: 'Custom',
                          icon: Icons.tune,
                          selected: _splitType == SplitType.custom,
                          onTap: () =>
                              setState(() => _splitType = SplitType.custom),
                        ),
                        if (widget.prefilledItems != null) ...[
                          AppSpacing.wSm,
                          _SplitTypeChip(
                            label: 'By Item',
                            icon: Icons.receipt,
                            selected: _splitType == SplitType.byItem,
                            onTap: () =>
                                setState(() => _splitType = SplitType.byItem),
                          ),
                        ],
                      ],
                    ),

                    // Custom split fields
                    if (_splitType == SplitType.custom) ...[
                      AppSpacing.hBase,
                      ...widget.group.members.map((m) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(m.name.split(' ').first,
                                      style: AppTypography.bodyMedium),
                                ),
                                AppSpacing.wBase,
                                Expanded(
                                  flex: 1,
                                  child: TextFormField(
                                    controller: _splitCtrlMap[m.userId],
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: const InputDecoration(
                                      prefixText: '\$ ',
                                      hintText: '0.00',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],

                    AppSpacing.hBase,

                    // Date picker
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Date', style: AppTypography.titleSmall),
                      subtitle: Text(
                        DateFormat('MMMM d, yyyy').format(_date),
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.primary),
                      ),
                      trailing: const Icon(Icons.calendar_today_outlined,
                          color: AppColors.grey400),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (ctx, child) => Theme(
                            data: Theme.of(ctx).copyWith(
                              colorScheme: const ColorScheme.light(
                                  primary: AppColors.primary),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) setState(() => _date = picked);
                      },
                    ),

                    AppSpacing.hSm,

                    AppTextField(
                      label: 'Notes (optional)',
                      controller: _notesCtrl,
                      maxLines: 2,
                    ),

                    AppSpacing.hXl,

                    AppGradientButton(
                      label: 'Save Expense',
                      isLoading: _isSaving,
                      onPressed: _isSaving ? null : _save,
                    ),

                    AppSpacing.hXl,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _catEmoji(ExpenseCategory cat) => switch (cat) {
        ExpenseCategory.food => '🍕',
        ExpenseCategory.transport => '🚗',
        ExpenseCategory.accommodation => '🏨',
        ExpenseCategory.entertainment => '🎬',
        ExpenseCategory.utilities => '💡',
        ExpenseCategory.shopping => '🛒',
        ExpenseCategory.health => '💊',
        ExpenseCategory.other => '📝',
      };

  String _catLabel(ExpenseCategory cat) => switch (cat) {
        ExpenseCategory.food => 'Food',
        ExpenseCategory.transport => 'Transport',
        ExpenseCategory.accommodation => 'Stay',
        ExpenseCategory.entertainment => 'Fun',
        ExpenseCategory.utilities => 'Bills',
        ExpenseCategory.shopping => 'Shop',
        ExpenseCategory.health => 'Health',
        ExpenseCategory.other => 'Other',
      };
}

class _SplitTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SplitTypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySurface : AppColors.grey100,
          borderRadius: AppSpacing.borderRadiusFull,
          border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: selected ? AppColors.primary : AppColors.grey400),
            AppSpacing.wXs,
            Text(label,
                style: AppTypography.labelMedium.copyWith(
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
