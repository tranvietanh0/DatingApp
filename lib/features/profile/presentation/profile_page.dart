import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  static const routeName = 'profile';
  static const routePath = '/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authController = ref.watch(authControllerProvider);
    final session = authController.session;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Foundation profile stub', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(
              'Module 3 will turn this into onboarding, photo upload, and profile editing. For now it anchors the navigation shell and app structure.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  radius: 24,
                  child: Icon(Icons.person_rounded),
                ),
                title: Text(session?.displayName ?? 'Your future profile lives here'),
                subtitle: Text(
                  session == null
                      ? 'Photos, bio, interests, settings'
                      : 'Signed in with ${session.provider}',
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: () => ref.read(authControllerProvider).signOut(),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
