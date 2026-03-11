import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'analytics_service.dart';
import 'crash_reporting_service.dart';
import 'moderation_service.dart';
import 'performance_service.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

final crashReportingServiceProvider = Provider<CrashReportingService>((ref) {
  return CrashReportingService();
});

final performanceServiceProvider = Provider<PerformanceService>((ref) {
  return PerformanceService();
});

final moderationServiceProvider = Provider<ModerationService>((ref) {
  return ModerationService();
});
