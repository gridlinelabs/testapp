import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../design/buttons.dart';
import '../../models/group_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/groups_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/app_text_field.dart';

class CreateGroupSheet extends ConsumerStatefulWidget {
  const CreateGroupSheet({super.key});

  @override
  ConsumerState<CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends ConsumerState<CreateGroupSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  GroupCategory _selectedCategory = GroupCategory.other;
  final List<GroupMember> _members = [];
  bool _isAddingMember = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _addMemberByEmail() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return;

    if (_members.any((m) => m.email == email)) {
      _showSnack('Member already added');
      return;
    }

    setState(() => _isAddingMember = true);

    final authService = ref.read(authServiceProvider);
    final user = await authService.findUserByEmail(email);

    if (!mounted) return;
    setState(() => _isAddingMember = false);

    if (user == null) {
      _showSnack('No user found with that email');
      return;
    }

    setState(() {
      _members.add(GroupMember(
        userId: user.id,
        name: user.name,
        email: user.email,
        photoUrl: user.photoUrl,
      ));
      _emailCtrl.clear();
    });
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_members.isEmpty) {
      _showSnack('Add at least one member');
      return;
    }

    setState(() => _isSaving = true);

    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;

    // Add self as first member
    final allMembers = [
      GroupMember(
        userId: currentUser.id,
        name: currentUser.name,
        email: currentUser.email,
        photoUrl: currentUser.photoUrl,
      ),
      ..._members,
    ];

    final group = GroupModel(
      id: '', // will be assigned by Firestore
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      category: _selectedCategory,
      createdBy: currentUser.id,
      members: allMembers,
      createdAt: DateTime.now(),
    );

    final created =
        await ref.read(groupsNotifierProvider.notifier).createGroup(group);

    if (!mounted) return;
    setState(() => _isSaving = false);

    Navigator.of(context).pop();
    if (created != null) {
      context.push('/group/${created.id}');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
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
                AppSpacing.base,
                AppSpacing.md,
                AppSpacing.base,
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('New Group', style: AppTypography.headlineSmall),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: scrollCtrl,
                  padding: AppSpacing.paddingAll16,
                  children: [
                    AppTextField(
                      label: 'Group Name',
                      hint: 'Weekend Trip, Apartment, etc.',
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Group name is required';
                        }
                        return null;
                      },
                    ),
                    AppSpacing.hMd,
                    AppTextField(
                      label: 'Description (optional)',
                      hint: 'What is this group for?',
                      controller: _descCtrl,
                      maxLines: 2,
                    ),
                    AppSpacing.hXl,

                    // Category picker
                    Text('Category', style: AppTypography.titleSmall),
                    AppSpacing.hMd,
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: GroupCategory.values.map((cat) {
                        final selected = _selectedCategory == cat;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedCategory = cat),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primarySurface
                                  : AppColors.grey100,
                              borderRadius: AppSpacing.borderRadiusFull,
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_categoryEmoji(cat),
                                    style: const TextStyle(fontSize: 16)),
                                AppSpacing.wXs,
                                Text(
                                  _categoryLabel(cat),
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

                    AppSpacing.hXl,

                    // Add members
                    Text('Add Members', style: AppTypography.titleSmall),
                    AppSpacing.hXs,
                    Text(
                      'Search by email address',
                      style: AppTypography.bodySmall,
                    ),
                    AppSpacing.hMd,
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Email address',
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _addMemberByEmail(),
                          ),
                        ),
                        AppSpacing.wSm,
                        AppIconButton(
                          icon: _isAddingMember
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Icon(Icons.add, color: AppColors.primary),
                          onPressed:
                              _isAddingMember ? null : _addMemberByEmail,
                          backgroundColor: AppColors.primarySurface,
                          size: 52,
                        ),
                      ],
                    ),

                    if (_members.isNotEmpty) ...[
                      AppSpacing.hBase,
                      ..._members.asMap().entries.map((entry) {
                        final i = entry.key;
                        final member = entry.value;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: AppColors.avatarColor(i),
                            child: Text(
                              member.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          title: Text(member.name,
                              style: AppTypography.titleSmall),
                          subtitle: Text(member.email,
                              style: AppTypography.bodySmall),
                          trailing: IconButton(
                            icon: const Icon(Icons.close,
                                size: 18, color: AppColors.grey400),
                            onPressed: () =>
                                setState(() => _members.removeAt(i)),
                          ),
                        );
                      }),
                    ],

                    AppSpacing.hX2l,

                    AppGradientButton(
                      label: 'Create Group',
                      isLoading: _isSaving,
                      onPressed: _isSaving ? null : _createGroup,
                    ),

                    AppSpacing.hXl,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryEmoji(GroupCategory cat) => switch (cat) {
        GroupCategory.home => '🏠',
        GroupCategory.trip => '✈️',
        GroupCategory.food => '🍕',
        GroupCategory.event => '🎉',
        GroupCategory.couple => '💑',
        GroupCategory.other => '💼',
      };

  String _categoryLabel(GroupCategory cat) => switch (cat) {
        GroupCategory.home => 'Home',
        GroupCategory.trip => 'Trip',
        GroupCategory.food => 'Food',
        GroupCategory.event => 'Event',
        GroupCategory.couple => 'Couple',
        GroupCategory.other => 'Other',
      };
}
