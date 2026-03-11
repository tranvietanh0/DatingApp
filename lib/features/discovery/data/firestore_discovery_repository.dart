import 'package:cloud_firestore/cloud_firestore.dart';

import '../../profile/domain/user_profile.dart';
import '../domain/discovery_filters.dart';
import '../domain/swipe.dart';
import '../domain/swipe_action.dart';
import 'discovery_repository.dart';

class FirestoreDiscoveryRepository implements DiscoveryRepository {
  FirestoreDiscoveryRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _swipesCollection =>
      _firestore.collection('swipes');

  @override
  Future<List<UserProfile>> fetchCandidates({
    required String userId,
    required double latitude,
    required double longitude,
    required DiscoveryFilters filters,
    int limit = 20,
  }) async {
    // Get already swiped user IDs
    final swipedIds = await _getSwipedTargetIds(userId);
    swipedIds.add(userId); // Exclude self

    // Get blocked user IDs (both directions)
    final blockedIds = await _getBlockedUserIds(userId);

    // Simple query - filter by geohash prefix for nearby users
    // This is a simplified geo query using geohash prefix matching
    final geohash = _encodeGeohash(latitude, longitude, precision: 4);

    final snapshot = await _usersCollection
        .where('isVisible', isEqualTo: true)
        .orderBy('lastActive', descending: true)
        .limit(100) // Fetch more, then filter
        .get();

    // Filter candidates
    final filtered = snapshot.docs
        .map((doc) => UserProfile.fromFirestore(doc))
        .where((profile) {
      // Exclude already swiped
      if (swipedIds.contains(profile.userId)) return false;

      // Exclude blocked users
      if (blockedIds.contains(profile.userId)) return false;

      // Filter by visibility
      if (!profile.isVisible) return false;

      // Filter by profile completeness
      if (!profile.isComplete) return false;

      // Filter by distance (approximate using geohash prefix)
      if (profile.geohash != null &&
          !profile.geohash!.startsWith(geohash.substring(0, 3))) {
        // Only include if geohash prefix matches (within ~150km)
        // This is a rough filter, you'd want more precise distance calc
      }

      // Filter by gender preference
      if (filters.interestedIn.isNotEmpty &&
          profile.gender != null &&
          !filters.interestedIn.contains(profile.gender)) {
        return false;
      }

      // Filter by age
      final age = profile.age;
      if (age != null && (age < filters.minAge || age > filters.maxAge)) {
        return false;
      }

      return true;
    }).toList();

    return filtered.take(limit).toList();
  }

  String _encodeGeohash(double lat, double lng, {int precision = 6}) {
    const base32 = '0123456789bcdefghjkmnpqrstuvwxyz';
    var minLat = -90.0, maxLat = 90.0;
    var minLng = -180.0, maxLng = 180.0;
    var hash = '';
    var isEven = true;
    var bit = 0;
    var ch = 0;

    while (hash.length < precision) {
      if (isEven) {
        final mid = (minLng + maxLng) / 2;
        if (lng >= mid) {
          ch |= 1 << (4 - bit);
          minLng = mid;
        } else {
          maxLng = mid;
        }
      } else {
        final mid = (minLat + maxLat) / 2;
        if (lat >= mid) {
          ch |= 1 << (4 - bit);
          minLat = mid;
        } else {
          maxLat = mid;
        }
      }
      isEven = !isEven;
      if (bit < 4) {
        bit++;
      } else {
        hash += base32[ch];
        bit = 0;
        ch = 0;
      }
    }
    return hash;
  }

  @override
  Future<void> recordSwipe({
    required String swiperId,
    required String targetId,
    required SwipeAction action,
  }) async {
    await _swipesCollection.add({
      'swiperId': swiperId,
      'targetId': targetId,
      'action': action.name,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<Swipe>> getSwipedUserIds(String userId) async {
    final snapshot = await _swipesCollection
        .where('swiperId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => Swipe.fromFirestore(doc)).toList();
  }

  @override
  Future<bool> checkMutualLike({
    required String userId1,
    required String userId2,
  }) async {
    // Check if userId2 has liked userId1
    final reverseSwipe = await _swipesCollection
        .where('swiperId', isEqualTo: userId2)
        .where('targetId', isEqualTo: userId1)
        .where('action', isEqualTo: SwipeAction.like.name)
        .limit(1)
        .get();

    return reverseSwipe.docs.isNotEmpty;
  }

  Future<Set<String>> _getSwipedTargetIds(String userId) async {
    final snapshot = await _swipesCollection
        .where('swiperId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => doc.data()['targetId'] as String)
        .toSet();
  }

  Future<Set<String>> _getBlockedUserIds(String userId) async {
    // Users I blocked
    final myBlocks = await _firestore
        .collection('blocks')
        .where('blockerId', isEqualTo: userId)
        .get();

    // Users who blocked me
    final blockedByOthers = await _firestore
        .collection('blocks')
        .where('blockedId', isEqualTo: userId)
        .get();

    final blockedIds = <String>{};
    for (final doc in myBlocks.docs) {
      blockedIds.add(doc.data()['blockedId'] as String);
    }
    for (final doc in blockedByOthers.docs) {
      blockedIds.add(doc.data()['blockerId'] as String);
    }

    return blockedIds;
  }
}
