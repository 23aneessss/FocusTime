# FocusTime macOS App Generation Prompt Research Report

## Executive summary

This report designs a paste-ready, “agentic” Codex prompt that instructs an AI coding model to generate a complete offline macOS app named **FocusTime** with a pixel-art theme, built using **Swift + SwiftUI + AppKit**, plus a connected **WidgetKit** widget for daily focus stats. It also specifies the project structure (main app target + widget extension + shared App Group), MVVM architecture, shared storage keys and schema, window behavior (floating, fixed-size, hidden title bar, optional Dock-less agent mode), pixel-art rendering techniques (nearest-neighbor interpolation, anti-aliasing control, @2x assets), and WidgetKit timeline/refresh constraints and strategies. citeturn4search0turn4search3turn0search1turn0search12turn3search1

Key recommendations:

- Treat the prompt like a build specification: demand **file-by-file output**, strict compilation targets, and “no placeholders,” as recommended by entity["organization","OpenAI","ai research company"]’s Codex prompting guidance. citeturn4search0turn4search3turn4search6  
- Use an **App Group** and either **UserDefaults(suiteName:)** or a JSON file in the **shared container**; widgets can’t directly read the main app’s sandbox. citeturn0search1turn7search2turn2search2turn0search29  
- Design widget refresh around **WidgetKit budgets** and **timeline policies** (e.g., entries ≥ ~5 minutes); refresh via `WidgetCenter.reloadAllTimelines()` only on meaningful changes. citeturn2search1turn0search4turn0search8turn0search16  
- Enforce pixel-art crispness using **`.interpolation(.none)`**, optional **`Image.antialiased(false)`**, and **proper asset catalog management** with high-resolution resources. citeturn0search6turn9search12turn8search0turn8search7turn8search2  

Assumptions: You have a Mac; your Xcode version and Swift toolchain are not fixed (prompt requests “use the installed toolchain”); the app is offline-first and personal (no CI/CD required). citeturn1search10turn1search1turn1search0  

## Product scope and target platform

**App name:** FocusTime (bundle name: `FocusTime`, widget kind: `FocusTimeWidget`).  

**Goals (MVP):**  
FocusTime is a small, floating Pomodoro-style timer that feels like a “desktop widget” but is a real app window: start/pause/reset focus sessions, persist daily totals (seconds), session count, and a streak, and expose those stats in a WidgetKit widget. The system should work entirely offline, using only on-device storage. citeturn3search10turn0search20turn7search3  

**Target platform:** macOS only. (WidgetKit supports macOS; availability is documented on WidgetKit pages.) citeturn0search20turn0search8  

**Non-goals (explicit):** cloud sync, accounts, web APIs, analytics, push notifications, DevOps pipelines. (This constraint matters because WidgetKit refresh can be triggered by network events, but FocusTime must not depend on them.) citeturn0search16turn2search1  

## Toolchain, versions, and minimal Xcode requirements

### Swift and SwiftUI versioning when unspecified

In practice, the “version” of SwiftUI and the macOS SDK is determined by the installed Xcode (and its bundled SDKs). Therefore, the Codex prompt should require: “Use the **installed** Swift toolchain and SDK; avoid APIs that require a newer OS unless guarded by availability checks.” citeturn1search10turn3search17turn3search12  

### Xcode: what is minimally required

Even if you write SwiftUI code in another editor, you typically need Xcode (or at least its command-line toolchain) to build Apple-platform app targets. Apple documents both Xcode’s role in building/running apps and the availability of command-line tooling. citeturn1search6turn1search10turn1search1  

Minimal practical requirements for FocusTime (app + widget extension):

- **Full Xcode installation** is the simplest path because widget extensions, app signing, and entitlements (App Groups) are integrated into Xcode target configuration. citeturn1search6turn0search1turn0search29  
- You can still automate builds using **`xcodebuild`**, Apple’s command-line build tool for Xcode projects, after installing Xcode. citeturn1search0turn1search8  
- You can install **Xcode Command Line Tools** if you “work outside of Xcode,” but a WidgetKit + SwiftUI macOS app is easiest when driven by an Xcode project. citeturn1search1turn1search10turn0search20  

Practical prompt instruction: “Generate an Xcode project (or at least a complete file tree that can be dropped into a new Xcode project), including both targets and entitlements configuration steps.” citeturn1search6turn0search1turn0search29  

## Project structure, MVVM architecture, and data model

### Target layout and shared group

The prompt should require a canonical Apple-style multi-target layout:

