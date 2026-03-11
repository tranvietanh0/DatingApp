import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../profile/application/profile_providers.dart';
import '../../../profile/domain/gender.dart';

class BasicInfoStep extends ConsumerStatefulWidget {
  const BasicInfoStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  ConsumerState<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends ConsumerState<BasicInfoStep> {
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  Gender? _gender;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileControllerProvider).profile;
    if (profile != null) {
      _nameController.text = profile.name;
      _birthDate = profile.birthDate;
      _gender = profile.gender;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _nameController.text.trim().isNotEmpty &&
      _birthDate != null &&
      _gender != null &&
      _isAgeValid;

  bool get _isAgeValid {
    if (_birthDate == null) return false;
    final age = DateTime.now().difference(_birthDate!).inDays ~/ 365;
    return age >= 18;
  }

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final initialDate = _birthDate ?? DateTime(now.year - 25, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 18, now.month, now.day),
    );

    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _saveAndContinue() async {
    final controller = ref.read(profileControllerProvider);
    await controller.updateName(_nameController.text);
    await controller.updateBirthDate(_birthDate!);
    await controller.updateGender(_gender!);
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('About you', style: theme.textTheme.displayMedium),
        const SizedBox(height: 8),
        Text(
          'Let\'s start with the basics.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'First name',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 20),
        _DateField(
          label: 'Birthday',
          value: _birthDate,
          onTap: _selectBirthDate,
        ),
        if (_birthDate != null && !_isAgeValid) ...[
          const SizedBox(height: 8),
          Text(
            'You must be at least 18 years old.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 20),
        Text('I am', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        _GenderSelector(
          selected: _gender,
          onChanged: (g) => setState(() => _gender = g),
        ),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: _canContinue ? _saveAndContinue : null,
          child: const Text('Continue'),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today_rounded),
        ),
        child: Text(
          value != null
              ? '${value!.day}/${value!.month}/${value!.year}'
              : 'Select date',
          style: value != null
              ? theme.textTheme.bodyLarge
              : theme.textTheme.bodyLarge?.copyWith(
                  color: theme.hintColor,
                ),
        ),
      ),
    );
  }
}

class _GenderSelector extends StatelessWidget {
  const _GenderSelector({
    required this.selected,
    required this.onChanged,
  });

  final Gender? selected;
  final ValueChanged<Gender> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: Gender.values.map((gender) {
        final isSelected = selected == gender;
        return ChoiceChip(
          label: Text(gender.label),
          selected: isSelected,
          onSelected: (_) => onChanged(gender),
        );
      }).toList(),
    );
  }
}
