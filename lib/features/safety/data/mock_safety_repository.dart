import '../domain/report.dart';
import 'safety_repository.dart';

/// Mock safety repository for testing without Firebase
class MockSafetyRepository implements SafetyRepository {
  final Set<String> _blockedIds = {};

  @override
  Future<void> blockUser(String blockerId, String blockedId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _blockedIds.add(blockedId);
  }

  @override
  Future<void> unblockUser(String blockerId, String blockedId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _blockedIds.remove(blockedId);
  }

  @override
  Future<List<String>> getBlockedUserIds(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _blockedIds.toList();
  }

  @override
  Future<bool> isBlocked(String blockerId, String blockedId) async {
    return _blockedIds.contains(blockedId);
  }

  @override
  Future<void> reportUser({
    required String reporterId,
    required String reportedId,
    required ReportReason reason,
    String? details,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Just log in mock mode
  }

  @override
  Future<void> setProfileVisibility(String userId, bool isVisible) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> deleteAccount(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
