import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/chat_repository.dart';
import '../domain/message.dart';

class ChatController extends ChangeNotifier {
  ChatController({required ChatRepository repository})
      : _repository = repository;

  final ChatRepository _repository;

  List<Message> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;
  StreamSubscription<List<Message>>? _subscription;
  String? _currentMatchId;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  bool _isDisposed = false;

  void _safeNotify() {
    if (!_isDisposed) notifyListeners();
  }

  void watchMessages(String matchId, String currentUserId) {
    if (_currentMatchId == matchId || _isDisposed) return;

    _subscription?.cancel();
    _currentMatchId = matchId;
    _isLoading = true;
    _errorMessage = null;
    _safeNotify();

    _subscription = _repository.watchMessages(matchId).listen(
      (messages) {
        if (_isDisposed) return;
        _messages = messages;
        _isLoading = false;
        _safeNotify();

        // Mark messages as read
        _repository.markMessagesAsRead(
          matchId: matchId,
          userId: currentUserId,
        );
      },
      onError: (error) {
        if (_isDisposed) return;
        _errorMessage = 'Failed to load messages';
        _isLoading = false;
        _safeNotify();
      },
    );
  }

  Future<void> sendMessage({
    required String matchId,
    required String senderId,
    required String text,
  }) async {
    if (text.trim().isEmpty || _isSending || _isDisposed) return;

    _isSending = true;
    _errorMessage = null;
    _safeNotify();

    try {
      await _repository.sendMessage(
        matchId: matchId,
        senderId: senderId,
        text: text.trim(),
      );
    } catch (e) {
      _errorMessage = 'Failed to send message';
    }

    _isSending = false;
    _safeNotify();
  }

  void stopWatching() {
    _subscription?.cancel();
    _subscription = null;
    _currentMatchId = null;
    _messages = [];
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}
