import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Centralized crash reporting service
class CrashReportingService {
  CrashReportingService({FirebaseCrashlytics? crashlytics})
      : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  final FirebaseCrashlytics _crashlytics;

  /// Initialize crash reporting
  Future<void> initialize() async {
    // Pass all uncaught "fatal" errors to Crashlytics
    FlutterError.onError = (errorDetails) {
      _crashlytics.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };

    // Disable in debug mode
    await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
  }

  /// Set user identifier for crash reports
  Future<void> setUserId(String userId) async {
    await _crashlytics.setUserIdentifier(userId);
  }

  /// Clear user identifier on logout
  Future<void> clearUserId() async {
    await _crashlytics.setUserIdentifier('');
  }

  /// Set custom key-value pairs for crash context
  Future<void> setCustomKey(String key, Object value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  /// Log a message for debugging
  Future<void> log(String message) async {
    await _crashlytics.log(message);
  }

  /// Record a non-fatal error
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    await _crashlytics.recordError(
      exception,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  /// Record a Flutter error
  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    await _crashlytics.recordFlutterError(details);
  }

  /// Force a crash for testing (only in debug)
  void testCrash() {
    if (kDebugMode) {
      _crashlytics.crash();
    }
  }
}
