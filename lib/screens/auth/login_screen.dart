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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).signInWithEmail(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
  }

  Future<void> _handleGoogleLogin() async {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
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
      body: LoadingOverlay(
        isLoading: isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.x2l,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.hX2l,
                  // Logo
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: AppSpacing.borderRadiusLg,
                      boxShadow: AppSpacing.shadowPrimary,
                    ),
                    child: const Center(
                      child: Text('💸', style: TextStyle(fontSize: 32)),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.3, end: 0),

                  AppSpacing.hXl,

                  Text('Welcome back', style: AppTypography.headlineMedium)
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 400.ms),

                  AppSpacing.hXs,

                  Text(
                    'Sign in to split bills with friends',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

                  AppSpacing.hX3l,

                  // Email field
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
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                  AppSpacing.hMd,

                  // Password field
                  AppTextField(
                    label: 'Password',
                    controller: _passwordCtrl,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: AppColors.grey400, size: 20),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 6) return 'At least 6 characters';
                      return null;
                    },
                    onFieldSubmitted: (_) => _handleEmailLogin(),
                  ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

                  AppSpacing.hSm,

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      child: Text(
                        'Forgot password?',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  AppSpacing.hBase,

                  // Login button
                  AppGradientButton(
                    label: 'Sign In',
                    onPressed: isLoading ? null : _handleEmailLogin,
                    isLoading: isLoading,
                  ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

                  AppSpacing.hXl,

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.base),
                        child: Text(
                          'or continue with',
                          style: AppTypography.bodySmall,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ).animate().fadeIn(delay: 400.ms),

                  AppSpacing.hXl,

                  // Google sign in
                  AppButton(
                    label: 'Continue with Google',
                    onPressed: isLoading ? null : _handleGoogleLogin,
                    variant: AppButtonVariant.outline,
                    leadingIcon: const Text('G',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        )),
                  ).animate().fadeIn(delay: 450.ms, duration: 400.ms),

                  AppSpacing.hX2l,

                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/register'),
                        child: Text(
                          'Sign Up',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 500.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
