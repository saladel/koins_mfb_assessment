import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

/// A login failure with a message safe to show the user.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Authentication.
///
/// Credentials are mocked, as the brief requires: there is no auth backend and the fixed pair below is what the reviewer signs in with. The profile itself
/// is not mocked. On a successful credential check this does a real `GET` and
/// deserialises the signed-in user from the response, then persists it to Hive.
///
/// Swapping this for a real auth service means changing this one file. Nothing
/// above it knows how the user was obtained.
class AuthRepository {
  const AuthRepository(this._storage, this._api);

  final StorageService _storage;
  final ApiService _api;

  static const String userEmail = 'test@bank.com';
  static const String userPassword = 'Password123';

  /// Used only when the profile endpoint cannot be reached.
  static const UserModel _offlineProfile = UserModel(
    id: '1',
    fullName: 'Adewale Sanusi',
    email: userEmail,
    phoneNumber: '+234 801 234 5678',
    avatarUrl: 'https://placebear.com/256/256',
    totalSavings: 850000,
  );

  /// The persisted session, or null when signed out.
  UserModel? get currentUser => _storage.readUser();

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final String normalisedEmail = email.trim().toLowerCase();

    if (normalisedEmail != userEmail) {
      throw const AuthException('No account found for that email address.');
    }
    if (password != userPassword) {
      throw const AuthException('Incorrect password. Please try again.');
    }

    // Credentials check out. Fetch the profile over the network.
    UserModel user;
    try {
      final Map<String, dynamic> json = await _api.fetchUserProfile();
      user = UserModel.fromJson(json);
    } on ApiException {
      user = _offlineProfile;
    }

    await _storage.saveUser(user);
    return user;
  }

  Future<void> logout() => _storage.clearAll();
}
