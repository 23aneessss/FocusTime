# FocusTime

FocusTime is an offline macOS Pomodoro utility built as a small floating timer window with a pixel-art visual direction and a connected WidgetKit widget. The app is written in SwiftUI, uses AppKit where macOS window behavior needs more control, and shares local stats with the widget through an App Group backed by `UserDefaults(suiteName:)`.

The architecture and design direction for this repo still come from the agent docs in `FocusTime/Agent/`, especially `searchReport.md` for the implementation decisions and `prompt.md` for the intended file layout and delivery order.

## Current Status

This repository is no longer just the starter template.

- The `FocusTime` macOS app target is implemented as a floating utility-style timer window.
- The `FocusTimeWidget` widget extension target is present and builds with the app.
- Shared storage is wired through the App Group `group.com.focustime.focustime`.
- The first visual pass is code-drawn: segmented pixel ring, soft cloud background, focus/break palette, and a font fallback system.
- Settings for durations, sound, reduce motion, and preferred window corner are implemented.

What is still intentionally simple in this first version:

- There is no bundled external pixel font yet; the code prefers one later but currently falls back cleanly to system fonts.
- There are no imported bitmap pixel-art assets yet; the current UI is drawn in code.
- `LSUIElement` agent mode is documented but not enabled by default, so the app still appears in the Dock.

## Implemented Architecture

The current project shape follows the research report closely:

- `FocusTime` app target for timer UI, settings, and window management
- `FocusTimeWidget` widget extension for glanceable daily stats
- `FocusTime/Shared/` for shared models, storage keys, formatting, palette, and the pixel ring
- MVVM-style timer flow through `FocusTimerViewModel`
- App Group storage shared by app and widget

Main implementation areas:

- `FocusTime/FocusTimeApp.swift` and `FocusTime/AppDelegate.swift` handle app lifecycle and floating window behavior
- `FocusTime/FocusTimerViewModel.swift` owns timer state, phase changes, checkpoint writes, and meaningful widget reloads
- `FocusTime/Shared/DataStore.swift` owns shared persistence and widget snapshots
- `FocusTimeWidget/` contains the widget entry, provider, store wrapper, and widget UI

## Design Direction

The visual direction is based on the report and the screenshots in the agent context:

- compact floating utility window rather than a full desktop app layout
- segmented pixel ring instead of a smooth vector progress circle
- crisp retro feeling without shipping external sprite sheets in the first pass
- soft sky and cloud atmosphere with focus/break day-night tint shifts
- centralized palette and typography helpers so the look stays consistent across app and widget

For future asset work, keep following the report’s pixel-art rules:

- put bitmap art in `Assets.xcassets`
- export at integer-friendly sizes, usually `@2x` for Retina
- render pixel images with `.interpolation(.none)` and, when useful, `.antialiased(false)`

## Quick Start

1. Open `FocusTime.xcodeproj` in Xcode.
2. Select the `FocusTime` scheme.
3. Choose `My Mac` as the destination.
4. In `Signing & Capabilities`, pick your Apple team if Xcode asks.
5. Run the app.

What you should see:

- a compact floating timer window
- focus/break timer controls
- settings available through the slider button
- a normal Dock-visible macOS app for this first version

To test the widget:

1. Build and run the app once.
2. Add the FocusTime widget from the macOS widget picker.
3. Change timer state or complete a focus session in the app.
4. Confirm the widget updates on meaningful changes and through its conservative timeline refresh.

For the full beginner-first setup and signing walkthrough, use `setup.md`.

## Bundle IDs And Shared Storage

Current identifiers in the project:

- app bundle ID: `com.focustime.FocusTime`
- widget bundle ID: `com.focustime.FocusTime.widget`
- App Group: `group.com.focustime.focustime`

The widget bundle ID is intentionally prefixed by the app bundle ID because embedded app extensions on macOS must use that relationship to package and sign correctly.

Shared storage choice for v1:

- App Group `UserDefaults(suiteName:)`
- versioned keys under the `ft.` namespace
- local-day aggregates for focus seconds and session counts
- cached streak and last-updated metadata

## Repository Layout

- `FocusTime/` - macOS app source
- `FocusTime/Shared/` - shared models, theme, formatting, data store, and pixel ring
- `FocusTimeWidget/` - widget extension source
- `FocusTime/Agent/searchReport.md` - primary architecture and implementation reference
- `FocusTime/Agent/prompt.md` - prompt-level deliverables and expected file list
- `setup.md` - beginner-first build, signing, widget, and troubleshooting guide

## Source Of Truth

When you need deeper context than the code alone provides:

- use `FocusTime/Agent/searchReport.md` for architecture, App Group behavior, widget refresh strategy, window behavior, and pixel-art implementation rules
- use `FocusTime/Agent/prompt.md` for deliverables, file naming, and generation order

## Build Verification

The project has already been validated with:

- `xcodebuild -project FocusTime.xcodeproj -scheme FocusTime -destination 'platform=macOS' build`
- `xcodebuild -project FocusTime.xcodeproj -scheme FocusTime -destination 'platform=macOS' clean build`

The app bundle also no longer copies `FocusTime/Agent/*.md` into its runtime resources.
