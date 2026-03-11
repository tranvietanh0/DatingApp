import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

/// Centralized performance monitoring service
class PerformanceService {
  PerformanceService({FirebasePerformance? performance})
      : _performance = performance ?? FirebasePerformance.instance;

  final FirebasePerformance _performance;
  final Map<String, Trace> _activeTraces = {};

  /// Initialize performance monitoring
  Future<void> initialize() async {
    // Disable in debug mode for cleaner logs
    await _performance.setPerformanceCollectionEnabled(!kDebugMode);
  }

  /// Start a custom trace
  Future<void> startTrace(String name) async {
    if (_activeTraces.containsKey(name)) return;

    try {
      final trace = _performance.newTrace(name);
      await trace.start();
      _activeTraces[name] = trace;
    } catch (e) {
      debugPrint('Performance trace error: $e');
    }
  }

  /// Stop a custom trace
  Future<void> stopTrace(String name) async {
    final trace = _activeTraces.remove(name);
    if (trace != null) {
      await trace.stop();
    }
  }

  /// Add metric to active trace
  void incrementMetric(String traceName, String metricName, int value) {
    final trace = _activeTraces[traceName];
    trace?.incrementMetric(metricName, value);
  }

  /// Set attribute on active trace
  void setTraceAttribute(String traceName, String key, String value) {
    final trace = _activeTraces[traceName];
    trace?.putAttribute(key, value);
  }

  /// Measure async operation
  Future<T> measureAsync<T>(String name, Future<T> Function() operation) async {
    await startTrace(name);
    try {
      return await operation();
    } finally {
      await stopTrace(name);
    }
  }

  // ============ Predefined Traces ============

  Future<void> startAppStartTrace() => startTrace('app_start');
  Future<void> stopAppStartTrace() => stopTrace('app_start');

  Future<void> startAuthTrace() => startTrace('auth_flow');
  Future<void> stopAuthTrace() => stopTrace('auth_flow');

  Future<void> startDiscoveryLoadTrace() => startTrace('discovery_load');
  Future<void> stopDiscoveryLoadTrace() => stopTrace('discovery_load');

  Future<void> startChatLoadTrace() => startTrace('chat_load');
  Future<void> stopChatLoadTrace() => stopTrace('chat_load');

  Future<void> startImageUploadTrace() => startTrace('image_upload');
  Future<void> stopImageUploadTrace() => stopTrace('image_upload');
}
