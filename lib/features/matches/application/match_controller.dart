import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/bumble_rules_repository.dart';
import '../data/match_repository.dart';
import '../domain/match.dart';

class MatchController extends ChangeNotifier {
  MatchController({
    required MatchRepository repository,
    required BumbleRulesRepository bumbleRulesRepository,
  })  : _repository = repository,
        _bumbleRulesRepository = bumbleRulesRepository;

  final MatchRepository _repository;
  final BumbleRulesRepository _bumbleRulesRepository;

  List<Match> _matches = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<Match>>? _subscription;

  List<Match> get matches => _matches;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _matches.isEmpty && !_isLoading;

  int get unreadCount {
    return _matches.where((m) => m.unread.values.any((v) => v)).length;
  }

  void watchMatches(String userId) {
    _subscription?.cancel();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _subscription = _repository.watchMatches(userId).listen(
      (matches) {
        _matches = matches;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load matches';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> markAsRead(String matchId, String userId) async {
    await _repository.markAsRead(matchId, userId);
  }

  /// Extend a match by 24 hours (Bumble mode)
  Future<bool> extendMatch(String matchId) async {
    try {
      await _bumbleRulesRepository.extendMatch(matchId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to extend match';
      notifyListeners();
      return false;
    }
  }

  /// Get a specific match by ID
  Match? getMatch(String matchId) {
    return _matches.where((m) => m.id == matchId).firstOrNull;
  }

  /// Get active (non-expired) matches
  List<Match> get activeMatches {
    return _matches.where((m) => !m.isExpired).toList();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
