import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_providers.dart';
import '../../features/auth/domain/auth_status.dart';
import '../../features/premium/application/premium_providers.dart';
import '../../features/profile/application/profile_providers.dart';
import 'services_providers.dart';

/// Mixin to easily add analytics to any ConsumerWidget/ConsumerState
mixin AnalyticsMixin {
  AnalyticsHelper analytics(WidgetRef ref) => AnalyticsHelper(ref);
}

/// Helper class for common analytics operations
class AnalyticsHelper {
  AnalyticsHelper(this._ref);

  final WidgetRef _ref;

  /// Log a swipe action
  void logSwipe(String action) {
    _ref.read(analyticsServiceProvider).logSwipe(action);
  }

  /// Log match creation
  void logMatch() {
    _ref.read(analyticsServiceProvider).logMatch();
  }

  /// Log message sent
  void logMessageSent() {
    _ref.read(analyticsServiceProvider).logMessageSent();
  }

  /// Log paywall view
  void logPaywallViewed(String source) {
    _ref.read(analyticsServiceProvider).logPaywallViewed(source);
  }

  /// Log boost activation
  void logBoostActivated() {
    _ref.read(analyticsServiceProvider).logBoostActivated();
  }

  /// Log undo used
  void logUndoUsed() {
    _ref.read(analyticsServiceProvider).logUndoUsed();
  }

  /// Log user blocked
  void logUserBlocked() {
    _ref.read(analyticsServiceProvider).logUserBlocked();
  }

  /// Log user reported
  void logUserReported(String reason) {
    _ref.read(analyticsServiceProvider).logUserReported(reason);
  }

  /// Log screen view
  void logScreenView(String screenName) {
    _ref.read(analyticsServiceProvider).logScreenView(screenName);
  }
}

/// Provider that handles analytics state changes based on auth
final analyticsStateProvider = Provider<void>((ref) {
  final analytics = ref.watch(analyticsServiceProvider);
  final authController = ref.watch(authControllerProvider);

  // Update user ID when auth changes
  if (authController.status == AuthStatus.authenticated) {
    final userId = authController.session?.userId;
    if (userId != null) {
      analytics.setUserId(userId);

      // Set user properties
      final profile = ref.read(profileControllerProvider).profile;
      if (profile != null) {
        if (profile.gender != null) {
          analytics.setUserGender(profile.gender!.name);
        }
        if (profile.age != null) {
          analytics.setUserAge(profile.age!);
        }
      }

      final isPremium = ref.read(premiumControllerProvider).status.isPremium;
      analytics.setUserPremiumStatus(isPremium);
    }
  } else if (authController.status == AuthStatus.unauthenticated) {
    analytics.setUserId(null);
  }
});
