import 'package:flutter/foundation.dart';

import '../../profile/domain/user_profile.dart';
import '../data/discovery_repository.dart';
import '../domain/discovery_filters.dart';
import '../domain/swipe_action.dart';

class DiscoveryController extends ChangeNotifier {
  DiscoveryController({required DiscoveryRepository repository})
      : _repository = repository;

  final DiscoveryRepository _repository;

  List<UserProfile> _candidates = [];
  DiscoveryFilters _filters = const DiscoveryFilters();
  bool _isLoading = false;
  String? _errorMessage;

  List<UserProfile> get candidates => _candidates;
  DiscoveryFilters get filters => _filters;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _candidates.isEmpty && !_isLoading;

  Future<void> loadCandidates({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _candidates = await _repository.fetchCandidates(
        userId: userId,
        latitude: latitude,
        longitude: longitude,
        filters: _filters,
      );
    } catch (e) {
      _errorMessage = 'Failed to load candidates';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> swipe({
    required String swiperId,
    required String targetId,
    required SwipeAction action,
  }) async {
    // Remove the candidate from the list immediately
    _candidates.removeWhere((c) => c.userId == targetId);
    notifyListeners();

    try {
      await _repository.recordSwipe(
        swiperId: swiperId,
        targetId: targetId,
        action: action,
      );

      // Check for mutual like
      if (action == SwipeAction.like || action == SwipeAction.superLike) {
        final isMutual = await _repository.checkMutualLike(
          userId1: swiperId,
          userId2: targetId,
        );
        return isMutual;
      }

      return false;
    } catch (e) {
      _errorMessage = 'Failed to record swipe';
      notifyListeners();
      return false;
    }
  }

  void updateFilters(DiscoveryFilters newFilters) {
    _filters = newFilters;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
