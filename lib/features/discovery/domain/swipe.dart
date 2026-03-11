import 'package:cloud_firestore/cloud_firestore.dart';

import 'swipe_action.dart';

class Swipe {
  const Swipe({
    required this.id,
    required this.swiperId,
    required this.targetId,
    required this.action,
    required this.timestamp,
  });

  final String id;
  final String swiperId;
  final String targetId;
  final SwipeAction action;
  final DateTime timestamp;

  Map<String, dynamic> toFirestore() {
    return {
      'swiperId': swiperId,
      'targetId': targetId,
      'action': action.name,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  factory Swipe.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = data['timestamp'] as Timestamp?;

    return Swipe(
      id: doc.id,
      swiperId: data['swiperId'] as String,
      targetId: data['targetId'] as String,
      action: SwipeAction.values.firstWhere(
        (a) => a.name == data['action'],
        orElse: () => SwipeAction.pass,
      ),
      timestamp: timestamp?.toDate() ?? DateTime.now(),
    );
  }
}
