import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/bumble_rules_repository.dart';
import '../data/firestore_match_repository.dart';
import '../data/match_repository.dart';
import 'match_controller.dart';

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return FirestoreMatchRepository();
});

final bumbleRulesRepositoryProvider = Provider<BumbleRulesRepository>((ref) {
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
