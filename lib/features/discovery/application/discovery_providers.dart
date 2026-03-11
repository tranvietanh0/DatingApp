import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/discovery_repository.dart';
import '../data/firestore_discovery_repository.dart';
import '../data/mock_discovery_repository.dart';
import 'discovery_controller.dart';

// Set to true to use mock data for testing
const bool useMockData = false;

final discoveryRepositoryProvider = Provider<DiscoveryRepository>((ref) {
  if (useMockData) {
    return MockDiscoveryRepository();
  }
  return FirestoreDiscoveryRepository();
});

final discoveryControllerProvider =
    ChangeNotifierProvider<DiscoveryController>((ref) {
  return DiscoveryController(
    repository: ref.watch(discoveryRepositoryProvider),
  );
});
