import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../../matches/application/match_providers.dart';
import '../../profile/application/profile_providers.dart';
import '../../profile/domain/user_profile.dart';
import '../application/chat_providers.dart';
import 'widgets/chat_input.dart';
import 'widgets/match_expiry_banner.dart';
import 'widgets/message_bubble.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({
    super.key,
    required this.matchId,
    required this.otherUserId,
  });

  final String matchId;
  final String otherUserId;

  static const routeName = 'chat';
  static const routePath = '/chat/:matchId';

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initChat() {
    final session = ref.read(authControllerProvider).session;
    if (session != null) {
      ref.read(chatControllerProvider).watchMessages(
            widget.matchId,
            session.userId,
          );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage(String text) {
    final session = ref.read(authControllerProvider).session;
    if (session == null) return;

    ref.read(chatControllerProvider).sendMessage(
          matchId: widget.matchId,
          senderId: session.userId,
          text: text,
        );

    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider).session;
    final chatController = ref.watch(chatControllerProvider);
    final matchController = ref.watch(matchControllerProvider);
    final match = matchController.getMatch(widget.matchId);
    final currentUserId = session?.userId ?? '';

    // Determine if input should be enabled
    final canSendMessage = match == null ||
        !match.bumbleMode ||
        match.lastMessage != null ||
        match.canSendFirstMessage(currentUserId);

    final isExpired = match?.isExpired ?? false;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: FutureBuilder<UserProfile?>(
          future: ref.read(profileRepositoryProvider).getProfile(widget.otherUserId),
          builder: (context, snapshot) {
            final profile = snapshot.data;
            return Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: profile?.photos.firstOrNull != null
                      ? CachedNetworkImageProvider(profile!.photos.first)
                      : null,
                  child: profile?.photos.firstOrNull == null
                      ? Text((profile?.name ?? '?')[0].toUpperCase())
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile?.name ?? 'Loading...',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          if (match != null)
            MatchExpiryBanner(
              match: match,
              currentUserId: currentUserId,
              onExtend: () => _extendMatch(matchController),
            ),
          Expanded(
            child: _buildMessageList(chatController, currentUserId),
          ),
          ChatInput(
            onSend: _sendMessage,
            enabled: !chatController.isSending && canSendMessage && !isExpired,
            hintText: !canSendMessage
                ? 'Waiting for her to message first...'
                : isExpired
                    ? 'Match expired'
                    : null,
          ),
        ],
      ),
    );
  }

  Future<void> _extendMatch(dynamic matchController) async {
    final success = await matchController.extendMatch(widget.matchId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match extended by 24 hours!')),
      );
    }
  }

  Widget _buildMessageList(dynamic controller, String currentUserId) {
    final theme = Theme.of(context);

    if (controller.isLoading && controller.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 64,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No messages yet',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Say hi to start the conversation!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: controller.messages.length,
      itemBuilder: (context, index) {
        final message = controller.messages[index];
        final isMe = message.senderId == currentUserId;
        return MessageBubble(message: message, isMe: isMe);
      },
    );
  }
}
