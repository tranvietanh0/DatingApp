import 'package:dating_app/app/app.dart';
import 'package:dating_app/core/utils/validators.dart';
import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/auth/data/auth_repository.dart';
import 'package:dating_app/features/auth/domain/auth_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.initialSession});

  final AuthSession? initialSession;

  @override
  Future<AuthSession?> restoreSession() async => initialSession;

  @override
  Future<AuthSession> signInWithGoogle() async {
    return initialSession ??
        const AuthSession(
          userId: 'test-user',
          displayName: 'Test User',
          provider: 'google',
        );
  }

  @override
  Future<void> requestOtp(String phoneNumber) async {}

  @override
  Future<AuthSession> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    return const AuthSession(
      userId: 'phone-user',
      displayName: 'Phone User',
      provider: 'phone',
    );
  }

  @override
  Future<void> signOut() async {}
}

void main() {
  group('Auth flow', () {
    testWidgets('shows sign-in flow for unauthenticated user', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          ],
          child: const DatingApp(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Meet with intention.'), findsOneWidget);
      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.text('Send OTP'), findsOneWidget);
    });

    testWidgets('restores authenticated user into app shell', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(
              FakeAuthRepository(
                initialSession: const AuthSession(
                  userId: 'restored-user',
                  displayName: 'Restored User',
                  provider: 'google',
                ),
              ),
            ),
          ],
          child: const DatingApp(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Spark real chemistry.'), findsOneWidget);
      expect(find.text('Signed in as Restored User via google.'), findsOneWidget);
      expect(find.text('Discover'), findsOneWidget);
    });
  });

  group('Validators', () {
    group('phoneNumber', () {
      test('returns error for empty input', () {
        expect(Validators.phoneNumber(''), isNotNull);
        expect(Validators.phoneNumber(null), isNotNull);
      });

      test('accepts valid Vietnamese phone numbers', () {
        expect(Validators.phoneNumber('0912345678'), isNull);
        expect(Validators.phoneNumber('+84912345678'), isNull);
        expect(Validators.phoneNumber('84912345678'), isNull);
        expect(Validators.phoneNumber('0382 123 456'), isNull);
      });

      test('rejects invalid phone numbers', () {
        expect(Validators.phoneNumber('123'), isNotNull);
        expect(Validators.phoneNumber('0112345678'), isNotNull);
      });
    });

    group('otpCode', () {
      test('returns error for empty input', () {
        expect(Validators.otpCode(''), isNotNull);
        expect(Validators.otpCode(null), isNotNull);
      });

      test('accepts valid 6-digit codes', () {
        expect(Validators.otpCode('123456'), isNull);
        expect(Validators.otpCode('000000'), isNull);
      });

      test('rejects invalid codes', () {
        expect(Validators.otpCode('12345'), isNotNull);
        expect(Validators.otpCode('1234567'), isNotNull);
        expect(Validators.otpCode('abcdef'), isNotNull);
      });
    });

    group('normalizePhoneNumber', () {
      test('normalizes various formats to E.164', () {
        expect(Validators.normalizePhoneNumber('0912345678'), '+84912345678');
        expect(Validators.normalizePhoneNumber('84912345678'), '+84912345678');
        expect(Validators.normalizePhoneNumber('+84912345678'), '+84912345678');
        expect(Validators.normalizePhoneNumber('0382 123 456'), '+84382123456');
      });
    });
  });
}
