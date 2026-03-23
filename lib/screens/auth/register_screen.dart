import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../design/buttons.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/loading_overlay.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).signUpWithEmail(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
          _nameCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    ref.listen(authNotifierProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      } else if (next.hasValue && next.value != null) {
        context.go('/home');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
          color: AppColors.textPrimary,
        ),
      ),
      body: LoadingOverlay(
        isLoading: isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.base,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Create account', style: AppTypography.headlineMedium)
                      .animate()
                      .fadeIn(duration: 400.ms),
                  AppSpacing.hXs,
                  Text(
                    'Join BillSplit AI and split smarter',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 100.ms),

                  AppSpacing.hX2l,

                  AppTextField(
                    label: 'Full Name',
                    hint: 'Alex Johnson',
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.person_outline,
                        color: AppColors.grey400, size: 20),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Name is required';
                      }
                      if (v.trim().length < 2) {
                        return 'Name is too short';
                      }
                      return null;
                    },
                  ).animate().fadeIn(delay: 150.ms),

                  AppSpacing.hMd,

                  AppTextField(
                    label: 'Email',
                    hint: 'you@example.com',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.email_outlined,
                        color: AppColors.grey400, size: 20),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email is required';
                      if (!RegExp(r'^[\w\.\-]+@[\w\-]+\.\w{2,}$')
                          .hasMatch(v)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ).animate().fadeIn(delay: 200.ms),

                  AppSpacing.hMd,

                  AppTextField(
                    label: 'Password',
                    controller: _passwordCtrl,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: AppColors.grey400, size: 20),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 8) return 'At least 8 characters';
                      if (!RegExp(r'[0-9]').hasMatch(v)) {
                        return 'Include at least one number';
                      }
                      return null;
                    },
                  ).animate().fadeIn(delay: 250.ms),

                  AppSpacing.hMd,

                  AppTextField(
                    label: 'Confirm Password',
                    controller: _confirmPasswordCtrl,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: AppColors.grey400, size: 20),
                    validator: (v) {
                      if (v != _passwordCtrl.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _handleRegister(),
                  ).animate().fadeIn(delay: 300.ms),

                  AppSpacing.hXl,

                  // Terms note
                  Text(
                    'By creating an account, you agree to our Terms of Service and Privacy Policy.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 350.ms),

                  AppSpacing.hBase,

                  AppGradientButton(
                    label: 'Create Account',
                    onPressed: isLoading ? null : _handleRegister,
                    isLoading: isLoading,
                  ).animate().fadeIn(delay: 400.ms),

                  AppSpacing.hXl,

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          'Sign In',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 450.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
