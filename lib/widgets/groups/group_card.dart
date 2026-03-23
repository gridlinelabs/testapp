import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../models/group_model.dart';
import '../common/app_card.dart';
import 'member_avatar_stack.dart';

class GroupCard extends StatelessWidget {
  final GroupModel group;
  final String currentUserId;
  final VoidCallback? onTap;

  const GroupCard({
    super.key,
    required this.group,
    required this.currentUserId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final currentMember = group.members
        .where((m) => m.userId == currentUserId)
        .firstOrNull;
    final balance = currentMember?.balance ?? 0.0;

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusLg),
              ),
            ),
            child: Row(
              children: [
                // Category emoji circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      group.categoryEmoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                AppSpacing.wMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${group.memberCount} members · ${group.categoryLabel}',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total spent',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        AppSpacing.hXs,
                        Text(
                          formatter.format(group.totalExpenses),
                          style: AppTypography.amountSmall,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          balance >= 0 ? 'You are owed' : 'You owe',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        AppSpacing.hXs,
                        Text(
                          formatter.format(balance.abs()),
                          style: AppTypography.amountSmall.copyWith(
                            color: balance > 0.01
                                ? AppColors.positive
                                : balance < -0.01
                                    ? AppColors.negative
                                    : AppColors.neutral,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                AppSpacing.hMd,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MemberAvatarStack(
                      members: group.members.take(4).toList(),
                    ),
                    if (balance.abs() > 0.01)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: balance > 0
                              ? AppColors.accentSurface
                              : AppColors.errorSurface,
                          borderRadius: AppSpacing.borderRadiusFull,
                        ),
                        child: Text(
                          balance > 0 ? 'Settle up' : 'You owe',
                          style: AppTypography.labelSmall.copyWith(
                            color: balance > 0
                                ? AppColors.accentDark
                                : AppColors.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
