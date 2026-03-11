import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/discovery_repository.dart';
import '../data/mock_discovery_repository.dart';
import 'discovery_controller.dart';

// Set to true to use mock data for testing
const bool useMockData = true;

final discoveryRepositoryProvider = Provider<DiscoveryRepository>((ref) {
  // Use mock repository for testing without Firebase
  if (useMockData) {
    return MockDiscoveryRepository();
  }
  // TODO: Return FirestoreDiscoveryRepository() when Firebase is configured
  return MockDiscoveryRepository();
});

final discoveryControllerProvider =
    ChangeNotifierProvider<DiscoveryController>((ref) {
  return DiscoveryController(
    repository: ref.watch(discoveryRepositoryProvider),
  );
});
