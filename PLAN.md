# Dating App Build Plan

## Product Direction
- Target platform: Android first, built with Flutter.
- Product style: Tinder-like MVP first, then add Bumble-style rules as an upgrade module.
- Delivery strategy: split work into small modules that can be built, reviewed, and tested independently.

## Tech Stack
- Frontend: Flutter
- State management: Riverpod
- Routing: GoRouter
- Backend for MVP: Firebase Auth, Firestore, Storage, Cloud Functions, FCM
- Local utilities: Freezed/JSON serialization can be added after the base app is stable

## Delivery Rules
- Finish one module at a time and keep the app runnable after each module.
- Each module must define scope, screens, data, logic, dependencies, and done criteria.
- Do not start premium, AI matching, or video features before the core dating flow is stable.

## Module Roadmap

### Module 1 - Foundation
Goal: Create a production-ready Flutter base project.

Scope:
- Initialize Flutter Android app
- Add base folder structure
- Configure theme, app shell, routing, and environment placeholders
- Add reusable UI tokens and starter screens

Deliverables:
- Flutter app boots successfully on Android
- `lib/` follows feature-first structure
- App has starter home screen and navigation shell

Done when:
- `flutter analyze` passes or only has known external warnings
- `flutter test` passes
- App runs and shows branded starter UI

### Module 2 - Authentication
Goal: Let users sign in and persist session.

Scope:
- Firebase setup
- Phone OTP and/or Google sign-in
- Session restore, logout, auth guard

Screens:
- Splash
- Sign in
- OTP verification

Done when:
- New and returning users can enter the app correctly

### Module 3 - Onboarding And Profile
Goal: Collect the minimum dating profile.

Scope:
- Basic info: name, DOB, gender, interested in
- Bio, school, job
- Photo upload flow
- Location permission and profile completeness

Screens:
- Welcome flow
- Profile editor
- Photo uploader

Done when:
- User cannot enter discovery without a complete profile

### Module 4 - Discovery Feed
Goal: Show swipe candidates.

Scope:
- Candidate fetch pipeline
- Filters: age, distance, gender
- Swipe cards and empty state

Screens:
- Discovery screen
- Filter modal

Done when:
- Users can like/pass and do not see already-swiped profiles again

### Module 5 - Match Engine
Goal: Create matches on mutual likes.

Scope:
- Mutual like detection
- Match creation
- Match list
- Match celebration popup

Done when:
- One mutual like pair creates exactly one match record

### Module 6 - Chat
Goal: Enable post-match messaging.

Scope:
- Chat list
- Conversation screen
- Realtime text messages
- Unread/seen basics

Done when:
- Only matched users can exchange messages

### Module 7 - Notifications
Goal: Bring users back into the app.

Scope:
- New match notifications
- New message notifications
- Deep links into match/chat screens

Done when:
- Notifications work in foreground and background cases

### Module 8 - Safety
Goal: Provide minimum trust and moderation tools.

Scope:
- Block user
- Report user
- Hide profile
- Delete account

Done when:
- Blocked users stop appearing in discovery, match, and chat flows

### Module 9 - Bumble Rules
Goal: Add Bumble-style interaction rules.

Scope:
- Women-message-first rule
- Match expiry timer
- Extend match action

Done when:
- Message actions obey the selected Bumble logic

### Module 10 - Premium
Goal: Add monetization-ready features.

Scope:
- Undo
- Boost
- Who liked you
- Premium gating and paywall

Done when:
- Feature access changes correctly between free and premium users

### Module 11 - Operations And Scale
Goal: Prepare the product for growth.

Scope:
- Analytics events
- Crash reporting
- Moderation dashboard hooks
- Performance review
- Basic anti-spam rules

Done when:
- Team can monitor usage, bugs, and abuse patterns

## Suggested Build Sequence
1. Module 1 - Foundation
2. Module 2 - Authentication
3. Module 3 - Onboarding And Profile
4. Module 4 - Discovery Feed
5. Module 5 - Match Engine
6. Module 6 - Chat
7. Module 7 - Notifications
8. Module 8 - Safety
9. Module 9 - Bumble Rules
10. Module 10 - Premium
11. Module 11 - Operations And Scale

## Current Execution Plan
Module 1 and Module 2 are complete. Ready to start Module 3.

Module 2 completed:
- Auth state, repository abstraction, session restore
- Route guards with splash and sign-in redirects
- Sign-in (Google + Phone OTP), verification, sign-out
- Phone number validation and normalization
- OTP resend with 60s cooldown
- Firebase-swappable repository pattern

## Notes For Later Modules
- Firebase project wiring should be done in Module 2.
- Discovery, matching, and chat models should be added only after auth/profile basics exist.
- Bumble-specific logic should remain isolated so the Tinder-like MVP stays simple.
