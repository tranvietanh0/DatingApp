import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/message.dart';
import 'chat_repository.dart';

class FirestoreChatRepository implements ChatRepository {
  FirestoreChatRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _messagesCollection(
          String matchId) =>
      _firestore.collection('matches').doc(matchId).collection('messages');

  DocumentReference<Map<String, dynamic>> _matchDoc(String matchId) =>
      _firestore.collection('matches').doc(matchId);

  @override
  Stream<List<Message>> watchMessages(String matchId) {
    return _messagesCollection(matchId)
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList());
  }

  @override
  Future<void> sendMessage({
    required String matchId,
    required String senderId,
    required String text,
  }) async {
    final batch = _firestore.batch();

    // Add message
    final messageRef = _messagesCollection(matchId).doc();
    batch.set(messageRef, {
      'senderId': senderId,
      'text': text,
      'sentAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    // Update match with last message
    batch.update(_matchDoc(matchId), {
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  @override
  Future<void> markMessagesAsRead({
    required String matchId,
    required String userId,
  }) async {
    // Get unread messages not sent by the current user
    final unreadMessages = await _messagesCollection(matchId)
        .where('isRead', isEqualTo: false)
        .where('senderId', isNotEqualTo: userId)
        .get();

    if (unreadMessages.docs.isEmpty) return;

    final batch = _firestore.batch();

    for (final doc in unreadMessages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    // Also update the match unread status
    batch.update(_matchDoc(matchId), {
      'unread.$userId': false,
    });

    await batch.commit();
  }
}
