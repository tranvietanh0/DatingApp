import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/gradient_scaffold.dart';
import '../../auth/application/auth_providers.dart';

class DiscoveryPage extends ConsumerWidget {
  const DiscoveryPage({super.key});

  static const routeName = 'discovery';
  static const routePath = '/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final session = ref.watch(authControllerProvider).session;

    return GradientScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        children: [
          Text('Spark real chemistry.', style: theme.textTheme.displayMedium),
          const SizedBox(height: 12),
          Text(
            'Module 1 sets up the shell, routing, theming, and starter discovery experience for the Android MVP.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          Text(
            'Signed in as ${session?.displayName ?? 'guest'} via ${session?.provider ?? 'unknown provider'}.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 320,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFF8C8B8), Color(0xFFE56B5D)],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 24,
                          top: 24,
                          child: Chip(
                            avatar: const Icon(Icons.place_rounded, size: 16),
                            label: const Text('Hanoi, 4 km away'),
                          ),
                        ),
                        Positioned(
                          left: 24,
                          right: 24,
                          bottom: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Linh, 25',
                                style: theme.textTheme.displaySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Cafe explorer, pilates addict, and always planning the next city escape.',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      Chip(label: Text('Verified-ready foundation')),
                      Chip(label: Text('Router + shell')),
                      Chip(label: Text('Warm brand theme')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () {},
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Pass'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_rounded),
                  label: const Text('Like'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
