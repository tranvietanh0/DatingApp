import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/services/crash_reporting_service.dart';
import 'core/services/performance_service.dart';
import 'firebase_options.dart';

// Set to true to run without Firebase (for testing UI)
const bool useMockMode = false;

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Background messages are handled by the system notification tray
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!useMockMode) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize crash reporting
    final crashReporting = CrashReportingService();
    await crashReporting.initialize();

    // Initialize performance monitoring
    final performance = PerformanceService();
    await performance.initialize();
    await performance.startAppStartTrace();

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } else {
    debugPrint('Running in MOCK MODE - Firebase disabled');
  }

  runApp(const ProviderScope(child: DatingApp()));

  if (!useMockMode) {
    // Stop app start trace after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PerformanceService().stopAppStartTrace();
    });
  }
}
