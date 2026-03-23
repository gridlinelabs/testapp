import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../design/buttons.dart';
import '../../widgets/common/app_card.dart';

class UpgradeScreen extends StatelessWidget {
  const UpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
          color: AppColors.textSecondary,
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hero
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: AppSpacing.shadowPrimary,
              ),
              child: const Center(
                child: Text('⚡', style: TextStyle(fontSize: 48)),
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.7, 0.7)),

            AppSpacing.hXl,

            Text(
              'Upgrade to Pro',
              style: AppTypography.headlineMedium,
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),

            AppSpacing.hSm,

            Text(
              'Unlock unlimited groups, AI scanning, and advanced features',
              style: AppTypography.bodyLarge
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 150.ms),

            AppSpacing.hX2l,

            // Pricing cards
            _PricingCard(
              title: 'Monthly',
              price: '\$3.99',
              period: '/month',
              isPopular: false,
              onTap: () {},
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),

            AppSpacing.hMd,

            _PricingCard(
              title: 'Annual',
              price: '\$29.99',
              period: '/year',
              badge: 'Save 37%',
              isPopular: true,
              onTap: () {},
            ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.3, end: 0),

            AppSpacing.hX2l,

            // Feature list
            Text('Everything in Pro', style: AppTypography.titleMedium)
                .animate()
                .fadeIn(delay: 300.ms),

            AppSpacing.hBase,

            ..._proFeatures.asMap().entries.map((e) => _FeatureRow(
                  icon: e.value.$1,
                  title: e.value.$2,
                  subtitle: e.value.$3,
                ).animate().fadeIn(delay: (350 + e.key * 50).ms)),

            AppSpacing.hX2l,

            // CTA
            AppGradientButton(
              label: 'Start Free 7-Day Trial',
              onPressed: () {
                // Payment integration goes here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Payment integration coming soon!')),
                );
              },
            ).animate().fadeIn(delay: 600.ms),

            AppSpacing.hMd,

            Text(
              'Cancel anytime. No commitment.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 650.ms),

            AppSpacing.hXl,
          ],
        ),
      ),
    );
  }
}

const _proFeatures = [
  (Icons.group_add, 'Unlimited Groups',
      'Create as many groups as you need'),
  (Icons.receipt_long, 'AI Receipt Scanning',
      'Scan and parse receipts instantly'),
  (Icons.auto_awesome, 'Smart AI Splitting',
      'Let AI suggest who ordered what'),
  (Icons.bar_chart, 'Expense Analytics',
      'Track spending trends over time'),
  (Icons.cloud_download, 'Export to CSV/PDF',
      'Download your expense reports'),
  (Icons.notifications_active, 'Smart Reminders',
      'Gentle nudges to settle debts'),
  (Icons.palette, 'Custom Themes',
      'Personalize your app experience'),
  (Icons.support_agent, 'Priority Support',
      'Get help when you need it'),
];

class _PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final String? badge;
  final bool isPopular;
  final VoidCallback onTap;

  const _PricingCard({
    required this.title,
    required this.price,
    required this.period,
    this.badge,
    required this.isPopular,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.paddingAll16,
        decoration: BoxDecoration(
          gradient:
              isPopular ? AppColors.primaryGradient : null,
          color: isPopular ? null : AppColors.surface,
          borderRadius: AppSpacing.borderRadiusLg,
          border: Border.all(
            color: isPopular ? Colors.transparent : AppColors.border,
            width: isPopular ? 0 : 1.5,
          ),
          boxShadow: isPopular ? AppSpacing.shadowPrimary : AppSpacing.shadowSm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTypography.titleMedium.copyWith(
                          color:
                              isPopular ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      if (badge != null) ...[
                        AppSpacing.wSm,
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: AppSpacing.borderRadiusFull,
                          ),
                          child: Text(
                            badge!,
                            style: AppTypography.labelSmall.copyWith(
                              color: isPopular
                                  ? Colors.white
                                  : AppColors.primary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (isPopular)
                    Text(
                      'Most popular choice',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: AppTypography.amountSmall.copyWith(
                    color: isPopular ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    period,
                    style: AppTypography.bodySmall.copyWith(
                      color: isPopular ? Colors.white70 : AppColors.textSecondary,
                    ),
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

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          AppSpacing.wMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleSmall),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: AppColors.accent, size: 20),
        ],
      ),
    );
  }
}
