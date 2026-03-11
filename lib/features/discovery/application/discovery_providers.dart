import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/discovery_repository.dart';
import '../data/firestore_discovery_repository.dart';
import 'discovery_controller.dart';

final discoveryRepositoryProvider = Provider<DiscoveryRepository>((ref) {
  return FirestoreDiscoveryRepository();
});

final discoveryControllerProvider =
    ChangeNotifierProvider<DiscoveryController>((ref) {
  return DiscoveryController(
    repository: ref.watch(discoveryRepositoryProvider),
  );
});
