import 'package:flutter/material.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Container(
                padding: AppSpacing.paddingAll24,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.borderRadiusLg,
                  boxShadow: AppSpacing.shadowLg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 3,
                    ),
                    if (message != null) ...[
                      AppSpacing.hBase,
                      Text(
                        message!,
                        style: AppTypography.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Inline loading state
class AppLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double size;

  const AppLoadingIndicator({super.key, this.color, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: color ?? AppColors.primary,
        ),
      ),
    );
  }
}

/// Empty state widget
class AppEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final Widget? icon;
  final Widget? action;

  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x3l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              AppSpacing.hXl,
            ],
            Text(
              title,
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            AppSpacing.hSm,
            Text(
              message,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              AppSpacing.hXl,
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state widget
class AppErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x2l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppColors.error),
            AppSpacing.hBase,
            Text(
              'Something went wrong',
              style: AppTypography.titleMedium,
            ),
            AppSpacing.hSm,
            Text(
              message,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              AppSpacing.hXl,
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
