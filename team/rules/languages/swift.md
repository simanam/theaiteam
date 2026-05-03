# Swift / iOS

## Toolchain

- Swift 5.9+; targeting iOS 16+ unless brief says otherwise.
- Xcode latest stable.
- SwiftPM preferred for dep management; CocoaPods for SDKs that distribute via Pods.
- SwiftLint + SwiftFormat in CI.

## Concurrency

- `async / await` and structured concurrency (Swift 6 concurrency model).
- `actor` for isolated mutable state.
- `@MainActor` annotations for UI-touching code.
- Avoid `DispatchQueue` callbacks in new code.

## SwiftUI

- Default to SwiftUI for new UI; UIKit only for required platform integrations.
- `@Observable` over `ObservableObject` (Swift 5.9+).
- Views are small and composable. Long view bodies → extract subviews.
- Previews for every reusable view.

## Patterns

- MVVM with SwiftUI; coordinators only when nav demands it.
- Dependency injection via initializer or environment, not singletons.
- Result types for error-prone returns; `throws` for failable async.
- Codable for serialization; custom encoders only when needed.

## Networking

- `URLSession` async API. Wrap in a typed `APIClient`.
- Retry policy decided at the client level, not call site.
- Auth tokens injected via interceptor / middleware pattern.

## Compliance

- App Tracking Transparency: prompt only after user understands the value, never on launch.
- Privacy manifest (`PrivacyInfo.xcprivacy`) listing all SDKs and reasons.
- Required reason API audit (UserDefaults, file timestamps, etc.).
- Universal Links with proper `apple-app-site-association` on the production domain.

## Testing

- XCTest for unit; XCUITest for UI flows.
- Snapshot tests via `swift-snapshot-testing` for visual regressions.
- Test on the lowest supported iOS version, not just latest.

## Common pitfalls

- Force-unwraps in shipped code. Almost always a bug.
- Strong-reference cycles in closures. `[weak self]` when capturing in long-lived closures.
- Reflection-based serialization that breaks across Swift versions.
- Reading IDFA before ATT consent.
