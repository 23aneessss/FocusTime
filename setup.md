# FocusTime Setup Guide

This guide is for the project as it exists now: a real macOS app target plus a widget extension, already wired for shared storage and a first pixel-art UI pass. It is written for a first-time macOS app developer, so the goal is to make the Xcode setup, signing, widget behavior, and project structure feel predictable instead of mysterious.

Keep these two files nearby while you work:

- `FocusTime/Agent/searchReport.md`
- `FocusTime/Agent/prompt.md`

Use the report as the architecture reference and the prompt as the deliverables checklist.

## Current Baseline

Observed from this machine and project:

- Xcode: `26.4`
- macOS: `26.3.1`
- project file: `FocusTime.xcodeproj`
- app target: `FocusTime`
- widget target: `FocusTimeWidget`
- app bundle ID: `com.focustime.FocusTime`
- widget bundle ID: `com.focustime.FocusTime.widget`
- App Group: `group.com.focustime.focustime`
- shared storage choice: `UserDefaults(suiteName:)`

Important note:

- The widget bundle ID is `com.focustime.FocusTime.widget`, not `com.focustime.FocusTimeWidget`.
- That is intentional. The embedded widget extension bundle identifier needs to stay prefixed by the parent app bundle identifier so packaging and signing work correctly.

## Before You Start

You should have:

- full Xcode installed, not only Command Line Tools
- an Apple account added in Xcode
- a selected signing team that can build apps with a widget extension and App Groups

Why the team matters:

- the main app can often build with fewer issues
- widget extensions and App Groups are stricter because of entitlements
- if your team cannot use App Groups, the app and widget will not share data correctly

## Quick Glossary

`target`
: one buildable unit in Xcode. Here, the app and the widget are separate targets.

`scheme`
: the thing you select in the Xcode toolbar when you choose what to run or build.

`App Group`
: a shared container/identity that lets the app and widget access the same local storage.

`widget extension`
: the separate target that builds the WidgetKit widget.

`bundle identifier`
: the unique identifier for a target, such as `com.focustime.FocusTime`.

`signing`
: Apple’s process that ties the app to your selected team and its entitlements.

## Part 1: Open The Project

1. Open `FocusTime.xcodeproj` in Xcode.
2. Wait for indexing to finish.
3. In the top toolbar, confirm the selected scheme is `FocusTime`.
4. Confirm the run destination is `My Mac`.
5. Build once before changing anything.

If this first build fails, fix signing before you move on. It is much easier to debug one problem at a time than to mix signing issues with widget or App Group issues.

## Part 2: Understand The Current Project State

The project already contains the first real FocusTime implementation.

What exists now:

- a floating timer app window with hidden title bar styling
- a shared data layer under `FocusTime/Shared/`
- a settings window for durations, sound, reduce motion, and window corner
- a `FocusTimeWidget` extension that reads the same shared data
- App Group entitlements on both targets

What is still intentionally lightweight:

- no external pixel font is bundled yet
- no bitmap art pack is bundled yet
- `LSUIElement` is not turned on

So the right mental model is:

- this is a usable v1 implementation
- it is also a base for later visual polish

## Part 3: Check Signing And Bundle Identifiers

Do this before running the app and before trying the widget.

1. Click the project file in Xcode.
2. Select the `FocusTime` target.
3. Open `Signing & Capabilities`.
4. Make sure a team is selected.
5. Repeat for `FocusTimeWidget`.

Current identifiers:

- app: `com.focustime.FocusTime`
- widget: `com.focustime.FocusTime.widget`

If Xcode says the IDs are not available for your team:

1. Change the app bundle ID to your own version, such as `com.yourname.FocusTime`.
2. Change the widget bundle ID so it stays prefixed by the app bundle ID, such as `com.yourname.FocusTime.widget`.
3. Keep the relationship consistent across Debug and Release if Xcode shows both.

Do not rename only one of them and leave the other behind.

## Part 4: Verify App Groups

Both targets should already be wired to the same App Group.

To verify:

1. Open `Signing & Capabilities` for `FocusTime`.
2. Confirm `App Groups` is present.
3. Confirm the group is `group.com.focustime.focustime`.
4. Repeat the same check for `FocusTimeWidget`.

If your team requires you to use a different group string:

1. Change the App Group in both targets.
2. Update the matching constant in `FocusTime/Shared/Keys.swift`.
3. Rebuild the project.

The app and widget must use the exact same App Group string or shared data will silently fail.

## Part 5: Understand The Shared Storage Path

The project already chose one storage strategy from the report:

- App Group `UserDefaults(suiteName:)`

That choice lives in `FocusTime/Shared/DataStore.swift`.

What is stored there:

- focus duration
- break duration
- sound toggle
- reduce motion toggle
- preferred window corner
- today’s focus seconds
- today’s session count
- streak
- active timer phase

The day model follows the report’s local-day keyed structure using `YYYY-MM-DD` keys.

If you are new to macOS development, keep this strategy for now. It is simpler than moving to a shared JSON file too early.

## Part 6: Build And Run The App

1. Select the `FocusTime` scheme.
2. Press `Run`.
3. Let the app launch on your Mac.

