import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../main.dart' show useMockMode;

class DatingApp extends ConsumerWidget {
  const DatingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    // Skip NotificationWrapper in mock mode (requires Firebase)
    return MaterialApp.router(
      title: 'Dating App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
