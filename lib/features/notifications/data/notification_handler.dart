import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Callback for handling notification taps
typedef NotificationTapCallback = void Function(String? matchId);

/// Handles incoming notifications and taps
class NotificationHandler {
  NotificationHandler({
    FirebaseMessaging? messaging,
  }) : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;
  NotificationTapCallback? _onNotificationTap;

  /// Set callback for notification taps
  void setOnNotificationTap(NotificationTapCallback callback) {
    _onNotificationTap = callback;
  }

  /// Setup notification listeners
  Future<void> setupListeners() async {
    // Handle notification tap when app was terminated
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  void _handleMessage(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.data}');

    final matchId = message.data['matchId'] as String?;
    _onNotificationTap?.call(matchId);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground notification: ${message.notification?.title}');
    // Foreground notifications are shown automatically via
    // setForegroundNotificationPresentationOptions
  }
}