What you should see:

- a small floating utility-style timer window
- a segmented pixel ring
- a soft sky/cloud background
- focus/break timer controls
- a settings button in the top area

Expected behavior:

- the window stays Dock-visible in this version
- the window defaults to the top-right corner
- changing the preferred corner in Settings repositions the window
- focus progress is saved periodically while the timer runs

## Part 7: Understand The Widget Target

The widget target already exists. You do not need to create it from scratch unless you choose to rebuild the project manually later.

Relevant files:

- `FocusTimeWidget/FocusTimeWidget.swift`
- `FocusTimeWidget/Provider.swift`
- `FocusTimeWidget/Entry.swift`
- `FocusTimeWidget/WidgetView.swift`
- `FocusTimeWidget/WidgetDataStore.swift`

The widget is intentionally conservative:

- it shows today’s focus time, sessions, streak, and a compact ring
- it refreshes on a coarse timeline
- the app requests widget reloads only on meaningful events
- it is not a live per-second timer

That matches the WidgetKit guidance captured in `searchReport.md`.

## Part 8: Add The Widget On macOS

1. Build and run the app at least once.
2. Open the macOS widget picker.
3. Find `FocusTime`.
4. Add the widget to your desktop or widget area.

Then validate shared data:

1. Start a focus session in the app.
2. Pause, reset, or complete a session.
3. Confirm the widget eventually reflects the shared values for:
   - today focus time
   - sessions
   - streak

If the widget looks stale, remember that WidgetKit is budgeted. A short delay is normal.

## Part 9: Add Pixel Assets Or A Pixel Font Later

The current first pass is code-drawn, so external assets are optional right now.

If you want to add real pixel art later:

1. Put the images in `FocusTime/Assets.xcassets`.
2. Export at integer-friendly scales, usually `@2x`.
3. Render them with `.interpolation(.none)`.
4. For especially crisp sprite edges, also consider `.antialiased(false)`.

If you want to add a bundled pixel font later:

1. Add the `.ttf` file to the Xcode project.
2. Make sure target membership includes the app.
3. Include the widget too if the widget should use the same font.
4. Keep the fallback logic in `FocusTime/Shared/Theme.swift`.

Do not remove the fallback until you confirm the font is loading correctly in both targets.

## Part 10: Optional `LSUIElement` Mode

`LSUIElement` is the Info.plist setting that makes a macOS app behave like an agent app without a Dock icon.

For this project, treat it as optional and not as your first setup step.

Why it is not enabled by default:

- it makes the app easier to lose if you are still debugging launch behavior
- it can be confusing for a first macOS project
- the current window and settings flow are easier to verify while the app still behaves like a normal app

If you decide to try it later:

1. Add the `LSUIElement` key to the app’s Info settings.
2. Set it to `YES`.
3. Make sure you still have a reliable way to reopen or quit the app.

Only do this after the main workflow is stable.

## Troubleshooting

### Signing fails

Check these first:

1. Make sure both `FocusTime` and `FocusTimeWidget` have a selected team.
2. Make sure the bundle identifiers are unique for your team.
3. Make sure the widget bundle ID is still prefixed by the app bundle ID.
4. Clean the build folder and build again.

### App Group looks enabled but the widget does not share data

Check:

1. Both targets use the exact same App Group string.
2. `FocusTime/Shared/Keys.swift` matches the App Group you enabled in Xcode.
3. You did not change only the Xcode capability and forget the code constant.
4. Both targets still point at their entitlement files.

### Widget does not refresh

Check:

1. The app was run at least once after the latest build.
2. The widget was removed and re-added after major entitlement or bundle-ID changes.
3. You are not expecting per-second updates.
4. The app is actually writing meaningful shared changes such as session completion or reset.

### Font or pixel assets do not render correctly

Check:

1. Images are in `Assets.xcassets`.
2. Pixel images are shown with `.interpolation(.none)`.
3. The font file is included in the correct target membership.
4. The fallback in `FocusTime/Shared/Theme.swift` still exists.
5. You are not scaling tiny art to arbitrary non-integer-looking sizes.

### macOS blocks the app outside Xcode

If you move a local development build outside Xcode, Gatekeeper may warn about it.

If you trust the build:

1. Open `System Settings`.
2. Go to `Privacy & Security`.
3. Find the blocked app message.
4. Choose `Open Anyway`.

That is normal for local, non-notarized development builds.

## Useful Files To Learn From

- `FocusTime/Shared/Keys.swift` - app group ID, widget kind, default timing values
- `FocusTime/Shared/DataStore.swift` - shared persistence and widget snapshot logic
- `FocusTime/FocusTimerViewModel.swift` - timer state machine and checkpoint writes
- `FocusTime/AppDelegate.swift` - floating window behavior and corner positioning
- `FocusTimeWidget/Provider.swift` - conservative widget timeline strategy

## Build And Verify Checklist

1. Build the `FocusTime` scheme.
2. Run the app.
3. Open Settings and change a duration or corner.
4. Start and pause the timer.
5. Add the widget.
6. Confirm the widget reflects shared stats after meaningful changes.
7. If signing changed, verify both targets and the App Group again.
