import '../domain/match.dart';

abstract class MatchRepository {
  Stream<List<Match>> watchMatches(String userId);
  Future<Match?> getMatch(String matchId);
  Future<void> createMatch(String userId1, String userId2);
  Future<void> markAsRead(String matchId, String userId);
}
