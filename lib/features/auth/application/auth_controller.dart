import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/auth_repository.dart';
import '../domain/auth_session.dart';
import '../domain/auth_status.dart';

class AuthController extends ChangeNotifier {
  AuthController({required AuthRepository repository}) : _repository = repository;

  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.initial;
  AuthSession? _session;
  String? _pendingPhoneNumber;
  String? _errorMessage;
  DateTime? _lastOtpRequestTime;

  AuthStatus get status => _status;
  AuthSession? get session => _session;
  String? get pendingPhoneNumber => _pendingPhoneNumber;
  String? get errorMessage => _errorMessage;

  /// Seconds remaining before OTP can be resent.
  int get resendCooldownSeconds {
    if (_lastOtpRequestTime == null) return 0;
    final elapsed = DateTime.now().difference(_lastOtpRequestTime!).inSeconds;
    final remaining = 60 - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  bool get canResendOtp => resendCooldownSeconds == 0;

  Future<void> bootstrap() async {
    if (_status != AuthStatus.initial) {
      return;
    }

    final session = await _repository.restoreSession();
    if (session == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    _session = session;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    await _runAuthAction(() async {
      _session = await _repository.signInWithGoogle();
      _pendingPhoneNumber = null;
      _status = AuthStatus.authenticated;
    });
  }

  Future<void> requestOtp(String phoneNumber) async {
    await _runAuthAction(() async {
      await _repository.requestOtp(phoneNumber);
      _pendingPhoneNumber = phoneNumber;
      _lastOtpRequestTime = DateTime.now();
      _status = AuthStatus.unauthenticated;
    });
  }

  Future<void> resendOtp() async {
    final phoneNumber = _pendingPhoneNumber;
    if (phoneNumber == null || !canResendOtp) return;

    await _runAuthAction(() async {
      await _repository.requestOtp(phoneNumber);
      _lastOtpRequestTime = DateTime.now();
      _status = AuthStatus.unauthenticated;
    });
  }

  void cancelOtpFlow() {
    _pendingPhoneNumber = null;
    _lastOtpRequestTime = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> verifyOtp(String otpCode) async {
    final phoneNumber = _pendingPhoneNumber;
    if (phoneNumber == null) {
      _errorMessage = 'Missing phone number. Start the OTP flow again.';
      notifyListeners();
      return;
    }

    await _runAuthAction(() async {
      _session = await _repository.verifyOtp(
        phoneNumber: phoneNumber,
        otpCode: otpCode,
      );
      _pendingPhoneNumber = null;
      _lastOtpRequestTime = null;
      _status = AuthStatus.authenticated;
    });
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _session = null;
    _pendingPhoneNumber = null;
    _errorMessage = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _runAuthAction(Future<void> Function() action) async {
    _errorMessage = null;
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      await action();
    } catch (_) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Authentication failed. Please try again.';
    }

    notifyListeners();
  }
}
