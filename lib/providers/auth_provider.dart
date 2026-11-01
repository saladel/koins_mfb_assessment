import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import 'app_providers.dart';
import 'insight_provider.dart';
import 'product_provider.dart';
import 'savings_provider.dart';

/// Immutable auth state.
///
/// Auth uses a plain [Notifier] rather than an `AsyncNotifier` because the
/// router needs to read `isAuthenticated` synchronously inside `redirect`.
/// An `AsyncValue` there would mean handling a loading state on every
/// navigation, which is noise for a session we can read from Hive instantly.
class AuthState {
  const AuthState({this.user, this.isSubmitting = false, this.errorMessage});

  final UserModel? user;
  final bool isSubmitting;
  final String? errorMessage;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserModel? user,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Restores a persisted session on cold start.
    return AuthState(user: ref.read(authRepositoryProvider).currentUser);
  }

  /// Returns true on success. The screen uses the return value to navigate,
  /// and reads `state.errorMessage` to render the failure inline.
  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final UserModel user = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);

      state = AuthState(user: user);
      return true;
    } on AuthException catch (error) {
      state = state.copyWith(isSubmitting: false, errorMessage: error.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    ref.invalidate(savingsProvider);
    ref.invalidate(productsProvider);
    ref.invalidate(insightsProvider);
    state = const AuthState();
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final NotifierProvider<AuthNotifier, AuthState> authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

/// Convenience selector so widgets rebuild only when the user object changes.
final Provider<UserModel?> currentUserProvider = Provider<UserModel?>(
  (ref) => ref.watch(authProvider).user,
);
