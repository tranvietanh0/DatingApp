import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_safety_repository.dart';
import '../data/safety_repository.dart';
import 'safety_controller.dart';

// Set to true to use mock data for testing without Firebase
const bool useMockSafety = true;

final safetyRepositoryProvider = Provider<SafetyRepository>((ref) {
  if (useMockSafety) {
    return MockSafetyRepository();
  }
  // TODO: Return FirestoreSafetyRepository() when Firebase is configured
  return MockSafetyRepository();
});

final safetyControllerProvider = ChangeNotifierProvider<SafetyController>((ref) {
  final repository = ref.watch(safetyRepositoryProvider);
  return SafetyController(repository: repository);
});
