import '../domain/liker.dart';
import '../domain/premium_status.dart';

abstract class PremiumRepository {
  /// Get premium status for a user
  Future<PremiumStatus> getPremiumStatus(String oderId);

  /// Stream premium status changes
  Stream<PremiumStatus> watchPremiumStatus(String oderId);

  /// Use an undo (decrements undosRemaining for free users)
  Future<void> useUndo(String oderId);

  /// Use a boost
  Future<void> useBoost(String oderId);

  /// Get boost expiry time (null if not boosted)
  Future<DateTime?> getBoostExpiry(String oderId);

  /// Get users who liked the current user
  Future<List<Liker>> getWhoLikedYou(String oderId, {required bool isPremium});

  /// Get count of users who liked you
  Future<int> getLikesCount(String oderId);

  /// Get last swipe for undo
  Future<Map<String, dynamic>?> getLastSwipe(String oderId);

  /// Delete a swipe (for undo)
  Future<void> deleteSwipe(String swipeId);
}
