import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/match.dart';
import 'match_repository.dart';

class FirestoreMatchRepository implements MatchRepository {
  FirestoreMatchRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _matchesCollection =>
      _firestore.collection('matches');

  @override
  Stream<List<Match>> watchMatches(String userId) {
    return _matchesCollection
        .where('userIds', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Match.fromFirestore(doc)).toList());
  }

  @override
  Future<Match?> getMatch(String matchId) async {
    final doc = await _matchesCollection.doc(matchId).get();
    if (!doc.exists) return null;
    return Match.fromFirestore(doc);
  }

  @override
  Future<void> createMatch(String userId1, String userId2) async {
    final matchId = Match.createMatchId(userId1, userId2);

    // Check if match already exists
    final existing = await _matchesCollection.doc(matchId).get();
    if (existing.exists) return;

    await _matchesCollection.doc(matchId).set({
      'userIds': [userId1, userId2]..sort(),
      'matchedAt': FieldValue.serverTimestamp(),
      'lastMessageAt': FieldValue.serverTimestamp(),
      'unread': {userId1: false, userId2: false},
    });
  }

  @override
  Future<void> markAsRead(String matchId, String userId) async {
    await _matchesCollection.doc(matchId).update({
      'unread.$userId': false,
    });
  }
}
