import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/mock_profile_repository.dart';
import '../data/profile_repository.dart';
import 'profile_controller.dart';

// Set to true to use mock data for testing without Firebase
const bool useMockProfile = true;

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  // Use mock repository for testing without Firebase
  if (useMockProfile) {
    return MockProfileRepository();
  }
  // TODO: Return FirestoreProfileRepository() when Firebase is configured
  return MockProfileRepository();
});

final profileControllerProvider = ChangeNotifierProvider<ProfileController>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  final controller = ProfileController(repository: repository);

  final session = ref.watch(authControllerProvider).session;
  if (session != null) {
    controller.loadProfile(session.userId);
  }

  return controller;
});
