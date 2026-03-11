import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/chat_repository.dart';
import '../data/firestore_chat_repository.dart';
import '../data/mock_chat_repository.dart';
import 'chat_controller.dart';

// Set to true to use mock data for testing without Firebase
const bool useMockChat = false;

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  if (useMockChat) {
    return MockChatRepository();
  }
  return FirestoreChatRepository();
});

final chatControllerProvider = ChangeNotifierProvider.autoDispose<ChatController>((ref) {
  final controller = ChatController(
    repository: ref.watch(chatRepositoryProvider),
  );

  ref.onDispose(() => controller.dispose());

  return controller;
});
