import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../profile/application/profile_providers.dart';
import '../../../profile/domain/gender.dart';

class InterestsStep extends ConsumerStatefulWidget {
  const InterestsStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  ConsumerState<InterestsStep> createState() => _InterestsStepState();
}

class _InterestsStepState extends ConsumerState<InterestsStep> {
  final Set<Gender> _interestedIn = {};

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileControllerProvider).profile;
    if (profile != null) {
      _interestedIn.addAll(profile.interestedIn);
    }
  }

  void _toggleInterest(Gender gender) {
    setState(() {
      if (_interestedIn.contains(gender)) {
        _interestedIn.remove(gender);
      } else {
        _interestedIn.add(gender);
      }
    });
  }

  Future<void> _saveAndContinue() async {
    await ref
        .read(profileControllerProvider)
        .updateInterestedIn(_interestedIn.toList());
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Interested in', style: theme.textTheme.displayMedium),
        const SizedBox(height: 8),
        Text(
          'Who are you looking to meet?',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 32),
        ...Gender.values.map((gender) {
          final isSelected = _interestedIn.contains(gender);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _InterestOption(
              gender: gender,
              isSelected: isSelected,
              onTap: () => _toggleInterest(gender),
            ),
          );
        }),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _interestedIn.isNotEmpty ? _saveAndContinue : null,
          child: const Text('Continue'),
        ),
      ],
    );
  }
}

class _InterestOption extends StatelessWidget {
  const _InterestOption({
    required this.gender,
    required this.isSelected,
    required this.onTap,
  });

  final Gender gender;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: isSelected ? theme.colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
              const SizedBox(width: 16),
              Text(
                gender.label,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