- **FocusTime app target** (SwiftUI App lifecycle + AppKit window behaviors). citeturn10search20turn6search0turn0search3  
- **FocusTimeWidget extension** (WidgetKit timeline provider + SwiftUI widget view). citeturn0search20turn2search10turn0search8  
- **Shared group** (App Group entitlement + shared storage code in a shared folder/Swift package). citeturn0search1turn0search29turn2search2  

Apple’s App Groups documentation defines the shared container concept and how multiple apps/targets can access it when in the same group. citeturn0search1turn0search29  

### MVVM: code organization expectations

Because this is a timer + stats app, MVVM is a good fit:

- **Model**: daily aggregates, settings, and persistence representation.  
- **ViewModel**: timer state machine (running/paused), session completion logic, persistence writes, widget refresh triggers.  
- **Views**: Pixel UI, timer ring, settings UI, widget UI.  

SwiftUI’s data flow guidance and the modern Observation framework support reactive updates as model state changes; the prompt can either use Observation (preferred on newer toolchains) or `ObservableObject` for maximum compatibility. citeturn10search14turn10search2turn10search1  

### Files to generate (explicit list)

Your Codex prompt should enforce these files (plus any necessary helpers), because Codex performs best when constraints are concrete and verifiable. citeturn4search0turn4search3turn4search6  

Required app files:

- `FocusTimeApp.swift` (SwiftUI entry point, scenes, settings scene). citeturn10search20turn10search0  
- `AppDelegate.swift` (via `@NSApplicationDelegateAdaptor`, configures window level/position/behavior at launch). citeturn6search0turn6search2turn0search11  
- `ContentView.swift` (root view; hosts timer UI and “mini widget-like” chrome).  
- `TimerView.swift` (main timer controls, time display).  
- `PixelRingView.swift` (segmented pixel progress ring algorithm).  
- `PixelBackgroundView.swift` (cloud parallax + day/night tint).  
- `SettingsView.swift` (durations, sound toggle, corner placement, LSUIElement toggle note). citeturn10search0turn10search8turn10search1  
- `DataStore.swift` (persistence, App Group wiring, JSON schema). citeturn7search2turn2search2turn0search1  
- `FocusTimerViewModel.swift` (MVVM timer logic; writes stats; triggers widget reload). citeturn0search4turn5search6turn5search4  

Required widget files (extension target):

- `FocusTimeWidget.swift` (widget configuration + supported families). citeturn0search20  
- `Provider.swift` (TimelineProvider). citeturn0search8turn2search10  
- `Entry.swift` (timeline entry model struct). citeturn2search10  
- `WidgetView.swift` (pixel-style widget UI consuming shared data).  
- `WidgetDataStore.swift` (reads shared storage; lightweight parsing). citeturn7search2turn2search2  

### Data model: daily seconds, sessions, streaks

A simple, robust offline model is a day-keyed aggregate:

- `dailySeconds[YYYY-MM-DD] = Int`  
- `dailySessions[YYYY-MM-DD] = Int`  
- `streak = Int` (computed or cached)  

The prompt should specify a deterministic day boundary definition (local calendar day), and require “write updates at session end and optionally periodic checkpoints (e.g., every 60s) to prevent data loss.” (This is an architectural requirement; persistence is via UserDefaults or a file.) citeturn7search3turn7search23turn2search2  

#### JSON schema (recommended for file-based or debugging)

Even if you store in UserDefaults, defining a JSON schema in the prompt makes expectations testable and helps avoid ad-hoc keys.

Example schema to require in generation:

- File name (if file-based): `focus_stats.json` in the App Group container. citeturn2search2turn2search11  
- JSON structure:

```json
{
  "schemaVersion": 1,
  "days": {
    "2026-03-28": { "seconds": 5400, "sessions": 3 },
    "2026-03-27": { "seconds": 7200, "sessions": 4 }
  },
  "streak": 5,
  "lastUpdatedISO8601": "2026-03-28T18:40:00Z"
}
```

Rationale: App Groups provide a shared container, and Apple documents retrieving the container URL using `FileManager.containerURL(forSecurityApplicationGroupIdentifier:)`. citeturn2search2turn2search11turn0search1  

### App Group setup and UserDefaults keys

**Entitlement:** `com.apple.security.application-groups` (App Groups entitlement). citeturn0search29turn0search1  

**Shared group identifier example:** `group.com.<yourname>.focustime` (the exact string must match across targets). Apple’s App Groups documentation describes using the shared container for multiple apps/extensions developed by the same team. citeturn0search1turn0search29  

**UserDefaults(suiteName:)**: Apple explicitly documents that to read and write settings for a shared app group you specify the app group identifier in `UserDefaults.init(suiteName:)`. citeturn7search2turn7search3  

