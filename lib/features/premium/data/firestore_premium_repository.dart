import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/liker.dart';
import '../domain/premium_status.dart';
import 'premium_repository.dart';

class FirestorePremiumRepository implements PremiumRepository {
  FirestorePremiumRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<PremiumStatus> getPremiumStatus(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final premiumData = doc.data()?['premium'] as Map<String, dynamic>?;
    return PremiumStatus.fromFirestore(premiumData);
  }

  @override
  Stream<PremiumStatus> watchPremiumStatus(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      final premiumData = doc.data()?['premium'] as Map<String, dynamic>?;
      return PremiumStatus.fromFirestore(premiumData);
    });
  }

  @override
  Future<void> useUndo(String userId) async {
    final status = await getPremiumStatus(userId);

    if (!status.isPremium && status.undosRemaining > 0) {
      await _firestore.collection('users').doc(userId).update({
        'premium.undosRemaining': FieldValue.increment(-1),
      });
    }
  }

  @override
  Future<void> useBoost(String userId) async {
    final status = await getPremiumStatus(userId);

    // Set boost expiry to 30 minutes from now
    final boostExpiry = DateTime.now().add(const Duration(minutes: 30));

    await _firestore.collection('users').doc(userId).update({
      'boostExpiresAt': Timestamp.fromDate(boostExpiry),
      if (!status.isPremium && status.boostsRemaining > 0)
        'premium.boostsRemaining': FieldValue.increment(-1),
    });
  }

  @override
  Future<DateTime?> getBoostExpiry(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final timestamp = doc.data()?['boostExpiresAt'] as Timestamp?;

    if (timestamp == null) return null;

    final expiry = timestamp.toDate();
    return expiry.isAfter(DateTime.now()) ? expiry : null;
  }

  @override
  Future<List<Liker>> getWhoLikedYou(String userId, {required bool isPremium}) async {
    // Get swipes where current user is the target and action is like/superLike
    final snapshot = await _firestore
        .collection('swipes')
        .where('targetId', isEqualTo: userId)
        .where('action', whereIn: ['like', 'superLike'])
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();

    // Get already swiped user IDs to filter out
    final mySwipes = await _firestore
        .collection('swipes')
        .where('swiperId', isEqualTo: userId)
        .get();

    final swipedIds = mySwipes.docs
        .map((doc) => doc.data()['targetId'] as String)
        .toSet();

    // Filter out users we already swiped on
    final likers = snapshot.docs
        .where((doc) => !swipedIds.contains(doc.data()['swiperId']))
        .map((doc) => Liker.fromSwipeDoc(doc, isPremium: isPremium))
        .toList();

    // If premium, fetch profile info
    if (isPremium && likers.isNotEmpty) {
      final userIds = likers.map((l) => l.oderId).toList();
      final profiles = await Future.wait(
        userIds.map((id) => _firestore.collection('users').doc(id).get()),
      );

      return likers.asMap().entries.map((entry) {
        final liker = entry.value;
        final profileDoc = profiles[entry.key];
        final data = profileDoc.data();

        if (data == null) return liker;

        final birthDate = (data['birthDate'] as Timestamp?)?.toDate();
        int? age;
        if (birthDate != null) {
          age = DateTime.now().year - birthDate.year;
        }

        return liker.withProfile(
          name: data['name'] as String?,
          photoUrl: (data['photos'] as List<dynamic>?)?.firstOrNull as String?,
          age: age,
        );
      }).toList();
    }

    return likers;
  }

  @override
  Future<int> getLikesCount(String userId) async {
    // Get swipes where current user is the target
    final snapshot = await _firestore
        .collection('swipes')
        .where('targetId', isEqualTo: userId)
        .where('action', whereIn: ['like', 'superLike'])
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  @override
  Future<Map<String, dynamic>?> getLastSwipe(String userId) async {
    final snapshot = await _firestore
        .collection('swipes')
        .where('swiperId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    return {
      'id': doc.id,
      ...doc.data(),
    };
  }

  @override
  Future<void> deleteSwipe(String swipeId) async {
    await _firestore.collection('swipes').doc(swipeId).delete();
  }
}
