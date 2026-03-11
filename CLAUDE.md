# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter dating app (Android-first MVP). Tinder-like swipe cards with mutual matching. Uses Flutter + Firebase stack.

## Commands

```bash
flutter analyze       # Static analysis
flutter test          # Run all tests
flutter run           # Run on connected device/emulator
flutter pub get       # Install dependencies

# Firebase (after setup)
cd functions && npm run build   # Build Cloud Functions
firebase deploy --only functions # Deploy functions
firebase deploy --only firestore:rules # Deploy Firestore rules
```

## Firebase Setup Required

Before running, configure Firebase:
1. Create Firebase project at https://console.firebase.google.com
2. Enable Authentication (Phone + Google)
3. Create Firestore Database
4. Create Storage bucket
5. Run `flutterfire configure` to generate `lib/firebase_options.dart`
6. Download `google-services.json` to `android/app/`
7. Deploy Cloud Functions: `cd functions && npm install && npm run deploy`

## Architecture

### Feature-First Structure
```
lib/
  app/              # App-level setup (router, shell, theme)
  core/             # Shared utilities
    theme/          # App theme, colors
    widgets/        # Reusable widgets
    services/       # Analytics, crash reporting, moderation
  features/         # Feature modules
    auth/           # Firebase Auth (Phone OTP + Google)
    profile/        # Firestore profile management
    onboarding/     # Profile setup flow
    discovery/      # Swipe cards, candidate fetching
    matches/        # Match list, Bumble rules
    chat/           # Real-time messaging
    notifications/  # FCM push notifications
    safety/         # Block, report, settings
    premium/        # Subscriptions, undo, boost, likes
```

### State Management (Riverpod)
- Providers defined in `features/{feature}/application/{feature}_providers.dart`
- Controllers extend `ChangeNotifier` for listenable state
- Auth state is bootstrapped automatically when provider is first read

### Routing (GoRouter)
- Routes defined in `lib/app/router/app_router.dart`
- Auth-aware redirects via `refreshListenable` on merged controllers
- Main app uses `StatefulShellRoute.indexedStack` for bottom nav branches

### Repository Pattern
Each feature uses an abstract repository with Firebase implementations:
- `AuthRepository` / `FirebaseAuthRepository` - Firebase Auth
- `ProfileRepository` / `FirestoreProfileRepository` - Firestore + Storage
- `DiscoveryRepository` / `FirestoreDiscoveryRepository` - Geo queries
- `MatchRepository` / `FirestoreMatchRepository` - Real-time matches
- `ChatRepository` / `FirestoreChatRepository` - Real-time messages

### Cloud Functions
Located in `functions/src/`:
- `onSwipe.ts` - Creates match on mutual like, sends FCM notifications, sets Bumble rules
- `onMessage.ts` - Updates match last message, sends FCM notifications
- `cleanupExpiredMatches.ts` - Scheduled hourly cleanup of expired Bumble matches
- `onReportCreated.ts` - Auto-flags users with multiple reports, moderation actions

### Core Services
Located in `lib/core/services/`:
- `AnalyticsService` - Firebase Analytics event tracking
- `CrashReportingService` - Firebase Crashlytics integration
- `PerformanceService` - Firebase Performance custom traces
- `ModerationService` - Rate limiting, anti-spam, user status checks

## Data Models (Firestore)

- `users/{userId}` - User profiles with geohash for location queries
- `swipes/{swipeId}` - Like/pass/superLike actions
- `matches/{matchId}` - Mutual matches (ID = sorted userIds joined by _)
- `matches/{matchId}/messages/{messageId}` - Chat messages
- `blocks/{blockId}` - User blocks (ID = blockerId_blockedId)
- `reports/{reportId}` - User reports with reason and status

## Theme
Brand colors defined in `lib/core/theme/app_theme.dart`:
- Primary: coral (#E56B5D)
- Secondary: amber (#F3B562)
- Surface: sand (#F7F1E8)
- Typography: Space Grotesk (headings), DM Sans (body)

## Module Status
All modules complete - MVP ready!

- Phase 1 (Foundation + Auth): Complete - Firebase Auth integrated
- Phase 2 (Profile + Onboarding): Complete - Firestore + Storage
- Phase 3 (Discovery + Swipe): Complete - Card swiper, geo filtering
- Phase 4 (Matching Engine): Complete - Cloud Functions for match detection
- Phase 5 (Chat): Complete - Real-time messaging
- Phase 6 (Notifications): Complete - FCM integration with deep links
- Phase 7 (Safety): Complete - Block, report, hide profile, delete account
- Phase 8 (Bumble Rules): Complete - Women-message-first, match expiry, extend
- Phase 9 (Premium): Complete - Undo, boost, who liked you, paywall
- Phase 10 (Operations): Complete - Analytics, crash reporting, moderation
