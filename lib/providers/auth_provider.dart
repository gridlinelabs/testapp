import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Raw Firebase auth state stream
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Current logged-in user model
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return null;
      return ref.read(authServiceProvider).getCurrentUserModel();
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Auth notifier for login/register actions
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.data(null));

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _authService.signInWithEmail(email: email, password: password));
  }

  Future<void> signUpWithEmail(
      String email, String password, String name) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authService.signUpWithEmail(
          email: email,
          password: password,
          name: name,
        ));
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state =
        await AsyncValue.guard(() => _authService.signInWithGoogle());
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AsyncValue.data(null);
  }

  Future<void> sendPasswordReset(String email) =>
      _authService.sendPasswordResetEmail(email);
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
