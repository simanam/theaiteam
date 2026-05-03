# Kotlin / Android

## Toolchain

- Kotlin 1.9+; minSdk 26+ unless brief says otherwise.
- Android Gradle Plugin 8.0+.
- ktlint + detekt in CI.
- Distribution: Maven Central via Sonatype OSSRH for SDKs; Play Console for apps.

## Concurrency

- Kotlin coroutines + structured concurrency.
- `Flow` for reactive streams; `StateFlow` / `SharedFlow` for view-model state.
- `viewModelScope` / `lifecycleScope` — never bare `GlobalScope`.

## Compose

- Jetpack Compose for new UI; XML layouts only for legacy or specific needs.
- Stateless composables where possible; state hoisted to view model.
- Preview annotations for every reusable composable.
- Material 3 components by default.

## Patterns

- MVVM with Hilt for DI.
- Repository pattern for data; data sources isolated.
- `Result` / sealed classes for error-prone returns.
- kotlinx.serialization for JSON.

## Networking

- Retrofit + OkHttp + kotlinx.serialization converter.
- Interceptors for auth, logging, retry.
- Timeouts set explicitly. Defaults are too long.

## Compliance

- Android App Links with verified Digital Asset Links (`assetlinks.json`) on the production domain.
- Permissions requested at point-of-use, not on launch.
- Privacy policy URL filed in Play Console.
- Target latest Android API per Play Store requirements (annual ratchet).

## Testing

- JUnit 5 + Mockk for unit tests.
- Compose UI tests via `createComposeRule`.
- Robolectric for fast Android-flavored tests; instrumented tests for real-device behavior.
- Test on the minimum supported API level, not just latest.

## Common pitfalls

- Memory leaks from holding `Activity` / `Context` in long-lived scopes.
- Blocking the main thread on Room or shared-prefs reads.
- Force-unwrap (`!!`) sprinkled liberally. Almost always a bug.
- Reflection-based JSON parsing in release builds (kotlinx.serialization processor avoids this).
