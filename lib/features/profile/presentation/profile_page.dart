import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../safety/presentation/settings_page.dart';
import '../application/profile_providers.dart';
import 'edit_profile_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  static const routeName = 'profile';
  static const routePath = '/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(profileControllerProvider).profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () => context.push(EditProfilePage.routePath),
            icon: const Icon(Icons.edit_rounded),
          ),
          IconButton(
            onPressed: () => context.push(SettingsPage.routePath),
            icon: const Icon(Icons.settings_rounded),
          ),
        ],
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _PhotosSection(photos: profile.photos),
                const SizedBox(height: 24),
                _ProfileHeader(
                  name: profile.name,
                  age: profile.age,
                ),
                const SizedBox(height: 16),
                if (profile.bio.isNotEmpty) ...[
                  Text(profile.bio, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 16),
                ],
                if (profile.job.isNotEmpty)
                  _InfoRow(
                    icon: Icons.work_outline_rounded,
                    text: profile.job,
                  ),
                if (profile.school.isNotEmpty)
                  _InfoRow(
                    icon: Icons.school_outlined,
                    text: profile.school,
                  ),
                _InfoRow(
                  icon: Icons.person_outline_rounded,
                  text: profile.gender?.label ?? 'Not specified',
                ),
                _InfoRow(
                  icon: Icons.favorite_outline_rounded,
                  text: profile.interestedIn.isEmpty
                      ? 'Not specified'
                      : 'Interested in ${profile.interestedIn.map((g) => g.label).join(', ')}',
                ),
              ],
            ),
    );
  }
}

class _PhotosSection extends StatelessWidget {
  const _PhotosSection({required this.photos});

  final List<String> photos;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.person_rounded, size: 64),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          photos.first,
          fit: BoxFit.cover,
          errorBuilder: (_, error, stackTrace) => Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Icon(Icons.broken_image_rounded, size: 64),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name, required this.age});

  final String name;
  final int? age;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = name.isEmpty ? 'Your Name' : name;
    final displayAge = age != null ? ', $age' : '';

    return Text(
      '$displayName$displayAge',
      style: theme.textTheme.headlineMedium,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.outline),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
