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
- 24 food assets hardcoded in `GrillAssetsProvider.defaultAssets` with PNGs in `assets/images/`

## Adding New Food Icons

**Style**: Flat design, bold saturated colors, light/dark split shading down center vertical axis, no outlines, no text, transparent background, 512x512 RGBA PNG.

**Steps**:

1. **Generate** via Replicate API using `openai/gpt-image-1.5`:
   - `quality`: "high", `background`: "transparent", `output_format`: "png", `aspect_ratio`: "1:1"
   - Prompt template: `"A [food item], flat design food icon for a mobile app, minimal geometric shapes, bold saturated colors, light-dark split shading down the center vertical axis where left half is lighter and right half is darker, no outlines, no text, no labels, no background elements, simple and clean, similar to Flaticon basic flat style, single food item centered, 512x512"`

2. **Trim & resize** — generated images come at 1024x1024 with excess padding:
   ```python
   from PIL import Image
   img = Image.open('icon.png')
   cropped = img.crop(img.getbbox())  # trim transparent padding
   max_dim = max(cropped.size)
   padding = int(max_dim * 0.04)      # ~4% padding to match existing icons
   canvas = Image.new('RGBA', (max_dim + 2*padding,)*2, (0,0,0,0))
   canvas.paste(cropped, ((canvas.width-cropped.width)//2, (canvas.height-cropped.height)//2))
   canvas.resize((512, 512), Image.LANCZOS).save('icon.png', 'PNG', optimize=True)
   ```

3. **Compress**: `pngquant --force --quality=65-80 --output icon.png icon.png` (target: 15-50KB)

4. **Register** in `lib/providers/grill_assets_provider.dart`:
   ```dart
   GrillAsset(image: 'assets/images/icon.png'),
   ```
   No `pubspec.yaml` change needed — `assets/images/` directory is already declared.

## Deployment

- **Web**: GitHub Pages from `docs/` directory, base href `/ultimate_grill_timer/`
- **Android**: Fastlane lanes — `test`, `beta` (Crashlytics), `deploy` (Play Store). Signing key at `/home/josh/Documents/ultimate_grill_timer_digital_key/key.properties`
- **Version format**: `major.minor.patch+buildNumber` in `pubspec.yaml` (currently 1.0.13+14)
