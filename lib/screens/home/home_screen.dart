import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../design/buttons.dart';
import '../../providers/auth_provider.dart';
import '../../providers/groups_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/groups/group_card.dart';
import '../groups/create_group_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final groupsAsync = ref.watch(userGroupsProvider);
    final canCreate = ref.watch(canCreateGroupProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _HomeHeader(
              userName: currentUser?.name.split(' ').first ?? 'there',
              avatarUrl: currentUser?.photoUrl,
              onProfileTap: () => context.push('/profile'),
            ),

            // Body
            Expanded(
              child: groupsAsync.when(
                loading: () => const AppLoadingIndicator(),
                error: (e, _) => AppErrorState(
                  message: e.toString(),
                  onRetry: () => ref.refresh(userGroupsProvider),
                ),
                data: (groups) {
                  if (groups.isEmpty) {
                    return _EmptyGroupsState(
                      onCreateGroup: () => _showCreateGroup(context),
                    );
                  }

                  // Compute total balance across all groups
                  final uid = authState.valueOrNull?.uid ?? '';
                  double totalOwed = 0;
                  double totalOwe = 0;
                  for (final g in groups) {
                    final me = g.members
                        .where((m) => m.userId == uid)
                        .firstOrNull;
                    final b = me?.balance ?? 0.0;
                    if (b > 0) totalOwed += b;
                    if (b < 0) totalOwe += b.abs();
                  }

                  return CustomScrollView(
                    slivers: [
                      // Balance overview
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.base,
                            AppSpacing.sm,
                            AppSpacing.base,
                            AppSpacing.base,
                          ),
                          child: _BalanceOverview(
                            totalOwed: totalOwed,
                            totalOwe: totalOwe,
                          ),
                        ),
                      ),

                      // Groups header
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.base),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Your Groups',
                                  style: AppTypography.titleMedium),
                              if (!canCreate)
                                GestureDetector(
                                  onTap: () => context.push('/upgrade'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: AppSpacing.xs,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius:
                                          AppSpacing.borderRadiusFull,
                                    ),
                                    child: Text(
                                      'Upgrade',
                                      style: AppTypography.labelSmall.copyWith(
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.base,
                          AppSpacing.md,
                          AppSpacing.base,
                          AppSpacing.x5l,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) => Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppSpacing.md),
                              child: GroupCard(
                                group: groups[i],
                                currentUserId: uid,
                                onTap: () {
                                  ref
                                      .read(selectedGroupIdProvider.notifier)
                                      .state = groups[i].id;
                                  context.push('/group/${groups[i].id}');
                                },
                              ),
                            ),
                            childCount: groups.length,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: canCreate
            ? () => _showCreateGroup(context)
            : () => context.push('/upgrade'),
        backgroundColor: AppColors.primary,
        icon: Icon(canCreate ? Icons.add : Icons.lock, color: Colors.white),
        label: Text(
          canCreate ? 'New Group' : 'Upgrade',
          style: AppTypography.labelLarge.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  void _showCreateGroup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateGroupSheet(),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final VoidCallback? onProfileTap;

  const _HomeHeader({
    required this.userName,
    this.avatarUrl,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.base,
        AppSpacing.base,
        AppSpacing.sm,
      ),
      color: AppColors.surface,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hey, $userName 👋', style: AppTypography.headlineSmall),
                Text(
                  'Ready to split some bills?',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                image: avatarUrl != null
                    ? DecorationImage(
                        image: NetworkImage(avatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: avatarUrl == null
                  ? Center(
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                        style: AppTypography.titleSmall.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceOverview extends StatelessWidget {
  final double totalOwed;
  final double totalOwe;

  const _BalanceOverview({
    required this.totalOwed,
    required this.totalOwe,
  });

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return Container(
      padding: AppSpacing.paddingAll16,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppSpacing.borderRadiusXl,
        boxShadow: AppSpacing.shadowPrimary,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You are owed',
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white70,
                  ),
                ),
                AppSpacing.hXs,
                Text(
                  f.format(totalOwed),
                  style: AppTypography.amountMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You owe',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  AppSpacing.hXs,
                  Text(
                    f.format(totalOwe),
                    style: AppTypography.amountMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyGroupsState extends StatelessWidget {
  final VoidCallback onCreateGroup;

  const _EmptyGroupsState({required this.onCreateGroup});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x3l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('👥', style: TextStyle(fontSize: 48)),
              ),
            ),
            AppSpacing.hXl,
            Text(
              'No groups yet',
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
            AppSpacing.hSm,
            Text(
              'Create a group to start splitting bills with your friends, roommates, or travel buddies.',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            AppSpacing.hX2l,
            AppGradientButton(
              label: 'Create First Group',
              onPressed: onCreateGroup,
              leadingIcon: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
