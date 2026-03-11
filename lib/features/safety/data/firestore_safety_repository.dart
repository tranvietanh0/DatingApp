import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../domain/report.dart';
import 'safety_repository.dart';

class FirestoreSafetyRepository implements SafetyRepository {
  FirestoreSafetyRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  @override
  Future<void> blockUser(String blockerId, String blockedId) async {
    final blockId = '${blockerId}_$blockedId';
    await _firestore.collection('blocks').doc(blockId).set({
      'blockerId': blockerId,
      'blockedId': blockedId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> unblockUser(String blockerId, String blockedId) async {
    final blockId = '${blockerId}_$blockedId';
    await _firestore.collection('blocks').doc(blockId).delete();
  }

  @override
  Future<List<String>> getBlockedUserIds(String userId) async {
    final snapshot = await _firestore
        .collection('blocks')
        .where('blockerId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => doc.data()['blockedId'] as String)
        .toList();
  }

  @override
  Future<bool> isBlocked(String blockerId, String blockedId) async {
    final blockId = '${blockerId}_$blockedId';
    final doc = await _firestore.collection('blocks').doc(blockId).get();
    return doc.exists;
  }

  @override
  Future<void> reportUser({
    required String reporterId,
    required String reportedId,
    required ReportReason reason,
    String? details,
  }) async {
    await _firestore.collection('reports').add({
      'reporterId': reporterId,
      'reportedId': reportedId,
      'reason': reason.name,
      'details': details,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  @override
  Future<void> setProfileVisibility(String userId, bool isVisible) async {
    await _firestore.collection('users').doc(userId).update({
      'isVisible': isVisible,
    });
  }

  @override
  Future<void> deleteAccount(String userId) async {
    final batch = _firestore.batch();

    // Delete user profile
    batch.delete(_firestore.collection('users').doc(userId));

    // Delete user's swipes
    final swipesAsSwiper = await _firestore
        .collection('swipes')
        .where('swiperId', isEqualTo: userId)
        .get();
    for (final doc in swipesAsSwiper.docs) {
      batch.delete(doc.reference);
    }

    final swipesAsTarget = await _firestore
        .collection('swipes')
        .where('targetId', isEqualTo: userId)
        .get();
    for (final doc in swipesAsTarget.docs) {
      batch.delete(doc.reference);
    }

    // Delete user's blocks
    final blocksAsBlocker = await _firestore
        .collection('blocks')
        .where('blockerId', isEqualTo: userId)
        .get();
    for (final doc in blocksAsBlocker.docs) {
      batch.delete(doc.reference);
    }

    final blocksAsBlocked = await _firestore
        .collection('blocks')
        .where('blockedId', isEqualTo: userId)
        .get();
    for (final doc in blocksAsBlocked.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();

    // Delete matches and their messages (separate batches due to subcollections)
    final matches = await _firestore
        .collection('matches')
        .where('userIds', arrayContains: userId)
        .get();

    for (final matchDoc in matches.docs) {
      // Delete messages subcollection
      final messages = await matchDoc.reference.collection('messages').get();
      for (final msgDoc in messages.docs) {
        await msgDoc.reference.delete();
      }
      await matchDoc.reference.delete();
    }

    // Delete user's photos from storage
    try {
      final photosRef = _storage.ref().child('users/$userId/photos');
      final photosList = await photosRef.listAll();
      for (final item in photosList.items) {
        await item.delete();
      }
    } catch (_) {
      // Photos folder may not exist
    }

    // Delete Firebase Auth user
    await _auth.currentUser?.delete();
  }
}
