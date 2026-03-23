import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../models/expense_model.dart';
import '../../models/group_model.dart';
import '../common/app_card.dart';
import '../groups/member_avatar_stack.dart';

class BalanceSummaryCard extends StatelessWidget {
  final GroupModel group;
  final String currentUserId;
  final VoidCallback? onSettleUp;

  const BalanceSummaryCard({
    super.key,
    required this.group,
    required this.currentUserId,
    this.onSettleUp,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final me = group.members
        .where((m) => m.userId == currentUserId)
        .firstOrNull;
    final myBalance = me?.balance ?? 0.0;

    return GradientCard(
      gradient: myBalance >= 0
          ? AppColors.accentGradient
          : const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                myBalance >= 0 ? 'You are owed' : 'You owe',
                style: AppTypography.labelMedium.copyWith(
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
              if (myBalance.abs() > 0.01)
                GestureDetector(
                  onTap: onSettleUp,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: AppSpacing.borderRadiusFull,
                    ),
                    child: Text(
                      'Settle up',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          AppSpacing.hSm,
          Text(
            formatter.format(myBalance.abs()),
            style: AppTypography.amountLarge.copyWith(color: Colors.white),
          ),
          AppSpacing.hBase,
          const Divider(color: Colors.white24),
          AppSpacing.hMd,
          Text(
            'Group total',
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white.withOpacity(0.75),
            ),
          ),
          AppSpacing.hXs,
          Text(
            formatter.format(group.totalExpenses),
            style: AppTypography.titleMedium.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// Minimal debt settlement transactions list
class SettlementsView extends StatelessWidget {
  final List<SettlementTransaction> transactions;
  final String currentUserId;
  final void Function(SettlementTransaction)? onSettle;

  const SettlementsView({
    super.key,
    required this.transactions,
    required this.currentUserId,
    this.onSettle,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Padding(
        padding: AppSpacing.paddingAll16,
        child: Row(
          children: [
            const Icon(Icons.check_circle,
                color: AppColors.positive, size: 20),
            AppSpacing.wSm,
            Text(
              'All settled up!',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.positive),
            ),
          ],
        ),
      );
    }

    return Column(
      children: transactions.map((t) {
        final isMe = t.fromUserId == currentUserId;
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              MemberAvatar(name: t.fromUserName, colorIndex: 0, size: 36),
              AppSpacing.wSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMe ? 'You' : t.fromUserName,
                      style: AppTypography.titleSmall,
                    ),
                    Text(
                      '→ ${t.toUserId == currentUserId ? 'You' : t.toUserName}',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                '\$${t.amount.toStringAsFixed(2)}',
                style: AppTypography.amountSmall.copyWith(
                  color: isMe ? AppColors.negative : AppColors.positive,
                  fontSize: 16,
                ),
              ),
              if (isMe && onSettle != null) ...[
                AppSpacing.wSm,
                TextButton(
                  onPressed: () => onSettle!(t),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  ),
                  child: const Text('Settle'),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}
