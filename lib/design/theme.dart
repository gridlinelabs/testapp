import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';
import 'spacing.dart';

/// BillSplit AI — App Theme
/// Light + Dark mode support with Material 3

abstract class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: AppColors.textInverse,
          primaryContainer: AppColors.primarySurface,
          onPrimaryContainer: AppColors.primaryDark,
          secondary: AppColors.accent,
          onSecondary: AppColors.textInverse,
          secondaryContainer: AppColors.accentSurface,
          onSecondaryContainer: AppColors.accentDark,
          error: AppColors.error,
          onError: AppColors.textInverse,
          errorContainer: AppColors.errorSurface,
          onErrorContainer: AppColors.error,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          surfaceContainerHighest: AppColors.surfaceVariant,
          onSurfaceVariant: AppColors.textSecondary,
          outline: AppColors.border,
          outlineVariant: AppColors.grey200,
          shadow: Colors.black,
          scrim: Colors.black,
          inverseSurface: AppColors.grey900,
          onInverseSurface: AppColors.grey50,
          inversePrimary: AppColors.primaryLight,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: AppTypography.fontFamily,
        textTheme: AppTypography.textTheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: false,
          titleTextStyle: AppTypography.titleLarge,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
        cardTheme: CardTheme(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusLg,
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.grey50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusMd,
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusMd,
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusMd,
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusMd,
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusMd,
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          labelStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          errorStyle: AppTypography.bodySmall.copyWith(
            color: AppColors.error,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textInverse,
            elevation: 0,
            minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
            shape: const RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            textStyle: AppTypography.labelLarge,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
            shape: const RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            textStyle: AppTypography.labelLarge,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: AppTypography.labelLarge,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textInverse,
          elevation: 4,
          shape: CircleBorder(),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.grey100,
          selectedColor: AppColors.primarySurface,
          labelStyle: AppTypography.labelMedium,
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusFull,
          ),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
          space: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.grey400,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: AppTypography.labelSmall,
          unselectedLabelStyle: AppTypography.labelSmall,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.grey900,
          contentTextStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textInverse,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          behavior: SnackBarBehavior.floating,
        ),
        dialogTheme: const DialogTheme(
          backgroundColor: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusXl,
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXl),
            ),
          ),
          elevation: 0,
        ),
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.xs,
          ),
          minVerticalPadding: AppSpacing.sm,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.surface;
            }
            return AppColors.grey400;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return AppColors.grey200;
          }),
        ),
      );

  static ThemeData get dark => light.copyWith(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.primaryLight,
          onPrimary: AppColors.grey900,
          primaryContainer: AppColors.primaryDark,
          onPrimaryContainer: AppColors.primaryLight,
          secondary: AppColors.accentLight,
          onSecondary: AppColors.grey900,
          secondaryContainer: AppColors.accentDark,
          onSecondaryContainer: AppColors.accentLight,
          error: AppColors.error,
          onError: AppColors.textInverse,
          errorContainer: AppColors.errorSurface,
          onErrorContainer: AppColors.error,
          surface: AppColors.surfaceDark,
          onSurface: AppColors.textPrimaryDark,
          surfaceContainerHighest: AppColors.surfaceVariantDark,
          onSurfaceVariant: AppColors.textSecondaryDark,
          outline: AppColors.borderDark,
          outlineVariant: AppColors.grey700,
          shadow: Colors.black,
          scrim: Colors.black,
          inverseSurface: AppColors.grey100,
          onInverseSurface: AppColors.grey900,
          inversePrimary: AppColors.primary,
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surfaceDark,
          foregroundColor: AppColors.textPrimaryDark,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
      );
}
