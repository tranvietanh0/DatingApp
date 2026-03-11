import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_providers.dart';
import '../../chat/presentation/chat_page.dart';
import '../../profile/application/profile_providers.dart';
import '../../profile/domain/user_profile.dart';
import '../../safety/application/safety_providers.dart';
import '../../safety/presentation/safety_actions.dart';
import '../application/match_providers.dart';
import '../domain/match.dart';

class MatchesPage extends ConsumerWidget {
  const MatchesPage({super.key});

  static const routeName = 'matches';
  static const routePath = '/matches';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchController = ref.watch(matchControllerProvider);
    final safetyController = ref.watch(safetyControllerProvider);
    final session = ref.watch(authControllerProvider).session;
    final currentUserId = session?.userId ?? '';

    // Filter out blocked users and expired matches
    final blockedIds = safetyController.blockedUserIds;
    final filteredMatches = matchController.matches
        .where((match) => !blockedIds.contains(match.getOtherUserId(currentUserId)))
        .where((match) => !match.isExpired)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
        centerTitle: true,
      ),
      body: _buildBody(context, ref, matchController, filteredMatches, currentUserId),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    dynamic controller,
    List<Match> matches,
    String currentUserId,
  ) {
    final theme = Theme.of(context);

    if (controller.isLoading && matches.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage != null && matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(controller.errorMessage!),
          ],
        ),
      );
    }

    if (matches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_border_rounded,
                size: 80,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 24),
              Text(
                'No matches yet',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Keep swiping to find your match!',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return _MatchTile(
          match: match,
          currentUserId: currentUserId,
        );
      },
    );
  }
}

class _MatchTile extends ConsumerWidget {
  const _MatchTile({
    required this.match,
    required this.currentUserId,
  });

  final Match match;
  final String currentUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final otherUserId = match.getOtherUserId(currentUserId);
    final hasUnread = match.hasUnread(currentUserId);

    return FutureBuilder<UserProfile?>(
      future: ref.read(profileRepositoryProvider).getProfile(otherUserId),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final name = profile?.name ?? 'Someone';
        final photoUrl = profile?.photos.firstOrNull;

        return ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundImage:
                photoUrl != null ? CachedNetworkImageProvider(photoUrl) : null,
            child: photoUrl == null ? Text(name[0].toUpperCase()) : null,
          ),
          title: Text(
            name,
            style: hasUnread ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
          subtitle: Text(
            match.lastMessage ?? 'Say hi!',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: hasUnread
                ? TextStyle(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  )
                : null,
          ),
          trailing: hasUnread
              ? Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          onTap: () {
            context.push(
              ChatPage.routePath
                  .replaceFirst(':matchId', match.id),
              extra: {'userId': otherUserId},
            );
          },
          onLongPress: () {
            showSafetyActions(
              context,
              ref,
              targetUserId: otherUserId,
              targetUserName: name,
            );
          },
        );
      },
    );
  }
}
