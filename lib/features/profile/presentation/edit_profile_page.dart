import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/profile_providers.dart';
import '../domain/gender.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  static const routeName = 'edit-profile';
  static const routePath = '/profile/edit';

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _jobController = TextEditingController();
  final _schoolController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileControllerProvider).profile;
    if (profile != null) {
      _nameController.text = profile.name;
      _bioController.text = profile.bio;
      _jobController.text = profile.job;
      _schoolController.text = profile.school;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _jobController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final controller = ref.read(profileControllerProvider);
    await controller.updateName(_nameController.text);
    await controller.updateBio(_bioController.text);
    await controller.updateJob(_jobController.text);
    await controller.updateSchool(_schoolController.text);

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(profileControllerProvider).profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _PhotosEditor(
            photos: profile?.photos ?? [],
            onAdd: () => _addPhoto(),
            onRemove: (index) =>
                ref.read(profileControllerProvider).removePhoto(index),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bioController,
            maxLines: 4,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'About me',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _jobController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Job',
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
              prefixIcon: Icon(Icons.school_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Text('Gender', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _GenderChips(
            selected: profile?.gender,
            onChanged: (g) => ref.read(profileControllerProvider).updateGender(g),
          ),
          const SizedBox(height: 24),
          Text('Interested in', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _InterestChips(
            selected: profile?.interestedIn ?? [],
            onChanged: (list) =>
                ref.read(profileControllerProvider).updateInterestedIn(list),
          ),
        ],
      ),
    );
  }

  Future<void> _addPhoto() async {
    final demoPhotos = [
      'https://picsum.photos/seed/edit1/400/600',
      'https://picsum.photos/seed/edit2/400/600',
      'https://picsum.photos/seed/edit3/400/600',
      'https://picsum.photos/seed/edit4/400/600',
      'https://picsum.photos/seed/edit5/400/600',
      'https://picsum.photos/seed/edit6/400/600',
    ];

    final currentPhotos = ref.read(profileControllerProvider).profile?.photos ?? [];
    if (currentPhotos.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 6 photos allowed')),
      );
      return;
    }

    final nextIndex = currentPhotos.length;
    await ref.read(profileControllerProvider).addPhoto(demoPhotos[nextIndex]);
  }
}

class _PhotosEditor extends StatelessWidget {
  const _PhotosEditor({
    required this.photos,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> photos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length + (photos.length < 6 ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == photos.length) {
            return _AddPhotoButton(onTap: onAdd);
          }
          return _PhotoThumbnail(
            photoUrl: photos[index],
            onRemove: () => onRemove(index),
          );
        },
      ),
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  const _PhotoThumbnail({
    required this.photoUrl,
    required this.onRemove,
  });

  final String photoUrl;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              photoUrl,
              width: 90,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPhotoButton extends StatelessWidget {
  const _AddPhotoButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 120,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.add_rounded,
          color: theme.colorScheme.outline,
        ),
      ),
    );
  }
}

class _GenderChips extends StatelessWidget {
  const _GenderChips({required this.selected, required this.onChanged});

  final Gender? selected;
  final ValueChanged<Gender> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: Gender.values.map((g) {
        return ChoiceChip(
          label: Text(g.label),
          selected: selected == g,
          onSelected: (_) => onChanged(g),
        );
      }).toList(),
    );
  }
}

class _InterestChips extends StatelessWidget {
  const _InterestChips({required this.selected, required this.onChanged});

  final List<Gender> selected;
  final ValueChanged<List<Gender>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: Gender.values.map((g) {
        final isSelected = selected.contains(g);
        return FilterChip(
          label: Text(g.label),
          selected: isSelected,
          onSelected: (value) {
            final newList = [...selected];
            if (value) {
              newList.add(g);
            } else {
              newList.remove(g);
            }
            onChanged(newList);
          },
        );
      }).toList(),
    );
  }
}
