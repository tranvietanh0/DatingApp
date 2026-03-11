import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../data/firebase_auth_repository.dart';
import '../data/local_auth_repository.dart';
import 'auth_controller.dart';

// Set to true to use local auth for testing without Firebase
const bool useMockAuth = false;

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (useMockAuth) {
    return LocalAuthRepository();
  }
  return FirebaseAuthRepository();
});

final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) {
  final controller = AuthController(repository: ref.watch(authRepositoryProvider));
  unawaited(controller.bootstrap());
  return controller;
});
