# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Cross-platform Flutter app — "The Ultimate Grill Timer" — for managing multiple cooking timers simultaneously. Deployed to web (GitHub Pages), Android (Google Play via Fastlane), and iOS.

- **Package**: `com.tesseractmobile.ultimate_grill_timer`
- **Live demo**: https://frankjoshua.github.io/ultimate_grill_timer/
- **License**: Apache 2.0

## Common Commands

```bash
# Run
flutter run -d web-server --web-port=8080  # Local web server (http://localhost:8080/ultimate_grill_timer)
flutter run -d chrome          # Web development
flutter run                    # Connected device (Android/iOS)

# Build
flutter build web --release    # Web build → build/web/
flutter build appbundle        # Android release bundle

# Test & Lint
flutter test                   # Run all tests
flutter test test/widget_test.dart  # Single test file
flutter analyze                # Lint (uses flutter_lints)

# Deploy
./deploy.sh                    # Full deploy: increment version → build web → update docs/ → git push → build Android
./increment_version.sh         # Bump patch+build in pubspec.yaml

# Icons
flutter pub run flutter_launcher_icons:main  # Regenerate from assets/icon/icon.jpg
```

**Note**: The `web-server` device does not support hot reload/restart. You must kill the server (`fuser -k 8080/tcp`) and relaunch it to see code changes.

## Architecture

**State management**: Riverpod (`flutter_riverpod`). Providers in `lib/providers/`, consumed via `ConsumerWidget`/`ConsumerStatefulWidget`.

**Persistence**: SharedPreferences via use cases in `lib/use_case/`. `SaveStateWidget` auto-saves on provider changes; `RestoreGrillItemsUseCase` restores on startup.

**Key structure**:

```
lib/
├── main.dart                          # App entry, MaterialApp
├── models/                            # Domain: GrillItem (with flip tracking), GrillTimer (pause/resume), GrillAsset
├── providers/                         # Riverpod: GrillItemsProvider (StateNotifier), GrillAssetsProvider (14 food items)
├── views/                             # UI: TimerList, AddGrillItemButtonRow, InstructionsView
├── managers/                          # TimerManager (250ms refresh), SaveStateWidget (persistence)
└── use_case/                          # Save/restore to SharedPreferences
```

**Widget tree**: `MyApp → TimerManager → MyHomePage → SaveStateWidget → Scaffold` with TimerList, Instructions, and AddGrillItemButtonRow.

**Core interaction flow**: Tap food icon → starts timer → tap same icon again → starts flip timer (tracks second side) → tap timer → pause/resume → swipe → delete.

## Key Patterns

- Models are immutable with `copyWith()`, serializable via `toMap()`/`fromMap()`
- Items synced by millisecond precision so concurrent timers align
- Sorted by `startTime` for consistent ordering
- Paused items render at 25% opacity with pause icon overlay
- 14 food assets hardcoded in `GrillAssetsProvider.defaultAssets` with PNGs in `assets/images/`

## Deployment

- **Web**: GitHub Pages from `docs/` directory, base href `/ultimate_grill_timer/`
- **Android**: Fastlane lanes — `test`, `beta` (Crashlytics), `deploy` (Play Store). Signing key at `/home/josh/Documents/ultimate_grill_timer_digital_key/key.properties`
- **Version format**: `major.minor.patch+buildNumber` in `pubspec.yaml` (currently 1.0.13+14)
