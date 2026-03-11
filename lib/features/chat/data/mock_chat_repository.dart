import 'dart:async';

import '../domain/message.dart';
import 'chat_repository.dart';

/// Mock chat repository for testing without Firebase
class MockChatRepository implements ChatRepository {
  final Map<String, List<Message>> _messages = {
    'match1': [
      Message(
        id: 'msg1',
        senderId: 'linh123',
        text: 'Hey! Nice to match with you!',
        sentAt: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: true,
      ),
      Message(
        id: 'msg2',
        senderId: 'demo_user',
        text: 'Hi! Nice to meet you too!',
        sentAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
        isRead: true,
      ),
      Message(
        id: 'msg3',
        senderId: 'linh123',
        text: 'How are you doing today?',
        sentAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
    ],
  };

  final _controllers = <String, StreamController<List<Message>>>{};

  @override
  Stream<List<Message>> watchMessages(String matchId) {
    _controllers[matchId] ??= StreamController<List<Message>>.broadcast();

    // Emit initial messages
    Future.microtask(() {
      final messages = _messages[matchId] ?? [];
      _controllers[matchId]?.add(messages);
    });

    return _controllers[matchId]!.stream;
  }

  @override
  Future<void> sendMessage({
    required String matchId,
    required String senderId,
    required String text,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final message = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      text: text,
      sentAt: DateTime.now(),
      isRead: false,
    );

    _messages[matchId] ??= [];
    _messages[matchId]!.add(message);

    // Notify listeners
    _controllers[matchId]?.add(_messages[matchId]!);
  }

  @override
  Future<void> markMessagesAsRead({
    required String matchId,
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
  }
}
