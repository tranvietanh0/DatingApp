import '../domain/match.dart';
import 'bumble_rules_repository.dart';
import 'match_repository.dart';

/// Mock match repository for testing without Firebase
class MockMatchRepository implements MatchRepository {
  final List<Match> _mockMatches = [
    Match(
      id: 'match1',
      userIds: ['demo_user', 'linh123'],
      matchedAt: DateTime.now().subtract(const Duration(hours: 5)),
      lastMessage: 'Hey! Nice to meet you',
      lastMessageAt: DateTime.now().subtract(const Duration(hours: 2)),
      unread: {'demo_user': true},
    ),
    Match(
      id: 'match2',
      userIds: ['demo_user', 'mai456'],
      matchedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Stream<List<Match>> watchMatches(String userId) {
    return Stream.value(_mockMatches);
  }

  @override
  Future<Match?> getMatch(String matchId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockMatches.where((m) => m.id == matchId).firstOrNull;
  }

  @override
  Future<void> createMatch(String userId1, String userId2) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final matchId = Match.createMatchId(userId1, userId2);
    _mockMatches.add(Match(
      id: matchId,
      userIds: [userId1, userId2],
      matchedAt: DateTime.now(),
    ));
  }

  @override
  Future<void> markAsRead(String matchId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

/// Mock Bumble rules repository for testing
class MockBumbleRulesRepository implements BumbleRulesRepository {
  @override
  Future<void> extendMatch(String matchId) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<bool> isBumbleModeEnabled() async {
    return false; // Bumble mode disabled in mock
  }

  @override
  Future<void> setBumbleModePreference(String userId, bool enabled) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<bool> getUserBumbleModePreference(String userId) async {
    return false;
  }
}