Recommended keys (if using direct keys rather than JSON blob):

- `ft.schemaVersion` (Int)  
- `ft.days.<YYYY-MM-DD>.seconds` (Int)  
- `ft.days.<YYYY-MM-DD>.sessions` (Int)  
- `ft.streak` (Int)  
- `ft.lastUpdated` (Double timestamp or ISO string)  

Prompt requirement: “Provide a single source of truth key namespace (`ft.` prefix) and centralize keys in one file (e.g., `Keys.swift`) to avoid drift.” This directly supports maintainability and reduces extension/app mismatch errors. citeturn7search3turn0search8turn0search1  

### Storage options comparison table (required)

| Option | How it works with App Group | Pros | Cons | Recommended use in FocusTime |
|---|---|---|---|---|
| **UserDefaults (suiteName)** | Both targets access `UserDefaults(suiteName: appGroupID)` | Simple, fast, perfect for small key-value data; Apple docs explicitly support app-group reading/writing this way | Not ideal for complex histories; risk of scattered keys unless centralized | Best for MVP; store today’s totals + a small rolling history citeturn7search2turn7search3 |
| **JSON file in shared container** | App writes a single JSON file to `FileManager.containerURL(...)`; widget reads it | Easy to debug; atomic “single read” for the widget; extensible schema | Need file I/O, atomic writes, error handling; concurrency concerns | Strong choice if you want history + charts soon citeturn2search2turn2search11turn2search5 |
| **Core Data in shared container** | Put SQLite store file in App Group container by setting store URL before loading | Great for long history, queries, charts; Apple documents Core Data stack concepts and persistent store configuration | Higher complexity; migration overhead; must set store description URL correctly | Overkill for MVP; consider for v2 analytics citeturn7search1turn7search0turn7search10 |

## Pixel-art UI system, assets, fonts, and the pixel ring algorithm

### Pixel-art UI approach (hybrid: macOS utility + pixel identity)

Your desired UX is “small utility window” with a stylized pixel theme—best implemented as a SwiftUI layout (for portability and speed) plus selective immediate-mode drawing for crisp shapes and animations. SwiftUI’s drawing systems include `Canvas`, `Shape`, and `Path`. citeturn5search0turn5search3turn5search1  

image_group{"layout":"carousel","aspect_ratio":"1:1","query":["pixel art pomodoro timer UI","pixel art circular progress ring UI","pixel art clouds parallax background UI","pixel art desktop widget timer"],"num_per_query":1}

### Pixel asset handling: crisp scaling on Retina

SwiftUI provides an interpolation API on images, including `.interpolation(.none)`, which is essential for “nearest-neighbor-like” crispness when scaling pixel art. citeturn0search6turn8search14  

Additionally, SwiftUI lets you control anti-aliasing for images via `Image.antialiased(_:)`, which can reduce unwanted smoothing at edges. citeturn9search12  

Your prompt should require these rules for pixel assets:

- All pixel-art `Image(...)` must set: `.resizable().interpolation(.none)` and optionally `.antialiased(false)` for sprite-like elements. citeturn0search6turn9search12  
- Use an asset catalog (`.xcassets`) and add images via Xcode’s documented workflow; this ensures correct bundling and scale handling. citeturn8search0turn8search7  
- Supply high-resolution assets “for all bitmap images” as recommended by Apple’s Human Interface Guidelines (HIG). For pixel art, that often means designing at a base grid and exporting at integer multiples (commonly @2x) while keeping logical point sizes constant. citeturn8search2turn8search7  

### Pixel font inclusion and fallback

Apple provides explicit guidance on applying custom fonts in SwiftUI: include the font file in the project and apply it with `.font(.custom(...))`. citeturn0search2  

Prompt requirements should include:

- Add a bundled pixel font (e.g., `PressStart2P-Regular.ttf` or another permissively licensed pixel font you supply) and register it for the app target and widget target as needed. citeturn0search2  
- Provide a fallback to system fonts if the custom font fails to load (important for robustness). SwiftUI’s font system supports dynamic selection and defaults. citeturn0search26  

### Pixel progress ring algorithm (segmented rectangles)

A “pixel ring” is best modeled as **N segments**, each a small rectangle rotated around the center; progress is represented by how many segments are “lit.”

Implementation strategy the prompt should mandate:

- Choose segment count `N` (e.g., 60 or 100).  
- For each segment index `i`, compute `angle = 2π * i / N`.  
- Place a rectangle at radius `r` from the center and rotate by `angle`.  
- Fill segments `i < floor(progress * N)` with active color; others with inactive color.  
- Keep edges crisp by using integer-aligned sizes where possible and avoiding fractional scaling.  

