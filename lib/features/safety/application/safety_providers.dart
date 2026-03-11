import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/firestore_safety_repository.dart';
import '../data/safety_repository.dart';
import 'safety_controller.dart';

final safetyRepositoryProvider = Provider<SafetyRepository>((ref) {
  return FirestoreSafetyRepository();
});

final safetyControllerProvider = ChangeNotifierProvider<SafetyController>((ref) {
  final repository = ref.watch(safetyRepositoryProvider);
  return SafetyController(repository: repository);
});
