import '../domain/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession?> restoreSession();
  Future<AuthSession> signInWithGoogle();
  Future<void> requestOtp(String phoneNumber);
  Future<AuthSession> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  });
  Future<void> signOut();
}
