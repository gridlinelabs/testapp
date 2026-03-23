import 'package:flutter/material.dart';
import 'colors.dart';
import 'spacing.dart';
import 'typography.dart';

/// BillSplit AI — Button Design System
/// Covers all button variants used across the app

enum AppButtonVariant { primary, secondary, outline, ghost, danger }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool isLoading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final height = _height;
    final padding = _padding;
    final textStyle = _textStyle;
    final bgColor = _backgroundColor(context);
    final fgColor = _foregroundColor(context);
    final border = _border(context);

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: AnimatedOpacity(
        opacity: onPressed == null ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: fgColor,
            disabledBackgroundColor: bgColor,
            disabledForegroundColor: fgColor,
            elevation: 0,
            shadowColor: Colors.transparent,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusMd,
              side: border,
            ),
            minimumSize: Size(0, height),
          ),
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (leadingIcon != null) ...[
                      leadingIcon!,
                      AppSpacing.wSm,
                    ],
                    Text(label, style: textStyle.copyWith(color: fgColor)),
                    if (trailingIcon != null) ...[
                      AppSpacing.wSm,
                      trailingIcon!,
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  double get _height => switch (size) {
        AppButtonSize.small => AppSpacing.buttonHeightSmall,
        AppButtonSize.medium => AppSpacing.buttonHeight,
        AppButtonSize.large => AppSpacing.buttonHeight + 8,
      };

  EdgeInsets get _padding => switch (size) {
        AppButtonSize.small =>
          const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        AppButtonSize.medium =>
          const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        AppButtonSize.large =>
          const EdgeInsets.symmetric(horizontal: AppSpacing.x2l),
      };

  TextStyle get _textStyle => switch (size) {
        AppButtonSize.small => AppTypography.labelMedium,
        AppButtonSize.medium => AppTypography.labelLarge,
        AppButtonSize.large =>
          AppTypography.labelLarge.copyWith(fontSize: 16),
      };

  Color _backgroundColor(BuildContext context) => switch (variant) {
        AppButtonVariant.primary => AppColors.primary,
        AppButtonVariant.secondary => AppColors.primarySurface,
        AppButtonVariant.outline => Colors.transparent,
        AppButtonVariant.ghost => Colors.transparent,
        AppButtonVariant.danger => AppColors.error,
      };

  Color _foregroundColor(BuildContext context) => switch (variant) {
        AppButtonVariant.primary => AppColors.textInverse,
        AppButtonVariant.secondary => AppColors.primary,
        AppButtonVariant.outline => AppColors.primary,
        AppButtonVariant.ghost => AppColors.textSecondary,
        AppButtonVariant.danger => AppColors.textInverse,
      };

  BorderSide _border(BuildContext context) => switch (variant) {
        AppButtonVariant.outline =>
          const BorderSide(color: AppColors.primary, width: 1.5),
        _ => BorderSide.none,
      };
}

/// Icon-only circular button
class AppIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.grey100,
          shape: BoxShape.circle,
        ),
        child: Center(child: icon),
      ),
    );
  }
}

/// Gradient primary button
class AppGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? leadingIcon;

  const AppGradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedOpacity(
        opacity: onPressed == null ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: AppSpacing.borderRadiusMd,
            boxShadow: AppSpacing.shadowPrimary,
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.textInverse),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (leadingIcon != null) ...[
                        leadingIcon!,
                        AppSpacing.wSm,
                      ],
                      Text(
                        label,
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.textInverse,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
