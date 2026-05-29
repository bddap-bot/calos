# Calos — a dead-simple Apple Watch calorie tracker

One screen: today's running calorie total, a focused number field, **Add**, and **Undo**.
Primary story is *open app → type a number → Add*. No macros, no accounts, no fuss.
Totals are stored on-device and roll over to 0 at midnight (history is kept).

## Build & run (needs a Mac)

watchOS apps can only be built/signed on macOS with Xcode — that's an Apple
constraint. The `.xcodeproj` is committed (CI regenerates it from `project.yml`),
so it's clone → open → run:

```sh
open Calos.xcodeproj
```

In Xcode:
1. Select the **Calos** target → **Signing & Capabilities** → pick your Apple ID Team
   (one-time; Apple requires it for install).
2. Choose a destination: an **Apple Watch … Simulator**, or your own watch.
3. **Run** (⌘R).

No paid Apple Developer account is needed for the simulator, or for 7 days on your
own watch with a free personal team. CI compiles every push on a macOS runner, so
master is always in a building state.

> Editing structure (adding files/targets)? Edit `project.yml`; CI regenerates and
> re-commits `Calos.xcodeproj`. Or run `brew install xcodegen && xcodegen generate`
> locally.

## Files
- `Sources/CalosApp.swift` — app entry point.
- `Sources/ContentView.swift` — the single screen (total, entry, Add/Undo).
- `Sources/CalorieStore.swift` — persistence + daily rollover (UserDefaults, per-entry log).
- `project.yml` — XcodeGen target spec (watchOS 10, single-target watch app).

## Notes / easy next steps
- Entry uses the watch's text input; pick the number pad (or dictate "two hundred").
- Want a complication / Smart Stack widget showing today's total? Add a WidgetKit
  extension — say the word.
- Want it to sync to bothouse (so the bot can read your daily intake)? I can add a
  tiny sync endpoint on the server side.
