import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../profile/application/profile_providers.dart';

class BioStep extends ConsumerStatefulWidget {
  const BioStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  ConsumerState<BioStep> createState() => _BioStepState();
}

class _BioStepState extends ConsumerState<BioStep> {
  final _bioController = TextEditingController();
  final _schoolController = TextEditingController();
  final _jobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileControllerProvider).profile;
    if (profile != null) {
      _bioController.text = profile.bio;
      _schoolController.text = profile.school;
      _jobController.text = profile.job;
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _schoolController.dispose();
    _jobController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    final controller = ref.read(profileControllerProvider);
    await controller.updateBio(_bioController.text);
    await controller.updateSchool(_schoolController.text);
    await controller.updateJob(_jobController.text);
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Tell us more', style: theme.textTheme.displayMedium),
        const SizedBox(height: 8),
        Text(
          'Help others get to know you better.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _bioController,
          maxLines: 4,
          maxLength: 500,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'About me',
            hintText: 'Share what makes you unique...',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _jobController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Job title',
            hintText: 'What do you do?',
            prefixIcon: Icon(Icons.work_outline_rounded),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _schoolController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'School',
            hintText: 'Where did you study?',
            prefixIcon: Icon(Icons.school_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'These fields are optional but help you stand out.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: _saveAndContinue,
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
