import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../models/expense_model.dart';

class ExpenseItem extends StatelessWidget {
  final ExpenseModel expense;
  final String currentUserId;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ExpenseItem({
    super.key,
    required this.expense,
    required this.currentUserId,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormatter = DateFormat('MMM d');
    final myShare = expense.amountOwedBy(currentUserId);
    final iPaid = expense.paidBy == currentUserId;

    Color amountColor;
    String amountLabel;
    double displayAmount;

    if (iPaid) {
      // I paid: I'm owed back (expense.amount - myShare)
      displayAmount = expense.amount - myShare;
      amountColor = AppColors.positive;
      amountLabel = 'you lent';
    } else if (myShare > 0) {
      displayAmount = myShare;
      amountColor = AppColors.negative;
      amountLabel = 'you owe';
    } else {
      displayAmount = expense.amount;
      amountColor = AppColors.neutral;
      amountLabel = 'not involved';
    }

    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: AppSpacing.borderRadiusMd,
              ),
              child: Center(
                child: Text(
                  expense.categoryEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            AppSpacing.wMd,
            // Title + paid by
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: AppTypography.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.hXs,
                  Text(
                    '${expense.paidByName} paid · ${dateFormatter.format(expense.date)}',
                    style: AppTypography.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            AppSpacing.wMd,
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatter.format(displayAmount),
                  style: AppTypography.amountSmall.copyWith(
                    color: amountColor,
                    fontSize: 16,
                  ),
                ),
                AppSpacing.hXs,
                Text(
                  amountLabel,
                  style: AppTypography.labelSmall.copyWith(
                    color: amountColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
