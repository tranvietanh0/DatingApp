import 'package:cloud_firestore/cloud_firestore.dart';

class Block {
  const Block({
    required this.id,
    required this.blockerId,
    required this.blockedId,
    required this.createdAt,
  });

  final String id;
  final String blockerId;
  final String blockedId;
  final DateTime createdAt;

  Map<String, dynamic> toFirestore() {
    return {
      'blockerId': blockerId,
      'blockedId': blockedId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory Block.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final createdAt = data['createdAt'] as Timestamp?;

    return Block(
      id: doc.id,
      blockerId: data['blockerId'] as String,
      blockedId: data['blockedId'] as String,
      createdAt: createdAt?.toDate() ?? DateTime.now(),
    );
  }
}
