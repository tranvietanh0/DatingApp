import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_providers.dart';
import '../../features/auth/domain/auth_status.dart';
import '../../features/auth/presentation/otp_verification_page.dart';
import '../../features/auth/presentation/sign_in_page.dart';
import '../../features/auth/presentation/splash_page.dart';
import '../../features/discovery/presentation/discovery_page.dart';
import '../../features/matches/presentation/matches_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../shell/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authController = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: SplashPage.routePath,
    refreshListenable: authController,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isSplash = location == SplashPage.routePath;
      final isSignIn = location == SignInPage.routePath;
      final isOtp = location == OtpVerificationPage.routePath;
      final isAuthRoute = isSplash || isSignIn || isOtp;

      switch (authController.status) {
        case AuthStatus.initial:
          return isSplash ? null : SplashPage.routePath;
        case AuthStatus.authenticating:
          return isAuthRoute ? null : SplashPage.routePath;
        case AuthStatus.unauthenticated:
          if (authController.pendingPhoneNumber != null) {
            return isOtp ? null : OtpVerificationPage.routePath;
          }
          return isSignIn ? null : SignInPage.routePath;
        case AuthStatus.authenticated:
          return isAuthRoute ? DiscoveryPage.routePath : null;
      }
    },
    routes: [
      GoRoute(
        path: SplashPage.routePath,
        name: SplashPage.routeName,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: SignInPage.routePath,
        name: SignInPage.routeName,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: OtpVerificationPage.routePath,
        name: OtpVerificationPage.routeName,
        builder: (context, state) => const OtpVerificationPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: DiscoveryPage.routePath,
                name: DiscoveryPage.routeName,
                builder: (context, state) => const DiscoveryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: MatchesPage.routePath,
                name: MatchesPage.routeName,
                builder: (context, state) => const MatchesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ProfilePage.routePath,
                name: ProfilePage.routeName,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
