import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/firestore_safety_repository.dart';
import '../data/mock_safety_repository.dart';
import '../data/safety_repository.dart';
import 'safety_controller.dart';

// Set to true to use mock data for testing without Firebase
const bool useMockSafety = false;

final safetyRepositoryProvider = Provider<SafetyRepository>((ref) {
  if (useMockSafety) {
    return MockSafetyRepository();
  }
  return FirestoreSafetyRepository();
});

final safetyControllerProvider = ChangeNotifierProvider<SafetyController>((ref) {
  final repository = ref.watch(safetyRepositoryProvider);
  return SafetyController(repository: repository);
});
