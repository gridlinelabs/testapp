import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/groups/group_detail_screen.dart';
import 'screens/scanner/receipt_scanner_screen.dart';
import 'screens/premium/upgrade_screen.dart';
import 'design/colors.dart';
import 'design/typography.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const _ForgotPasswordScreen(),
      ),

      // Main app routes
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/group/:id',
        builder: (_, state) => GroupDetailScreen(
          groupId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/scanner/:groupId',
        builder: (_, state) => ReceiptScannerScreen(
          groupId: state.pathParameters['groupId']!,
        ),
      ),
      GoRoute(
        path: '/upgrade',
        builder: (_, __) => const UpgradeScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const _ProfileScreen(),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.error}')),
    ),
  );
});

// ── Simple screens that don't need their own files ──────────────────────────

class _ForgotPasswordScreen extends ConsumerStatefulWidget {
  const _ForgotPasswordScreen();

  @override
  ConsumerState<_ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends ConsumerState<_ForgotPasswordScreen> {
  final _ctrl = TextEditingController();
  bool _sent = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mark_email_read,
                      size: 72, color: AppColors.accent),
                  const SizedBox(height: 24),
                  const Text('Check your email',
                      style: AppTypography.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    'We sent password reset instructions to ${_ctrl.text}',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Back to Sign In'),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Forgot Password',
                      style: AppTypography.headlineMedium),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your email and we\'ll send you reset instructions.',
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _ctrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading
                          ? null
                          : () async {
                              setState(() => _loading = true);
                              await ref
                                  .read(authNotifierProvider.notifier)
                                  .sendPasswordReset(_ctrl.text.trim());
                              if (mounted) {
                                setState(() {
                                  _loading = false;
                                  _sent = true;
                                });
                              }
                            },
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Send Reset Email'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ProfileScreen extends ConsumerWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
              context.go('/login');
            },
            child: const Text('Sign Out',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primary,
              backgroundImage: user?.photoUrl != null
                  ? NetworkImage(user!.photoUrl!)
                  : null,
              child: user?.photoUrl == null
                  ? Text(
                      user?.initials ?? '?',
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(user?.name ?? '', style: AppTypography.headlineSmall),
            Text(user?.email ?? '',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            if (!( user?.isPremium ?? false))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/upgrade'),
                  icon: const Icon(Icons.star, color: Colors.white),
                  label: const Text('Upgrade to Pro'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(0, 52),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