SwiftUI supports building such drawings via composed views (`ForEach` of rectangles) or more efficiently using `Canvas` for immediate-mode rendering when you want fine control and performance. citeturn5search0turn5search3turn5search17  

### Subtle animations: cloud parallax and day/night

For non-distracting animation, SwiftUI’s `TimelineView` can drive time-based visual updates (e.g., slow cloud drift) without heavy timers. Apple documents `TimelineView` as a view that updates on a schedule. citeturn5search8turn5search11  

Prompt requirements:

- Use a low refresh cadence for ambient motion (e.g., 10–30 FPS is unnecessary; slow drift can be updated less frequently).  
- Day/night mode can be tied to local time or a setting toggle, and can be implemented as a tint overlay layer over the pixel background.  
- Use `Canvas` or layered `Image` views; group complex content using `drawingGroup` only when necessary, because it flattens rendering and may affect performance. citeturn5search0turn9search1turn9search19  

## WidgetKit timeline, refresh budgets, and update strategy

### How widget timelines work

WidgetKit uses a **timeline** produced by a `TimelineProvider`. The timeline contains entries and a refresh policy that tells WidgetKit when to request a new timeline. Apple documents the `Timeline` object and the role of `TimelineProvider`. citeturn2search10turn0search8turn0search20  

### Refresh calls from the app

Your app can request updated widget timelines using `WidgetCenter`, including `reloadAllTimelines()` or `reloadTimelines(ofKind:)`. Apple documents both calls. citeturn0search4turn2search4turn0search0  

However, Apple also documents that WidgetKit enforces constraints on update frequency: there’s a minimum time before reloads (guidance suggests timeline entries “at least about 5 minutes”), and updates are budgeted. citeturn2search1turn0search12  

Therefore the prompt must require:

- Trigger `WidgetCenter.shared.reloadAllTimelines()` only after a meaningful state change (e.g., completing a session, manual reset, settings that affect widget output). citeturn0search16turn0search4  
- The widget timeline provider should generate entries with a conservative cadence (e.g., update “today’s focus time” every 15–60 minutes, plus immediate refresh after session completion). citeturn2search1turn2search10  

### Widget update strategy table (required)

| Strategy | Mechanism | Pros | Cons / constraints | Best for FocusTime |
|---|---|---|---|---|
| **Timeline entries (periodic)** | Provider returns entries across the day + policy `.atEnd` / `.after(date)` | Predictable, battery-friendly; works offline | WidgetKit enforces minimum reload spacing; too-frequent entries may be ignored | Baseline: update at coarse intervals (e.g., hourly) citeturn2search10turn2search1 |
| **Event-driven reload (recommended)** | App calls `WidgetCenter.reloadAllTimelines()` when session completes | Widget reflects real progress soon after key events | Still subject to WidgetKit budgeting; shouldn’t be spammed | Primary: reload when focus session ends or user resets day citeturn0search4turn0search16turn2search1 |
| **Always-fresh illusion (not allowed)** | Trying to update every minute/second | Would match a live timer | Not supported; WidgetKit is glanceable and budget-limited | Avoid; keep “live timer” inside the app window citeturn2search1turn0search12 |

## Window behavior, accessibility/localization, testing, and local installation

### Window behaviors for “widget-like” app feel (but it’s a real app)

SwiftUI supports macOS window styling:

- `HiddenTitleBarWindowStyle` hides title and title bar backing. citeturn3search1turn3search5  
- `windowResizability(.contentSize)` constrains the window size based on content. citeturn3search0turn3search8  
- `defaultSize(width:height:)` sets an initial default size for new windows. citeturn3search2  

For floating and precise placement, you need AppKit:

- Use `@NSApplicationDelegateAdaptor` to connect an `NSApplicationDelegate` in a SwiftUI lifecycle app. citeturn6search0turn6search1  
- Configure window level via `NSWindow.Level` to keep the timer above normal windows when desired (e.g., `.floating`). Apple documents window “levels” and their stacking behavior. citeturn0search11turn0search27  
- Place the window using `NSScreen.visibleFrame` and `NSWindow.setFrame(_:display:)` to position top-right/top-left and avoid the menu bar/dock areas. citeturn3search3turn3search7  
- Optionally make it appear across Spaces using `NSWindow.CollectionBehavior.canJoinAllSpaces`. citeturn6search3turn6search9  

### Optional: LSUIElement (agent app mode)

If you want FocusTime to **not appear in the Dock**, Apple documents `LSUIElement` as a boolean Info.plist key indicating the app is an agent app that runs in the background and doesn’t appear in the Dock. citeturn1search2turn1search4  

