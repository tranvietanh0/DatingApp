# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter dating app (Android-first MVP). Tinder-like core with planned Bumble-style rules as an upgrade module. Currently executing Module 2 (Authentication) of an 11-module roadmap defined in PLAN.md.

## Commands

```bash
flutter analyze       # Static analysis
flutter test          # Run all tests
flutter test test/widget_test.dart  # Run single test file
flutter run           # Run on connected device/emulator
flutter pub get       # Install dependencies
```

## Architecture

### Feature-First Structure
```
lib/
  app/              # App-level setup (router, shell, theme)
  core/             # Shared utilities (theme, widgets)
  features/         # Feature modules
    {feature}/
      data/         # Repository implementations
      domain/       # Models, enums, interfaces
      application/  # Controllers, providers
      presentation/ # Pages, widgets
```

### State Management (Riverpod)
- Providers defined in `features/{feature}/application/{feature}_providers.dart`
- Controllers extend `ChangeNotifier` for listenable state
- Auth state is bootstrapped automatically when provider is first read

### Routing (GoRouter)
- Routes defined in `lib/app/router/app_router.dart`
- Auth-aware redirects via `refreshListenable` on `AuthController`
- Pages define static `routeName` and `routePath` constants
- Main app uses `StatefulShellRoute.indexedStack` for bottom nav branches

### Auth Pattern
- Abstract `AuthRepository` allows swapping local stub for Firebase
- `AuthController` manages `AuthStatus` enum states: `initial`, `authenticating`, `unauthenticated`, `authenticated`
- OTP flow tracks `pendingPhoneNumber` for two-step verification
- Session persisted via `SharedPreferences` (local stub)

### Testing
- Override `authRepositoryProvider` with `FakeAuthRepository` for widget tests
- Use `ProviderScope` overrides to inject test dependencies

## Theme
Brand colors defined in `lib/core/theme/app_theme.dart`:
- Primary: coral (#E56B5D)
- Secondary: amber (#F3B562)
- Surface: sand (#F7F1E8)
- Typography: Space Grotesk (headings), DM Sans (body)

## Module Status
- Module 1 (Foundation): Complete
- Module 2 (Authentication): Complete - local stub ready for Firebase swap
- Modules 3-11: Not started (see PLAN.md for roadmap)
