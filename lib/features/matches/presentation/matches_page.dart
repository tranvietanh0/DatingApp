import 'package:flutter/material.dart';

class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key});

  static const routeName = 'matches';
  static const routePath = '/matches';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Matches')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Upcoming module', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(
            'This tab is reserved for Module 5, where mutual likes, match celebration, and the match list will land.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          for (final name in ['Mia', 'An', 'Sophie'])
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(name[0])),
                title: Text(name),
                subtitle: const Text('Preview placeholder'),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            ),
        ],
      ),
    );
  }
}
