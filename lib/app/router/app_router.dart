import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_providers.dart';
import '../../features/auth/domain/auth_status.dart';
import '../../features/auth/presentation/otp_verification_page.dart';
import '../../features/auth/presentation/sign_in_page.dart';
import '../../features/auth/presentation/splash_page.dart';
import '../../features/chat/presentation/chat_page.dart';
import '../../features/discovery/presentation/discovery_page.dart';
import '../../features/matches/presentation/matches_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/premium/presentation/who_liked_you_page.dart';
import '../../features/profile/application/profile_providers.dart';
import '../../features/profile/presentation/edit_profile_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/safety/presentation/settings_page.dart';
import '../shell/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authController = ref.read(authControllerProvider);
  final profileController = ref.read(profileControllerProvider);

  final listenable = Listenable.merge([authController, profileController]);

  return GoRouter(
    initialLocation: SplashPage.routePath,
    refreshListenable: listenable,
    redirect: (context, state) {
      final location = state.matchedLocation;
      debugPrint('Router: redirect called, location=$location, isComplete=${profileController.isComplete}');

      // Auth route checks
      final isSplash = location == SplashPage.routePath;
      final isSignIn = location == SignInPage.routePath;
      final isOtp = location == OtpVerificationPage.routePath;
      final isOnboarding = location == OnboardingPage.routePath;
      final isAuthRoute = isSplash || isSignIn || isOtp;

      // Handle auth states
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
          // Redirect away from auth routes
          if (isAuthRoute) {
            // Check if profile is complete
            if (profileController.isLoading) {
              return null; // Wait for profile to load
            }
            // In mock mode, allow navigation without checking profile completion
            return DiscoveryPage.routePath;
          }

          // Allow all navigation when authenticated (skip profile checks for testing)
          return null;
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
      GoRoute(
        path: OnboardingPage.routePath,
        name: OnboardingPage.routeName,
        builder: (context, state) => const OnboardingPage(),
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
      GoRoute(
        path: EditProfilePage.routePath,
        name: EditProfilePage.routeName,
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: SettingsPage.routePath,
        name: SettingsPage.routeName,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: WhoLikedYouPage.routePath,
        name: WhoLikedYouPage.routeName,
        builder: (context, state) => const WhoLikedYouPage(),
      ),
      GoRoute(
        path: ChatPage.routePath,
        name: ChatPage.routeName,
        builder: (context, state) {
          final matchId = state.pathParameters['matchId']!;
          final otherUserId = state.uri.queryParameters['userId'] ?? '';
          return ChatPage(matchId: matchId, otherUserId: otherUserId);
        },
      ),
    ],
  );
});
