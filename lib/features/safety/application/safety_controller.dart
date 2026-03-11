import 'package:flutter/foundation.dart';

import '../data/safety_repository.dart';
import '../domain/report.dart';

class SafetyController extends ChangeNotifier {
  SafetyController({required SafetyRepository repository})
      : _repository = repository;

  final SafetyRepository _repository;

  Set<String> _blockedUserIds = {};
  bool _isLoading = false;
  String? _errorMessage;

  Set<String> get blockedUserIds => _blockedUserIds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load blocked users for the current user
  Future<void> loadBlockedUsers(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ids = await _repository.getBlockedUserIds(userId);
      _blockedUserIds = ids.toSet();
    } catch (e) {
      _errorMessage = 'Failed to load blocked users';
      debugPrint('Error loading blocked users: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Check if a user is blocked
  bool isUserBlocked(String userId) {
    return _blockedUserIds.contains(userId);
  }

  /// Block a user
  Future<bool> blockUser(String blockerId, String blockedId) async {
    try {
      await _repository.blockUser(blockerId, blockedId);
      _blockedUserIds.add(blockedId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to block user';
      debugPrint('Error blocking user: $e');
      notifyListeners();
      return false;
    }
  }

  /// Unblock a user
  Future<bool> unblockUser(String blockerId, String blockedId) async {
    try {
      await _repository.unblockUser(blockerId, blockedId);
      _blockedUserIds.remove(blockedId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to unblock user';
      debugPrint('Error unblocking user: $e');
      notifyListeners();
      return false;
    }
  }

  /// Report a user
  Future<bool> reportUser({
    required String reporterId,
    required String reportedId,
    required ReportReason reason,
    String? details,
  }) async {
    try {
      await _repository.reportUser(
        reporterId: reporterId,
        reportedId: reportedId,
        reason: reason,
        details: details,
      );
      return true;
    } catch (e) {
      _errorMessage = 'Failed to submit report';
      debugPrint('Error reporting user: $e');
      notifyListeners();
      return false;
    }
  }

  /// Set profile visibility
  Future<bool> setProfileVisibility(String userId, bool isVisible) async {
    try {
      await _repository.setProfileVisibility(userId, isVisible);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update visibility';
      debugPrint('Error setting visibility: $e');
      notifyListeners();
      return false;
    }
  }

  /// Delete account
  Future<bool> deleteAccount(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteAccount(userId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete account';
      debugPrint('Error deleting account: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
