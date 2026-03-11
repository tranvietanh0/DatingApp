import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/premium_repository.dart';
import '../domain/liker.dart';
import '../domain/premium_status.dart';

class PremiumController extends ChangeNotifier {
  PremiumController({required PremiumRepository repository})
      : _repository = repository;

  final PremiumRepository _repository;

  PremiumStatus _status = const PremiumStatus();
  List<Liker> _likers = [];
  int _likesCount = 0;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<PremiumStatus>? _subscription;
  DateTime? _boostExpiry;

  PremiumStatus get status => _status;
  List<Liker> get likers => _likers;
  int get likesCount => _likesCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get boostExpiry => _boostExpiry;
  bool get isBoosted => _boostExpiry != null && _boostExpiry!.isAfter(DateTime.now());

  void watchStatus(String userId) {
    _subscription?.cancel();
    _subscription = _repository.watchPremiumStatus(userId).listen(
      (status) {
        _status = status;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error watching premium status: $error');
      },
    );

    // Also load boost status and likes count
    _loadBoostStatus(userId);
    _loadLikesCount(userId);
  }

  Future<void> _loadBoostStatus(String userId) async {
    _boostExpiry = await _repository.getBoostExpiry(userId);
    notifyListeners();
  }

  Future<void> _loadLikesCount(String userId) async {
    _likesCount = await _repository.getLikesCount(userId);
    notifyListeners();
  }

  /// Load who liked you list
  Future<void> loadWhoLikedYou(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _likers = await _repository.getWhoLikedYou(
        userId,
        isPremium: _status.isPremium,
      );
    } catch (e) {
      _errorMessage = 'Failed to load likes';
      debugPrint('Error loading who liked you: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Undo last swipe
  Future<String?> undoLastSwipe(String userId) async {
    if (!_status.canUndo) {
      return null;
    }

    try {
      final lastSwipe = await _repository.getLastSwipe(userId);
      if (lastSwipe == null) {
        _errorMessage = 'No swipe to undo';
        notifyListeners();
        return null;
      }

      await _repository.deleteSwipe(lastSwipe['id'] as String);
      await _repository.useUndo(userId);

      return lastSwipe['targetId'] as String?;
    } catch (e) {
      _errorMessage = 'Failed to undo swipe';
      debugPrint('Error undoing swipe: $e');
      notifyListeners();
      return null;
    }
  }

  /// Activate boost
  Future<bool> activateBoost(String userId) async {
    if (!_status.canBoost && !_status.isPremium) {
      return false;
    }

    try {
      await _repository.useBoost(userId);
      await _loadBoostStatus(userId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to activate boost';
      debugPrint('Error activating boost: $e');
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
