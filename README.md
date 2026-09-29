# Live Activities Demo App

Five Live Activity designs in one iOS app, each with a switch that puts it on the
Lock Screen so you can compare the patterns side by side. Built to explore how far
the format can be pushed — the flight design is modelled on Air India's boarding
activity, which packs terminal, gate, zone, seat, status, both airport codes, both
local times, flight duration and a live boarding countdown into one glance.

| Design | Pattern |
|---|---|
| Flight & boarding pass | Dense information board with a live boarding countdown |
| Order delivery | Staged tracker with a live ETA |
| Ride pickup | One emphasised number, plus the car to look for |
| Daily streak | Countdown to losing accumulated progress |
| Turn-by-turn directions | One dominant maneuver, everything else secondary |

Each design implements the Lock Screen layout plus all three Dynamic Island
presentations (compact, minimal, expanded), and declares
`supplementalActivityFamilies` so it also reaches the Apple Watch Smart Stack.

## Requirements

- **Xcode 26 or newer.** The project uses file-system-synchronized groups
  (`objectVersion = 77`) and `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`.
- **iOS 26.5 or newer** to run it — that's the deployment target. Lower
  `IPHONEOS_DEPLOYMENT_TARGET` to 18.0 if you need wider device support; nothing
  newer than iOS 18 is actually used.
- iOS only. ActivityKit doesn't exist on macOS or visionOS.
- No package dependencies.

## Running it

**On the simulator** — clone, open `Live Activities Demo App.xcodeproj`, run. No
signing setup needed.

**On a device** — signing is intentionally not checked in, so set it yourself:

1. Select the **Live Activities Demo App** target → Signing & Capabilities → pick
   your Team.
2. Do the same for the **LiveActivityWidgets** target. Both need it.
3. If Xcode reports the bundle identifier is taken, change
   `PRODUCT_BUNDLE_IDENTIFIER` on both targets to your own prefix. The extension's
   identifier must stay prefixed by the app's — e.g. `com.you.LiveDemo` and
   `com.you.LiveDemo.LiveActivityWidgets`.

## Layout

- `Shared/` — `ActivityAttributes` types, the Lock Screen views and the scripted
  demo scenarios. Compiled into **both** targets, which is how the picker screen
  previews the exact views the widget renders.
- `LiveActivityWidgets/` — the widget extension. Live Activities can only be
  declared here, one `ActivityConfiguration` per design.
- `Live Activities Demo App/` — the picker screen and the ActivityKit manager.

## Things worth knowing if you're building your own

Three behaviours cost real debugging time here:

- **ActivityKit allows only 5 simultaneous activities per app.** The 6th request
  throws `targetMaximumExceeded`, whose message is an unhelpful "The operation
  couldn't be completed."
- **Xcode's Stop button does not end Live Activities.** They outlive the debug
  session, so repeated Run/Stop cycles leak them until you hit that limit of 5 and
  nothing will start. This app ends leftovers on launch and its "Stop all" clears
  every activity, including ones it didn't start.
- **Don't apply `.fixedSize()` to `Text(timerInterval:)`.** It breaks rendering in
  the widget process — badly enough that iOS silently destroys the activity a
  second or two after `Activity.request` reports success. Reserve width with
  `.frame(minWidth:)` instead.

Live Activities never show a permission prompt, so there's nothing to allow on
first launch. The only control is Settings › the app › Live Activities.
