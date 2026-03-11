import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_providers.dart';
import '../../auth/domain/auth_status.dart';
import '../../chat/presentation/chat_page.dart';
import '../../safety/application/safety_providers.dart';
import '../application/notification_providers.dart';

/// Wrapper widget that initializes notifications based on auth state
class NotificationWrapper extends ConsumerStatefulWidget {
  const NotificationWrapper({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  ConsumerState<NotificationWrapper> createState() =>
      _NotificationWrapperState();
}

class _NotificationWrapperState extends ConsumerState<NotificationWrapper> {
  String? _currentUserId;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _setupNotificationHandler();
  }

  void _setupNotificationHandler() {
    final handler = ref.read(notificationHandlerProvider);
    handler.setOnNotificationTap(_handleNotificationTap);
    handler.setupListeners();
  }

  void _handleNotificationTap(String? matchId) {
    if (matchId != null && mounted) {
      // Navigate to chat page
      context.push(ChatPage.routePath.replaceFirst(':matchId', matchId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = ref.watch(authControllerProvider);

    // Handle auth state changes
    if (authController.status == AuthStatus.authenticated) {
      final userId = authController.session?.userId;
      if (userId != null && userId != _currentUserId) {
        _currentUserId = userId;
        _initializeNotifications(userId);
      }
    } else if (authController.status == AuthStatus.unauthenticated) {
      if (_currentUserId != null) {
        _cleanupNotifications(_currentUserId!);
        _currentUserId = null;
        _isInitialized = false;
      }
    }

    return widget.child;
  }

  Future<void> _initializeNotifications(String userId) async {
    if (_isInitialized) return;
    _isInitialized = true;

    final service = ref.read(notificationServiceProvider);
    await service.initialize(userId);

    // Load blocked users
    final safetyController = ref.read(safetyControllerProvider);
    await safetyController.loadBlockedUsers(userId);
  }

  Future<void> _cleanupNotifications(String userId) async {
    final service = ref.read(notificationServiceProvider);
    await service.removeToken(userId);
  }
}
