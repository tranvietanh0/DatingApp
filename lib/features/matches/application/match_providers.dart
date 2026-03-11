import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/bumble_rules_repository.dart';
import '../data/match_repository.dart';
import '../data/mock_match_repository.dart';
import 'match_controller.dart';

// Set to true to use mock data for testing without Firebase
const bool useMockMatches = true;

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  if (useMockMatches) {
    return MockMatchRepository();
  }
  // TODO: Return FirestoreMatchRepository() when Firebase is configured
  return MockMatchRepository();
});

final bumbleRulesRepositoryProvider = Provider<BumbleRulesRepository>((ref) {
  if (useMockMatches) {
    return MockBumbleRulesRepository();
  }
  // TODO: Return FirestoreBumbleRulesRepository() when Firebase is configured
  return MockBumbleRulesRepository();
});

final matchControllerProvider = ChangeNotifierProvider<MatchController>((ref) {
  final controller = MatchController(
    repository: ref.watch(matchRepositoryProvider),
    bumbleRulesRepository: ref.watch(bumbleRulesRepositoryProvider),
  );

  final session = ref.watch(authControllerProvider).session;
  if (session != null) {
    controller.watchMatches(session.userId);
  }

  ref.onDispose(() => controller.dispose());

  return controller;
});
