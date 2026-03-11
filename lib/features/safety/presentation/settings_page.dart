import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_providers.dart';
import '../../profile/application/profile_providers.dart';
import '../application/safety_providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  static const routeName = 'settings';
  static const routePath = '/settings';

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileController = ref.watch(profileControllerProvider);
    final isVisible = profileController.profile?.isVisible ?? true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Profile visibility section
          _SectionHeader(title: 'Privacy'),
          SwitchListTile(
            title: const Text('Show my profile'),
            subtitle: Text(
              isVisible
                  ? 'Your profile is visible in discovery'
                  : 'Your profile is hidden from discovery',
            ),
            value: isVisible,
            onChanged: (value) => _toggleVisibility(value),
          ),
          const Divider(),

          // Account section
          _SectionHeader(title: 'Account'),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: _signOut,
          ),
          ListTile(
            leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
            title: Text(
              'Delete account',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: const Text('This action cannot be undone'),
            onTap: _isDeleting ? null : _deleteAccount,
          ),
        ],
      ),
    );
  }

  Future<void> _toggleVisibility(bool isVisible) async {
    final userId = ref.read(authControllerProvider).session?.userId;
    if (userId == null) return;

    final safetyController = ref.read(safetyControllerProvider);
    final success = await safetyController.setProfileVisibility(userId, isVisible);

    if (success) {
      // Reload profile to reflect change
      ref.read(profileControllerProvider).loadProfile(userId);
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authControllerProvider).signOut();
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account'),
        content: const Text(
          'Are you sure you want to delete your account? '
          'This will permanently delete your profile, matches, and messages. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final userId = ref.read(authControllerProvider).session?.userId;
    if (userId == null) return;

    setState(() => _isDeleting = true);

    final safetyController = ref.read(safetyControllerProvider);
    final success = await safetyController.deleteAccount(userId);

    if (!mounted) return;

    if (success) {
      // Auth state will change, router will redirect to sign in
      context.go('/');
    } else {
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete account')),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
