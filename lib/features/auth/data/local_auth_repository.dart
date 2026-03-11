import 'package:shared_preferences/shared_preferences.dart';

import '../domain/auth_session.dart';
import 'auth_repository.dart';

class LocalAuthRepository implements AuthRepository {
  static const _userIdKey = 'auth.userId';
  static const _displayNameKey = 'auth.displayName';
  static const _providerKey = 'auth.provider';

  @override
  Future<AuthSession?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);
    final displayName = prefs.getString(_displayNameKey);
    final provider = prefs.getString(_providerKey);

    if (userId == null || displayName == null || provider == null) {
      return null;
    }

    return AuthSession(
      userId: userId,
      displayName: displayName,
      provider: provider,
    );
  }

  @override
  Future<AuthSession> signInWithGoogle() async {
    const session = AuthSession(
      userId: 'demo-google-user',
      displayName: 'Demo Google User',
      provider: 'google',
    );
    await _saveSession(session);
    return session;
  }

  @override
  Future<void> requestOtp(String phoneNumber) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<AuthSession> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final session = AuthSession(
      userId: 'demo-phone-user',
      displayName: 'Phone User',
      provider: 'phone',
    );
    await _saveSession(session);
    return session;
  }

  @override
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_displayNameKey);
    await prefs.remove(_providerKey);
  }

  Future<void> _saveSession(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, session.userId);
    await prefs.setString(_displayNameKey, session.displayName);
    await prefs.setString(_providerKey, session.provider);
  }
}
