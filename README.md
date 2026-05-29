# Calos — a dead-simple Apple Watch calorie tracker

One screen: today's running calorie total, a focused number field, **Add**, and **Undo**.
Primary story is *open app → type a number → Add*. No macros, no accounts, no fuss.
Totals are stored on-device and roll over to 0 at midnight (history is kept).

## Build & run (needs a Mac)

watchOS apps can only be built/signed on macOS with Xcode — that's an Apple
constraint, not a choice. This repo ships an [XcodeGen](https://github.com/yonyz/XcodeGen)
spec so the `.xcodeproj` is generated, not hand-maintained.

```sh
brew install xcodegen      # once
xcodegen generate          # creates Calos.xcodeproj from project.yml
open Calos.xcodeproj
```

In Xcode:
1. Select the **Calos** target → **Signing & Capabilities** → pick your Apple ID Team
   (and change the bundle id from `com.bddap.calos` if needed).
2. Choose a destination: an **Apple Watch Series … (watchOS) Simulator**, or your own
   watch (paired via your iPhone, Developer Mode on).
3. **Run** (⌘R).

No paid Apple Developer account is needed to run on the simulator or, for 7 days, on
your own watch with a free personal team.

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
