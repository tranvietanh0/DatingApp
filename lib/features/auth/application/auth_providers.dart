import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../data/local_auth_repository.dart';
import 'auth_controller.dart';

// Set to true to use local auth for testing without Firebase
const bool useMockAuth = true;

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // Use local repository for testing without Firebase
  if (useMockAuth) {
    return LocalAuthRepository();
  }
  // TODO: Return FirebaseAuthRepository() when Firebase is configured
  return LocalAuthRepository();
});

final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) {
  final controller = AuthController(repository: ref.watch(authRepositoryProvider));
  unawaited(controller.bootstrap());
  return controller;
});
