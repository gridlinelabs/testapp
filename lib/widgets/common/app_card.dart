import 'package:flutter/material.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';

/// Base card with shadow, border, and tap feedback
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final double? width;
  final double? height;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.border,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surface,
          borderRadius: borderRadius ?? AppSpacing.borderRadiusLg,
          boxShadow: boxShadow ?? AppSpacing.shadowSm,
          border: border ??
              Border.all(color: AppColors.border, width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius ?? AppSpacing.borderRadiusLg,
            splashColor: AppColors.primary.withOpacity(0.05),
            highlightColor: AppColors.primary.withOpacity(0.03),
            child: Padding(
              padding: padding ?? AppSpacing.paddingAll16,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Gradient card (used for summary/highlight sections)
class GradientCard extends StatelessWidget {
  final Widget child;
  final LinearGradient gradient;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const GradientCard({
    super.key,
    required this.child,
    this.gradient = AppColors.primaryGradient,
    this.padding,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? AppSpacing.paddingAll16,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: borderRadius ?? AppSpacing.borderRadiusXl,
          boxShadow: AppSpacing.shadowPrimary,
        ),
        child: child,
      ),
    );
  }
}

/// Subtle surface card (for secondary content)
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? color;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: padding,
      backgroundColor: color ?? AppColors.grey50,
      boxShadow: const [],
      border: Border.all(color: AppColors.border, width: 0.5),
      child: child,
    );
  }
}
