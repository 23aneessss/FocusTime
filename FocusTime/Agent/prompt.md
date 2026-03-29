ROLE
You are a senior macOS engineer. Generate a complete Xcode project codebase for a macOS app + WidgetKit widget extension.

APP
Name: FocusTime
Platform: macOS only
Offline: 100% offline. No networking, no analytics, no cloud sync.
UI theme: pixel-art / retro (crisp pixels + pixel font + subtle parallax clouds + day/night tint).

HARD REQUIREMENTS
- Use Swift + SwiftUI for UI.
- Use AppKit where needed for window management (floating, corner positioning).
- Include a WidgetKit widget extension that shows today's focus time + sessions + streak, and optionally yesterday.
- Use MVVM: Views are thin; ViewModel holds timer state machine; DataStore persists.
- Shared storage between app and widget MUST use an App Group.
- Shared storage implementation must be one of:
  (A) UserDefaults(suiteName: appGroupID) OR
  (B) JSON file in shared container (FileManager.containerURL(forSecurityApplicationGroupIdentifier:)).
  Choose ONE and implement cleanly with a versioned schema.
- When the app updates stats (session completed, reset day, preference change that affects widget output), call:
  WidgetCenter.shared.reloadAllTimelines()
  BUT do not spam it (only on meaningful events).
- Window must look like a widget but is a real app:
  - Hidden title bar
  - Fixed size (contentSize resizability)
  - Default size around 180x180 (configurable)
  - Always on top (floating level)
  - Positioned to top-right of visibleFrame by default (configurable corner)
  - Optional: window shows on all Spaces
- Optional behavior: document how to enable LSUIElement (agent app / no Dock icon) in Info.plist; do NOT enable it by default.

PIXEL ART RENDERING REQUIREMENTS
- Any pixel images must use .interpolation(.none) (+ optionally .antialiased(false)).
- Include a pixel font (place a .ttf in the project). Apply it, but provide fallback to system font if missing.
- Provide assets recommendations: base grid size, @2x exports for Retina.
- Implement PixelRingView as segmented rectangles around a circle (not a smooth vector ring):
  - N segments (e.g., 60 or 100)
  - "Lit" segments = progress
  - Supports focus + break modes with different colors (no hardcoded global palette; store palette in one place)

FEATURES (MVP)
- Pomodoro presets: Focus 25m, Break 5m (configurable in Settings).
- Controls: Start/Pause, Reset, Skip (optional).
- Notifications: Optional simple sound at session end (no network).
- Stats:
  - dailySeconds[YYYY-MM-DD]
  - dailySessions[YYYY-MM-DD]
  - streak
- Widget:
  - Small widget view: Today focus time, sessions, streak, and a progress ring.
  - Timeline provider that reads shared stats and updates conservatively (don’t attempt per-second updates).

ACCESSIBILITY + LOCALIZATION
- Add accessibility labels/values for controls and timer.
- Localizable strings: avoid hard-coded English; structure for localization (string keys).
- Reduce motion: allow disabling parallax animation in Settings.

DELIVERABLES
Generate the following files EXACTLY (plus any helpers you need). Put shared code in a Shared/ folder used by both targets.

App target files:
- FocusTimeApp.swift
- AppDelegate.swift
- ContentView.swift
- TimerView.swift
- PixelRingView.swift
- PixelBackgroundView.swift
- SettingsView.swift
- FocusTimerViewModel.swift
- DataStore.swift
- Keys.swift
- README.md (setup steps: App Group, build/run, widget usage, troubleshooting Gatekeeper)

Widget extension files:
- FocusTimeWidget.swift
- Provider.swift
- Entry.swift
- WidgetView.swift
- WidgetDataStore.swift

GENERATION ORDER (IMPORTANT)
1) Produce a folder tree of the project.
2) Generate Shared/ code first (Keys.swift, DataStore.swift, models).
3) Generate FocusTimerViewModel.swift.
4) Generate PixelRingView.swift and PixelBackgroundView.swift.
5) Generate TimerView.swift, ContentView.swift, FocusTimeApp.swift, AppDelegate.swift, SettingsView.swift.
6) Generate widget files (Entry, Provider, WidgetView, FocusTimeWidget).
7) Generate README.md last.

QUALITY BAR
- No TODOs, no placeholders.
- Code must compile.
- Use modern Swift concurrency where appropriate, but keep it simple.
- Include brief inline comments explaining non-obvious AppKit/window/widget budget constraints.

OUTPUT FORMAT
For each file:
- Start with: "FILE: <relative path>"
- Then provide the complete contents of the file.
- Do not include any extra commentary between files.
At the end, provide a short “Build & Verify” checklist.

CONSTRAINTS
- Do not use third-party packages.
- Do not require internet.
