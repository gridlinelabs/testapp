import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? initialValue;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.focusNode,
    this.onChanged,
    this.onFieldSubmitted,
    this.textInputAction,
    this.readOnly = false,
    this.onTap,
    this.initialValue,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final isPassword = widget.obscureText;

    return TextFormField(
      controller: widget.controller,
      initialValue: widget.initialValue,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      obscureText: isPassword ? _obscureText : false,
      maxLines: isPassword ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      textCapitalization: widget.textCapitalization,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      textInputAction: widget.textInputAction,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.grey400,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : widget.suffixIcon,
        counterText: '',
      ),
    );
  }
}

/// Currency amount field
class AmountTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String currencySymbol;

  const AmountTextField({
    super.key,
    this.controller,
    this.validator,
    this.onChanged,
    this.currencySymbol = '\$',
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      style: AppTypography.amountMedium,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: '0.00',
        hintStyle: AppTypography.amountMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        prefixText: '$currencySymbol ',
        prefixStyle: AppTypography.amountMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.primarySurface,
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusLg,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusLg,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusLg,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xl,
          horizontal: AppSpacing.base,
        ),
      ),
    );
  }
}
