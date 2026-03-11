import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../data/local_auth_repository.dart';
import 'auth_controller.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return LocalAuthRepository();
});

final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) {
  final controller = AuthController(repository: ref.watch(authRepositoryProvider));
  unawaited(controller.bootstrap());
  return controller;
});
