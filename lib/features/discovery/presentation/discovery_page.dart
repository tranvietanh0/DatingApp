import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/gradient_scaffold.dart';
import '../../auth/application/auth_providers.dart';
import '../../premium/application/premium_providers.dart';
import '../../premium/presentation/premium_paywall.dart';
import '../../premium/presentation/who_liked_you_page.dart';
import '../../profile/application/profile_providers.dart';
import '../application/discovery_providers.dart';
import '../domain/swipe_action.dart';
import 'widgets/action_buttons.dart';
import 'widgets/swipe_card.dart';

class DiscoveryPage extends ConsumerStatefulWidget {
  const DiscoveryPage({super.key});

  static const routeName = 'discovery';
  static const routePath = '/';

  @override
  ConsumerState<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends ConsumerState<DiscoveryPage> {
  final CardSwiperController _swiperController = CardSwiperController();
  bool _showMatchCelebration = false;
  String? _matchedUserName;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  Future<void> _loadCandidates() async {
    final session = ref.read(authControllerProvider).session;
    final profile = ref.read(profileControllerProvider).profile;

    if (session == null || profile == null) return;

    final lat = profile.latitude ?? 0;
    final lng = profile.longitude ?? 0;

    await ref.read(discoveryControllerProvider).loadCandidates(
          userId: session.userId,
          latitude: lat,
          longitude: lng,
        );
  }

  Future<void> _onSwipe(SwipeAction action) async {
    final session = ref.read(authControllerProvider).session;
    final candidates = ref.read(discoveryControllerProvider).candidates;

    if (session == null || candidates.isEmpty) return;

    final target = candidates.first;
    final isMatch = await ref.read(discoveryControllerProvider).swipe(
          swiperId: session.userId,
          targetId: target.userId,
          action: action,
        );

    if (isMatch && mounted) {
      setState(() {
        _showMatchCelebration = true;
        _matchedUserName = target.name;
      });
    }
  }

  bool _handleSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    final action = switch (direction) {
      CardSwiperDirection.right => SwipeAction.like,
      CardSwiperDirection.left => SwipeAction.pass,
      CardSwiperDirection.top => SwipeAction.superLike,
      _ => null,
    };

    if (action != null) {
      _onSwipe(action);
    }

    return true;
  }

  void _dismissMatchCelebration() {
    setState(() {
      _showMatchCelebration = false;
      _matchedUserName = null;
    });
  }

  Future<void> _onUndo() async {
    final premium = ref.read(premiumControllerProvider);
    final session = ref.read(authControllerProvider).session;

    if (!premium.status.canUndo) {
      _showPaywall();
      return;
    }

    if (session == null) return;

    final undoneUserId = await premium.undoLastSwipe(session.userId);
    if (undoneUserId != null && mounted) {
      // Reload candidates to show undone profile again
      _loadCandidates();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Swipe undone!')),
      );
    }
  }

  Future<void> _onBoost() async {
    final premium = ref.read(premiumControllerProvider);
    final session = ref.read(authControllerProvider).session;

    if (!premium.status.canBoost && !premium.status.isPremium) {
      _showPaywall();
      return;
    }

    if (premium.isBoosted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Boost already active!')),
      );
      return;
    }

    if (session == null) return;

    final success = await premium.activateBoost(session.userId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Boost activated for 30 minutes!')),
      );
    }
  }

  void _showPaywall() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const PremiumPaywall(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final discovery = ref.watch(discoveryControllerProvider);
    final candidates = discovery.candidates;

    return GradientScaffold(
      child: Stack(
        children: [
          Column(
            children: [
              // Header
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Text(
                        'Discover',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      _LikesButton(),
                      IconButton(
                        onPressed: () {
                          // TODO: Show filter sheet
                        },
                        icon: const Icon(Icons.tune_rounded),
                      ),
                    ],
                  ),
                ),
              ),

              // Card stack
              Expanded(
                child: _buildCardStack(discovery, candidates),
              ),

              // Action buttons
              if (candidates.isNotEmpty)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: ActionButtons(
                      enabled: !discovery.isLoading,
                      onUndo: _onUndo,
                      onPass: () => _swiperController.swipe(CardSwiperDirection.left),
                      onLike: () => _swiperController.swipe(CardSwiperDirection.right),
                      onSuperLike: () => _swiperController.swipe(CardSwiperDirection.top),
                      onBoost: _onBoost,
                    ),
                  ),
                ),
            ],
          ),

          // Match celebration overlay
          if (_showMatchCelebration) _buildMatchCelebration(),
        ],
      ),
    );
  }

  Widget _buildCardStack(dynamic discovery, List candidates) {
    final theme = Theme.of(context);

    if (discovery.isLoading && candidates.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (discovery.errorMessage != null && candidates.isEmpty) {
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
            Text(
              discovery.errorMessage!,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loadCandidates,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (candidates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 80,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 24),
              Text(
                'No one nearby',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Try expanding your filters or check back later.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: _loadCandidates,
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: CardSwiper(
        controller: _swiperController,
        cardsCount: candidates.length,
        numberOfCardsDisplayed: candidates.length.clamp(1, 3),
        onSwipe: _handleSwipe,
        padding: EdgeInsets.zero,
        cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
          return SwipeCard(profile: candidates[index]);
        },
      ),
    );
  }

  Widget _buildMatchCelebration() {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _dismissMatchCelebration,
      child: Container(
        color: Colors.black.withValues(alpha: 0.85),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_rounded,
                size: 100,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                "It's a Match!",
                style: theme.textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You and $_matchedUserName liked each other',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: _dismissMatchCelebration,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                    ),
                    child: const Text('Keep Swiping'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: () {
                      _dismissMatchCelebration();
                      // TODO: Navigate to chat
                    },
                    child: const Text('Send Message'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LikesButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final premium = ref.watch(premiumControllerProvider);
    final likesCount = premium.likesCount;

    return Stack(
      children: [
        IconButton(
          onPressed: () => context.push(WhoLikedYouPage.routePath),
          icon: const Icon(Icons.favorite_rounded),
        ),
        if (likesCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                likesCount > 99 ? '99+' : likesCount.toString(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