Prompt guidance: make LSUIElement **optional** behind a build setting or documented edit, because Dock-less apps can be confusing to quit/manage unless you also provide a menu bar item or an always-visible window. citeturn1search2turn1search4  

### Accessibility and localization (languages unspecified)

Accessibility is not automatic for custom pixel controls. Apple documents SwiftUI accessibility modifiers and fundamentals, including adding labels and values for assistive technologies. citeturn2search12turn2search20turn2search24  

Prompt requirements:

- Every tappable control (start/pause/reset) must have `accessibilityLabel` and the timer value should expose `accessibilityValue` (e.g., “Time remaining: 12 minutes, 30 seconds”). citeturn2search20turn2search16  
- Respect increased contrast and reduce motion settings by softening animations or allowing disabling parallax in Settings. (This is consistent with Apple accessibility intent for inclusive UI.) citeturn2search12turn2search24  
- For localization, structure strings as localizable SwiftUI text. Apple documents preparing SwiftUI views for localization. citeturn2search3  
- If using modern Xcode, implement localization through **String Catalogs** (Apple recommends them in recent Xcode releases, though some documentation pages may require JavaScript in web views). citeturn2search0turn2search6turn2search13  

### Testing steps (build, run, sign, allow unsigned)

For local development:

- Build and run from Xcode (standard workflow). citeturn1search6turn1search10  
- If you export/copy the `.app` to `/Applications`, macOS Gatekeeper may warn if the app isn’t notarized or is from an “unknown developer.” Apple provides steps to open such apps via Privacy & Security (“Open Anyway”). citeturn1search3turn1search5  

Prompt requirement: generate a `README.md` that includes (a) how to build/run from Xcode, (b) how to enable App Groups, and (c) how to open the app if macOS blocks it. citeturn0search1turn1search3turn1search6  

## The Codex prompt template for generating the full app

### Why the prompt must be “agentic” and file-ordered

Codex works best when you provide explicit structure, constraints, and validation steps—OpenAI’s Codex prompting guidance emphasizes giving the model context, specifying conventions, and making outputs structured and checkable (including multi-file work). citeturn4search0turn4search3turn4search6turn4search15  

Accordingly, your prompt should:

- Force a **file-by-file generation order**.  
- Require compilation success checks and “no TODO placeholders.”  
- Require a final summary: what was created, how to run, how to verify widget updates. citeturn4search3turn4search2turn4search6  


### Example code snippets to demand (validation anchors)

Codex prompts are more reliable when you include “anchor requirements” that are easy to verify during review. Suggested anchors:

1) App Groups via UserDefaults suite initialization (Apple-documented behavior): citeturn7search2  
- Require you see something like `UserDefaults(suiteName: "group.com...")`.

2) Widget refresh API call (Apple-documented): citeturn0search4  
- Require `WidgetCenter.shared.reloadAllTimelines()` inside “session completed” logic.

3) Pixel interpolation disabled (Apple-documented): citeturn0search6  
- Require `.interpolation(.none)` on pixel images.

4) Hidden title bar window style (SwiftUI-documented): citeturn3search1  
- Require `.windowStyle(.hiddenTitleBar)` or `HiddenTitleBarWindowStyle()`.

### Iterative refinement prompts (practical follow-ups)

OpenAI’s prompting best practices encourage iterative refinement: start, review output, then tighten constraints. citeturn4search2turn4search7  

Here are focused follow-up prompts (each assumes the codebase exists):

**Refine the pixel ring**
```text
Improve PixelRingView to avoid uneven segment spacing on resizing.
Keep segment count configurable, ensure segments remain crisp on Retina, and add a subtle “pulse” animation only when running.
Do not change external APIs of the view.
```

**Widget timeline correctness under budgets**
```text
Audit Provider.swift: ensure timeline entries are not more frequent than WidgetKit guidance (~5 minutes minimum).
Use a conservative schedule and rely on WidgetCenter.reloadAllTimelines() only on session completion.
Explain the chosen TimelineReloadPolicy in comments.
```
(WidgetKit enforces minimum reload timing and budgeting.) citeturn2search1turn0search12turn2search10  

**Window positioning corner selection**
```text
Add a setting (top-right, top-left, bottom-right, bottom-left). On change, reposition the NSWindow using NSScreen.visibleFrame.
Ensure it respects macOS Dock/menu bar safe area.
```
(Uses `visibleFrame` and `setFrame` per AppKit docs.) citeturn3search3turn3search7  

**Accessibility pass**
```text
Add accessibilityLabel/accessibilityValue to all buttons and to the timer display.
Ensure VoiceOver announces remaining time and running/paused state clearly.
```
