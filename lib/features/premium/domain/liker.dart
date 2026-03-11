import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user who liked the current user
class Liker {
  const Liker({
    required this.oderId,
    required this.visibleId,
    required this.likedAt,
    this.name,
    this.photoUrl,
    this.age,
  });

  final String oderId; // Original user ID
  final String visibleId; // Will be oderId if premium, 'hidden' otherwise
  final DateTime likedAt;
  final String? name;
  final String? photoUrl;
  final int? age;

  factory Liker.fromSwipeDoc(DocumentSnapshot doc, {required bool isPremium}) {
    final data = doc.data() as Map<String, dynamic>;
    final oderId = data['swiperId'] as String;
    final timestamp = data['timestamp'] as Timestamp?;

    return Liker(
      oderId: oderId,
      visibleId: isPremium ? oderId : 'hidden',
      likedAt: timestamp?.toDate() ?? DateTime.now(),
    );
  }

  Liker withProfile({
    String? name,
    String? photoUrl,
    int? age,
  }) {
    return Liker(
      oderId: oderId,
      visibleId: visibleId,
      likedAt: likedAt,
      name: name,
      photoUrl: photoUrl,
      age: age,
    );
  }
}
