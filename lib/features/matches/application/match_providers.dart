import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/bumble_rules_repository.dart';
import '../data/firestore_match_repository.dart';
import '../data/match_repository.dart';
import '../data/mock_match_repository.dart';
import 'match_controller.dart';

// Set to true to use mock data for testing without Firebase
const bool useMockMatches = false;

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  if (useMockMatches) {
    return MockMatchRepository();
  }
  return FirestoreMatchRepository();
});

final bumbleRulesRepositoryProvider = Provider<BumbleRulesRepository>((ref) {
  if (useMockMatches) {
    return MockBumbleRulesRepository();
  }
  return FirestoreBumbleRulesRepository();
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
