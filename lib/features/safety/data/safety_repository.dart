import '../domain/report.dart';

abstract class SafetyRepository {
  /// Block a user
  Future<void> blockUser(String blockerId, String blockedId);

  /// Unblock a user
  Future<void> unblockUser(String blockerId, String blockedId);

  /// Get list of blocked user IDs
  Future<List<String>> getBlockedUserIds(String userId);

  /// Check if a user is blocked
  Future<bool> isBlocked(String blockerId, String blockedId);

  /// Report a user
  Future<void> reportUser({
    required String reporterId,
    required String reportedId,
    required ReportReason reason,
    String? details,
  });

  /// Hide/show profile visibility
  Future<void> setProfileVisibility(String userId, bool isVisible);

  /// Delete user account and all associated data
  Future<void> deleteAccount(String userId);
}
