import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  const Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
    this.isRead = false,
  });

  final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;
  final bool isRead;

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'text': text,
      'sentAt': FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final sentAtTimestamp = data['sentAt'] as Timestamp?;

    return Message(
      id: doc.id,
      senderId: data['senderId'] as String,
      text: data['text'] as String,
      sentAt: sentAtTimestamp?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
    );
  }
}
