# Mood Day

The first screen of the daily mood check-in, built in native SwiftUI, with a matching interactive browser preview. Only the happy mood is implemented in this iteration.

## Preview now

From this directory:

```sh
python3 -m http.server 8768 --bind 127.0.0.1
```

Open <http://127.0.0.1:8768/Preview/>. The preview also works by opening `Preview/index.html` directly. It has no package dependencies, remote fonts, analytics, or network requests beyond local assets.

- Tap Happy or the Happy label to select the mood and trigger the original joyful hop and sparkles, along with a gentle blink. Happy’s original image floats and sways between taps.
- Next is enabled after selection and opens a confirmation sheet.
- Back clears the current selection. Escape or Back to check-in closes the sheet.
- The desktop preview has a pause/resume control. System Reduce Motion is respected on all screen sizes.

## Native iOS project

Open `MoodDay.xcodeproj` in Xcode. Select the MoodDay scheme and an iPhone simulator, then Run. Use the latest stable Xcode with the iOS SDK installed. The project uses Swift 6 language mode, SwiftUI, Canvas, structured concurrency, native haptics, and previews. Deployment target: iOS 26+. It uses the installed SDK, including the latest SDK when opened in Xcode 27.

For a physical device, choose your signing team and replace `com.example.MoodDay` with your own bundle identifier. The system status bar and home indicator are native; only the browser preview draws stand-ins.

```sh
xcodebuild -project MoodDay.xcodeproj -scheme MoodDay \
  -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO build
```

## Screen structure

- `MoodDay/MoodDayApp.swift`: single-screen app host and temporary selection confirmation.
- `MoodDay/HappyCheckInView.swift`: responsive layout, selection, Back/Next, haptics and accessibility.
- `MoodDay/HappySceneView.swift`: character timeline and interaction state, meadow movement, pulsing sun, clouds, butterflies, drifting particles and swaying flowers. Timeline rendering pauses when the app is inactive and when Reduce Motion is enabled.
- `MoodDay/HappyCharacterView.swift`: original Happy artwork with localized blinking eye lids; the original body, head and smile are preserved, with whole-image floating and tap-to-hop movement.
- `Preview/happy.js`: matching image renderer with eye-only blinking, bounded Retina rendering, pause/resume and visibility handling.
- `MoodDay/Assets.xcassets`: locally bundled transparent avatar and meadow scenery.
- `Preview/`: browser review companion; the iOS app does not use a web view.

## Scope and integration

This is step 1 only. The confirmation sheet is the boundary of this prototype, not a completed three-step check-in. It does not save a mood record. Replace `CheckInPreviewHost`'s confirmation with the next screen and pass the selected happy mood into the eventual check-in model. Onboarding, sign-up, home, the other three moods and check-in steps 2–3 are not yet implemented.

Happy uses the original transparent full-body image. Only localized eye lids animate, blinking every 5.3 seconds and on tap. The full image gently floats and sways, with a joyful hop on tap. There is no separate limb or mouth animation. The prior rig atlas is retained as unused artwork. Scenery combines a generated meadow plate with native animated layers. See `ASSET_PROMPTS.md` for asset provenance and generation prompts.

## Validation

Browser review passed at desktop size, 390 × 844, and 320 × 568: the avatar loads, tap and keyboard selection enable Next, Back resets selection, the confirmation opens and closes, pause/resume works, and there is no horizontal overflow. The small viewport scrolls vertically to keep the controls available. No browser console errors were reported. A 390 × 844 capture is saved at `Preview/preview-iphone.jpg`.

The Swift syntax check, project plist lint, shared scheme XML check, asset filename checks and project reference checks passed. The original-image restoration was visually reviewed. Selection still enables Next, and the eye renderer respects Pause and Reduce Motion. No browser errors were reported.

Swift source syntax can be checked with the available command-line compiler:

```sh
swiftc -frontend -parse MoodDay/MoodDayApp.swift MoodDay/HappyCheckInView.swift MoodDay/HappySceneView.swift MoodDay/HappyCharacterView.swift
plutil -lint MoodDay.xcodeproj/project.pbxproj
```

Full Xcode is not installed on the development Mac at delivery, so no iOS SDK build, simulator run, VoiceOver device check, or native rendering verification has been performed. Syntax parsing is not type checking. Install Xcode and run the build above before relying on the native app. The browser companion is used for visual and interaction review in the meantime.

### Happy and Sad mood preview
Swipe left across the character to explore Sad; swipe right to return to Happy. Keyboard users can use the arrow keys while a mood button is focused. Tap the character or its label to select/deselect; only the currently selected mood shows Next. The shared stage blends the characters and weather, preserving the header and controls. Sad uses the supplied character reference, a cool desaturated meadow, drifting clouds, and animated rain. Pause and reduced-motion preferences are respected. Native SwiftUI implements the same mood selection and horizontal gesture; native code was syntax checked, but requires full Xcode for a simulator build.
