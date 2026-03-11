import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Centralized analytics service for tracking user events
class AnalyticsService {
  AnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ============ Auth Events ============

  Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logLogout() async {
    await _log('logout');
  }

  // ============ Profile Events ============

  Future<void> logProfileComplete() async {
    await _log('profile_complete');
  }

  Future<void> logPhotoUploaded(int totalPhotos) async {
    await _log('photo_uploaded', {'total_photos': totalPhotos});
  }

  Future<void> logProfileUpdated(String field) async {
    await _log('profile_updated', {'field': field});
  }

  // ============ Discovery Events ============

  Future<void> logSwipe(String action) async {
    await _log('swipe', {'action': action});
  }

  Future<void> logFilterChanged(String filter, dynamic value) async {
    await _log('filter_changed', {'filter': filter, 'value': value.toString()});
  }

  Future<void> logDiscoveryRefresh() async {
    await _log('discovery_refresh');
  }

  // ============ Match Events ============

  Future<void> logMatch() async {
    await _log('match_created');
  }

  Future<void> logMatchExtended() async {
    await _log('match_extended');
  }

  Future<void> logMatchExpired() async {
    await _log('match_expired');
  }

  // ============ Chat Events ============

  Future<void> logMessageSent() async {
    await _log('message_sent');
  }

  Future<void> logChatOpened() async {
    await _log('chat_opened');
  }

  // ============ Premium Events ============

  Future<void> logPaywallViewed(String source) async {
    await _log('paywall_viewed', {'source': source});
  }

  Future<void> logSubscriptionStarted(String tier) async {
    await _log('subscription_started', {'tier': tier});
  }

  Future<void> logBoostActivated() async {
    await _log('boost_activated');
  }

  Future<void> logUndoUsed() async {
    await _log('undo_used');
  }

  Future<void> logWhoLikedYouViewed() async {
    await _log('who_liked_you_viewed');
  }

  // ============ Safety Events ============

  Future<void> logUserBlocked() async {
    await _log('user_blocked');
  }

  Future<void> logUserReported(String reason) async {
    await _log('user_reported', {'reason': reason});
  }

  Future<void> logAccountDeleted() async {
    await _log('account_deleted');
  }

  // ============ Engagement Events ============

  Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  Future<void> logNotificationOpened(String type) async {
    await _log('notification_opened', {'type': type});
  }

  // ============ User Properties ============

  Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
  }

  Future<void> setUserProperty(String name, String? value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  Future<void> setUserGender(String gender) async {
    await setUserProperty('gender', gender);
  }

  Future<void> setUserAge(int age) async {
    await setUserProperty('age_group', _getAgeGroup(age));
  }

  Future<void> setUserPremiumStatus(bool isPremium) async {
    await setUserProperty('is_premium', isPremium.toString());
  }

  String _getAgeGroup(int age) {
    if (age < 25) return '18-24';
    if (age < 30) return '25-29';
    if (age < 35) return '30-34';
    if (age < 40) return '35-39';
    if (age < 50) return '40-49';
    return '50+';
  }

  // ============ Helper ============

  Future<void> _log(String name, [Map<String, Object>? parameters]) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }
}
