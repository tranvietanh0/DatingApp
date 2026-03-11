import '../domain/message.dart';

abstract class ChatRepository {
  Stream<List<Message>> watchMessages(String matchId);
  Future<void> sendMessage({
    required String matchId,
    required String senderId,
    required String text,
  });
  Future<void> markMessagesAsRead({
    required String matchId,
    required String userId,
  });
}
