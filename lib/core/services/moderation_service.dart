import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// User moderation status
enum ModerationStatus {
  active,
  warned,
  suspended,
  banned,
}

/// Moderation action types
enum ModerationAction {
  warn,
  suspend,
  ban,
  unban,
}

/// Service for moderation and anti-spam functionality
class ModerationService {
  ModerationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // Rate limiting constants
  static const int maxSwipesPerHour = 100;
  static const int maxMessagesPerMinute = 10;
  static const int maxReportsBeforeReview = 3;

  /// Check if user can perform swipe action
  Future<bool> canSwipe(String userId) async {
    final hourAgo = DateTime.now().subtract(const Duration(hours: 1));

    final recentSwipes = await _firestore
        .collection('swipes')
        .where('swiperId', isEqualTo: userId)
        .where('timestamp', isGreaterThan: Timestamp.fromDate(hourAgo))
        .count()
        .get();

    final count = recentSwipes.count ?? 0;

    if (count >= maxSwipesPerHour) {
      await _logRateLimitHit(userId, 'swipe');
      return false;
    }

    return true;
  }

  /// Check if user can send message
  Future<bool> canSendMessage(String userId) async {
    final minuteAgo = DateTime.now().subtract(const Duration(minutes: 1));

    // Get recent messages sent by user across all matches
    final recentMessages = await _firestore
        .collectionGroup('messages')
        .where('senderId', isEqualTo: userId)
        .where('sentAt', isGreaterThan: Timestamp.fromDate(minuteAgo))
        .count()
        .get();

    final count = recentMessages.count ?? 0;

    if (count >= maxMessagesPerMinute) {
      await _logRateLimitHit(userId, 'message');
      return false;
    }

    return true;
  }

  /// Get user's moderation status
  Future<ModerationStatus> getModerationStatus(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      final status = doc.data()?['moderationStatus'] as String?;

      return ModerationStatus.values.firstWhere(
        (s) => s.name == status,
        orElse: () => ModerationStatus.active,
      );
    } catch (e) {
      return ModerationStatus.active;
    }
  }

  /// Check if user is allowed to use the app
  Future<bool> isUserAllowed(String userId) async {
    final status = await getModerationStatus(userId);
    return status == ModerationStatus.active || status == ModerationStatus.warned;
  }

  /// Check if user should be flagged for review
  Future<void> checkForAutoFlag(String userId) async {
    // Count reports against this user
    final reports = await _firestore
        .collection('reports')
        .where('reportedId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .count()
        .get();

    final reportCount = reports.count ?? 0;

    if (reportCount >= maxReportsBeforeReview) {
      await _flagForReview(userId, 'Multiple reports received');
    }
  }

  /// Flag a user for moderation review
  Future<void> _flagForReview(String userId, String reason) async {
    await _firestore.collection('moderation_queue').doc(userId).set({
      'userId': userId,
      'reason': reason,
      'flaggedAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    }, SetOptions(merge: true));
  }

  /// Log rate limit hit for monitoring
  Future<void> _logRateLimitHit(String userId, String action) async {
    try {
      await _firestore.collection('rate_limit_logs').add({
        'userId': userId,
        'action': action,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Failed to log rate limit: $e');
    }
  }

  /// Check message content for spam patterns
  bool isSpamMessage(String message) {
    final lowerMessage = message.toLowerCase();

    // Check for common spam patterns
    final spamPatterns = [
      RegExp(r'https?://\S+'), // URLs
      RegExp(r'@\S+\.\S+'), // Email-like patterns
      RegExp(r'\b(whatsapp|telegram|snapchat|instagram)\b', caseSensitive: false),
      RegExp(r'\b(venmo|cashapp|paypal|bitcoin|crypto)\b', caseSensitive: false),
      RegExp(r'(\d{3}[-.\s]?\d{3}[-.\s]?\d{4})'), // Phone numbers
    ];

    for (final pattern in spamPatterns) {
      if (pattern.hasMatch(lowerMessage)) {
        return true;
      }
    }

    // Check for repeated characters (spammy behavior)
    if (RegExp(r'(.)\1{5,}').hasMatch(message)) {
      return true;
    }

    return false;
  }

  /// Get suspension end time for suspended users
  Future<DateTime?> getSuspensionEndTime(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      final timestamp = doc.data()?['suspensionEndsAt'] as Timestamp?;
      return timestamp?.toDate();
    } catch (e) {
      return null;
    }
  }
}
