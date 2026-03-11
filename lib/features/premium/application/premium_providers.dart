import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/mock_premium_repository.dart';
import '../data/premium_repository.dart';
import 'premium_controller.dart';

// Set to true to use mock data for testing without Firebase
const bool useMockPremium = true;

final premiumRepositoryProvider = Provider<PremiumRepository>((ref) {
  if (useMockPremium) {
    return MockPremiumRepository();
  }
  // TODO: Return FirestorePremiumRepository() when Firebase is configured
  return MockPremiumRepository();
});

final premiumControllerProvider = ChangeNotifierProvider<PremiumController>((ref) {
  final controller = PremiumController(
    repository: ref.watch(premiumRepositoryProvider),
  );

  final session = ref.watch(authControllerProvider).session;
  if (session != null) {
    controller.watchStatus(session.userId);
  }

  ref.onDispose(() => controller.dispose());

  return controller;
});
