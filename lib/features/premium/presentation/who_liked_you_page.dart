import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../application/premium_providers.dart';
import '../domain/liker.dart';
import 'premium_paywall.dart';

class WhoLikedYouPage extends ConsumerStatefulWidget {
  const WhoLikedYouPage({super.key});

  static const routeName = 'who-liked-you';
  static const routePath = '/who-liked-you';

  @override
  ConsumerState<WhoLikedYouPage> createState() => _WhoLikedYouPageState();
}

class _WhoLikedYouPageState extends ConsumerState<WhoLikedYouPage> {
  @override
  void initState() {
    super.initState();
    _loadLikers();
  }

  Future<void> _loadLikers() async {
    final userId = ref.read(authControllerProvider).session?.userId;
    if (userId != null) {
      await ref.read(premiumControllerProvider).loadWhoLikedYou(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final premiumController = ref.watch(premiumControllerProvider);
    final isPremium = premiumController.status.isPremium;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Who Liked You'),
        actions: [
          if (!isPremium)
            TextButton(
              onPressed: () => _showPaywall(context),
              child: const Text('Unlock'),
            ),
        ],
      ),
      body: _buildBody(theme, premiumController, isPremium),
    );
  }

  Widget _buildBody(ThemeData theme, dynamic controller, bool isPremium) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.likers.isEmpty) {
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
                'No likes yet',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'When someone likes you, they\'ll appear here',
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

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: controller.likers.length,
      itemBuilder: (context, index) {
        final liker = controller.likers[index] as Liker;
        return _LikerCard(
          liker: liker,
          isPremium: isPremium,
          onTap: isPremium ? () => _onLikerTap(liker) : () => _showPaywall(context),
        );
      },
    );
  }

  void _onLikerTap(Liker liker) {
    // TODO: Navigate to profile or show in discovery
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing ${liker.name ?? "profile"}')),
    );
  }

  void _showPaywall(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const PremiumPaywall(),
    );
  }
}

class _LikerCard extends StatelessWidget {
  const _LikerCard({
    required this.liker,
    required this.isPremium,
    required this.onTap,
  });

  final Liker liker;
  final bool isPremium;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo
            if (liker.photoUrl != null)
              CachedNetworkImage(
                imageUrl: liker.photoUrl!,
                fit: BoxFit.cover,
              )
            else
              Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.person, size: 64),
              ),

            // Blur overlay for non-premium
            if (!isPremium)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.1),
                ),
              ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),

            // Info
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isPremium
                        ? '${liker.name ?? "Someone"}${liker.age != null ? ", ${liker.age}" : ""}'
                        : 'Tap to unlock',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!isPremium)
                    Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Premium',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
