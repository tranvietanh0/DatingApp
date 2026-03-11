import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../domain/user_profile.dart';
import 'profile_repository.dart';

class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  @override
  Future<UserProfile?> getProfile(String userId) async {
    final doc = await _usersCollection.doc(userId).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await _usersCollection.doc(profile.userId).set(
          profile.toFirestore(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<String> uploadPhoto(String userId, String localPath) async {
    final file = File(localPath);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('users/$userId/photos/$fileName');

    final uploadTask = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await uploadTask.ref.getDownloadURL();
  }

  @override
  Future<void> deletePhoto(String userId, String photoUrl) async {
    try {
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();
    } catch (_) {
      // Photo may not exist in storage
    }
  }

  Future<void> updateLastActive(String userId) async {
    await _usersCollection.doc(userId).update({
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateLocation({
    required String userId,
    required double latitude,
    required double longitude,
    required String geohash,
  }) async {
    await _usersCollection.doc(userId).update({
      'location': GeoPoint(latitude, longitude),
      'geohash': geohash,
    });
  }
}
