import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BumbleRulesRepository {
  /// Extend a match by 24 hours
  Future<void> extendMatch(String matchId);

  /// Check if Bumble mode is enabled globally
  Future<bool> isBumbleModeEnabled();

  /// Enable/disable Bumble mode for a user
  Future<void> setBumbleModePreference(String userId, bool enabled);

  /// Get user's Bumble mode preference
  Future<bool> getUserBumbleModePreference(String userId);
}

class FirestoreBumbleRulesRepository implements BumbleRulesRepository {
  FirestoreBumbleRulesRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const _expiryDuration = Duration(hours: 24);

  @override
  Future<void> extendMatch(String matchId) async {
    final matchRef = _firestore.collection('matches').doc(matchId);
    final matchDoc = await matchRef.get();

    if (!matchDoc.exists) return;

    final data = matchDoc.data()!;
    final currentExpiry = (data['expiresAt'] as Timestamp?)?.toDate();

    if (currentExpiry == null) return;

    // Extend by 24 hours from current expiry or from now if already expired
    final baseTime = currentExpiry.isAfter(DateTime.now())
        ? currentExpiry
        : DateTime.now();
    final newExpiry = baseTime.add(_expiryDuration);

    await matchRef.update({
      'expiresAt': Timestamp.fromDate(newExpiry),
      'isExtended': true,
    });
  }

  @override
  Future<bool> isBumbleModeEnabled() async {
    // Could be a global setting in a config collection
    // For now, return true to enable Bumble mode
    try {
      final configDoc = await _firestore.collection('config').doc('app').get();
      return configDoc.data()?['bumbleModeEnabled'] as bool? ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> setBumbleModePreference(String userId, bool enabled) async {
    await _firestore.collection('users').doc(userId).update({
      'bumbleModePreference': enabled,
    });
  }

  @override
  Future<bool> getUserBumbleModePreference(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc.data()?['bumbleModePreference'] as bool? ?? false;
    } catch (_) {
      return false;
    }
  }
}
