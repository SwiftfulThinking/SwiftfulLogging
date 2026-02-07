# SwiftfulLogging

Observable logging framework for Swift 6. `LogManager` distributes events to multiple `LogService` implementations (Console, Firebase Analytics, Mixpanel, Firebase Crashlytics). iOS 17+, macOS 14+.

## API

### LogManager

`@MainActor @Observable` class. All logging goes through this single entry point.

```swift
let logger = LogManager(services: [LogService])

logger.trackEvent(eventName: String, parameters: [String: Any]? = nil, type: LogType = .analytic)
logger.trackEvent(event: AnyLoggableEvent)
logger.trackEvent(event: LoggableEvent)
logger.trackScreenView(event: LoggableEvent)
logger.identifyUser(userId: String, name: String?, email: String?)
logger.addUserProperties(dict: [String: Any], isHighPriority: Bool = false)
logger.deleteUserProfile()
```

### LoggableEvent Protocol

```swift
public protocol LoggableEvent {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
    var type: LogType { get }
}
```

### AnyLoggableEvent

Convenience struct for ad-hoc events:

```swift
let event = AnyLoggableEvent(eventName: "ButtonTapped", parameters: ["id": "save"], type: .analytic)
```

### LogType

```swift
public enum LogType: Int, CaseIterable, Sendable {
    case info      // debug-only info, not sent to external services
    case analytic  // standard analytics events (default)
    case warning   // non-breaking issues that should rarely occur
    case severe    // critical errors affecting user experience
}
```

### ConsoleService

Built-in service for development logging:

```swift
ConsoleService(printParameters: Bool = true, system: LogSystemType = .stdout)
// system: .stdout (print) or .osLog (Apple OSLog)
```

### Available Service Implementations

```swift
import SwiftfulLogging                       // ConsoleService (included)
import SwiftfulLoggingFirebaseAnalytics      // FirebaseAnalyticsService()
import SwiftfulLoggingFirebaseCrashlytics    // FirebaseCrashlyticsService()
import SwiftfulLoggingMixpanel               // MixpanelService(token: String)
```

## Usage Guide

### Use SwiftfulLogging for ALL logging

IMPORTANT: Any app using SwiftfulLogging MUST use it for ALL analytics, logging, and console output. Never use `print()`, `dump()`, or `debugPrint()` directly.

| Instead of... | Use... |
|---|---|
| `print("debug info")` | `logger.trackEvent(eventName: "DebugInfo", type: .info)` |
| `print(error)` | `logger.trackEvent(eventName: "SomethingFailed", parameters: error.eventParameters, type: .severe)` |
| Analytics SDK directly | `logger.trackEvent(event: ...)` through LogManager |

When the user asks to "print" or "dump" something to the console, use `trackEvent` with `.info` type so it only appears in console during development and doesn't get sent to external analytics services.

### Service configuration by environment

Console logging is for development only. Production should never include `ConsoleService`.

```swift
// Mock / Testing — console only
let logger = LogManager(services: [
    ConsoleService(printParameters: true, system: .stdout)
])

// Development — console + all external services
let logger = LogManager(services: [
    ConsoleService(printParameters: true),
    FirebaseAnalyticsService(),
    MixpanelService(token: Keys.mixpanelToken),
    FirebaseCrashlyticsService()
])

// Production — external services only, no console
let logger = LogManager(services: [
    FirebaseAnalyticsService(),
    MixpanelService(token: Keys.mixpanelToken),
    FirebaseCrashlyticsService()
])
```

### LogType selection guide

IMPORTANT: Choose the correct `LogType` for every event. This determines which services process it and how it appears in dashboards.

**`.info`** — Debug-only information. Use for anything that helps the developer but doesn't need to go to external analytics. Console output, diagnostic data, temporary debugging. When in doubt between `print()` and analytics, use `.info`.

**`.analytic`** — Standard analytics events. The default for most events. Screen views, button taps, user actions, successful operations. This is the vast majority of events.

**`.severe`** — Real errors affecting user experience. Auth failures, purchase failures, network errors, data corruption, anything that breaks the user flow. These are logged as non-fatal crashes in Crashlytics so you can track error frequency in production. Not every failure is severe — use for errors that actually impact the user.

**`.warning`** — Non-breaking issues that should rarely happen. Edge cases that aren't technically errors but indicate something unexpected. Least used type. Examples: fallback to default value, unexpected empty state, deprecated code path hit.

```swift
// .info — developer diagnostics only
logger.trackEvent(eventName: "DebugTokenRefresh", parameters: ["token": token], type: .info)

// .analytic — standard event (default)
logger.trackEvent(eventName: "HomeView_Appear", type: .analytic)

// .warning — unexpected but non-breaking
logger.trackEvent(eventName: "UserProfile_MissingAvatar", type: .warning)

// .severe — real error, logged to Crashlytics as non-fatal
logger.trackEvent(eventName: "PurchaseFail", parameters: error.eventParameters, type: .severe)
```

### Event naming convention

Use `{ScreenName}_{Action}` or `{ScreenName}_{Feature}_{State}` format:

```swift
// Screen lifecycle
"HomeView_Appear"
"HomeView_Disappear"

// User actions
"HomeView_SettingsPressed"
"PaywallView_PurchasePressed"

// Async operations — Start / Success / Fail pattern
"CreateAccountView_AppleAuth_Start"
"CreateAccountView_AppleAuth_Success"
"CreateAccountView_AppleAuth_Fail"

// System events
"AppView_ExistingAuth_Start"
"AppView_ExistingAuth_Fail"
"AppView_FCM_Start"
"AppView_FCM_Success"
"AppView_FCM_Fail"
```

### Define events as LoggableEvent enums (recommended)

Every screen/presenter should define its own `Event` enum conforming to `LoggableEvent`. This is the recommended pattern over raw strings.

```swift
enum Event: LoggableEvent {
    case onAppear(delegate: HomeDelegate)
    case onDisappear(delegate: HomeDelegate)
    case settingsPressed
    case purchaseStart(product: AnyProduct)
    case purchaseSuccess(product: AnyProduct)
    case purchaseFail(error: Error)

    var eventName: String {
        switch self {
        case .onAppear:         return "HomeView_Appear"
        case .onDisappear:      return "HomeView_Disappear"
        case .settingsPressed:  return "HomeView_SettingsPressed"
        case .purchaseStart:    return "HomeView_Purchase_Start"
        case .purchaseSuccess:  return "HomeView_Purchase_Success"
        case .purchaseFail:     return "HomeView_Purchase_Fail"
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .onAppear(let delegate), .onDisappear(let delegate):
            return delegate.eventParameters
        case .purchaseStart(let product), .purchaseSuccess(let product):
            return product.eventParameters
        case .purchaseFail(let error):
            return error.eventParameters
        default:
            return nil
        }
    }

    var type: LogType {
        switch self {
        case .purchaseFail:
            return .severe
        default:
            return .analytic
        }
    }
}
```

### What to track

Every screen should have at minimum:

- **Appear / Disappear** — track when the screen is shown and dismissed
- **Button taps** — track when the user taps any meaningful button
- **Async operations** — track Start, Success, and Fail for any async action (network calls, auth, purchases, etc.)
- **Errors** — track all errors with `.severe` type and include error parameters

```swift
// Presenter — screen lifecycle
func onViewAppear(delegate: HomeDelegate) {
    interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
}

func onViewDisappear(delegate: HomeDelegate) {
    interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
}

// Presenter — async action with start/success/fail
func onPurchasePressed(product: AnyProduct) {
    interactor.trackEvent(event: Event.purchaseStart(product: product))

    Task {
        do {
            try await interactor.purchase(product: product)
            interactor.trackEvent(event: Event.purchaseSuccess(product: product))
        } catch {
            interactor.trackEvent(event: Event.purchaseFail(error: error))
        }
    }
}
```

### trackScreenEvent vs trackEvent

Use `trackScreenEvent` for screen appear events. Use `trackEvent` for everything else. Some analytics services (e.g. Firebase Analytics) handle screen views differently. In practice, both forward to `logManager.trackEvent()`, but the semantic distinction is important.

### isHighPriority for user properties

Firebase Analytics has a 25 user property limit. `addUserProperties(isHighPriority: true)` ensures the property is set in Firebase. Non-high-priority properties are only set in services without limits (e.g. Mixpanel). Use `isHighPriority: true` for key segmentation properties (subscription status, account type, etc.).

## Manager-Layer Logging

Most logging happens in the Presenter layer, but Managers also log internally. There are two patterns:

### Pattern 1: Manager defines its own Event enum

Some app-level managers (UserManager, ABTestManager, PushManager) define their own `Event: LoggableEvent` enums and accept `LogManager` directly:

```swift
class UserManager {
    private let logger: LogManager?

    init(logger: LogManager? = nil) {
        self.logger = logger
    }

    enum Event: LoggableEvent {
        case logInStart(user: UserModel?)
        case logInSuccess(user: UserModel?)
        case signOut
        case deleteAccountStart
        case deleteAccountSuccess

        var eventName: String { ... }
        var parameters: [String: Any]? { ... }
        var type: LogType { .analytic }  // manager events are typically .analytic
    }

    func logIn(user: UserModel) async throws {
        logger?.trackEvent(event: Event.logInStart(user: user))
        // ... perform login
        logger?.trackEvent(event: Event.logInSuccess(user: user))
    }
}
```

Managers also call `addUserProperties()` to set persistent analytics properties:

```swift
logger?.addUserProperties(dict: ["is_premium": true], isHighPriority: true)
```

### Pattern 2: Package defines its own logger protocol

Many Swiftful packages define their own logger protocols (separate from `LoggableEvent`). The app makes `LogManager` conform via retroactive conformance, then passes it as the logger:

| Package | Logger Protocol | Conformance |
|---|---|---|
| SwiftfulHaptics | `HapticLogger` | `extension LogManager: @retroactive HapticLogger` |
| SwiftfulSoundEffects | `SoundEffectLogger` | `extension LogManager: @retroactive SoundEffectLogger` |
| SwiftfulRouting | `RoutingLogger` | `SwiftfulRoutingLogger.enableLogging(logger: logManager)` |

```swift
// Retroactive conformance — LogManager adapts to each package's protocol
extension LogManager: @retroactive HapticLogger {
    public func trackEvent(event: any HapticLogEvent) {
        trackEvent(eventName: event.eventName, parameters: event.parameters, type: event.type.logType)
    }
}
```

### Wiring it all together

At app startup, `LogManager` is passed to every manager as their logger:

```swift
// All managers receive the same LogManager instance
userManager = UserManager(logger: logManager)
abTestManager = ABTestManager(logManager: logManager)
pushManager = PushManager(logManager: logManager)
hapticManager = HapticManager(logger: logManager)          // via HapticLogger protocol
soundEffectManager = SoundEffectManager(logger: logManager) // via SoundEffectLogger protocol
SwiftfulRoutingLogger.enableLogging(logger: logManager)     // via RoutingLogger protocol
```

This means ALL logging from every layer (Views, Presenters, Managers, and even third-party packages) flows through the single `LogManager` and gets distributed to all configured services.

## Architecture Examples

### MVC (pure SwiftUI) — @Environment

```swift
// Setup
Text("Hello")
    .environment(logger)

// View tracks directly
struct HomeView: View {
    @Environment(LogManager.self) var logger

    var body: some View {
        Text("Home")
            .onAppear {
                logger.trackEvent(eventName: "HomeView_Appear")
            }
    }
}
```

### MVVM — pass logger to ViewModel

```swift
@Observable
@MainActor
class HomeViewModel {
    private let logger: LogManager

    init(logger: LogManager) {
        self.logger = logger
    }

    func onAppear() {
        logger.trackEvent(eventName: "HomeView_Appear")
    }

    func onPurchasePressed() {
        logger.trackEvent(eventName: "HomeView_Purchase_Start")
        Task {
            do {
                try await purchase()
                logger.trackEvent(eventName: "HomeView_Purchase_Success")
            } catch {
                logger.trackEvent(eventName: "HomeView_Purchase_Fail", parameters: ["error": error.localizedDescription], type: .severe)
            }
        }
    }
}
```

### VIPER — interactor wraps LogManager

```swift
// GlobalInteractor protocol exposes logging
@MainActor
protocol GlobalInteractor {
    func trackEvent(eventName: String, parameters: [String: Any]?, type: LogType)
    func trackEvent(event: AnyLoggableEvent)
    func trackEvent(event: LoggableEvent)
    func trackScreenEvent(event: LoggableEvent)
}

// CoreInteractor forwards to LogManager
class CoreInteractor: GlobalInteractor {
    let logManager: LogManager

    func trackEvent(event: LoggableEvent) {
        logManager.trackEvent(event: event)
    }

    func trackScreenEvent(event: LoggableEvent) {
        logManager.trackEvent(event: event)
    }
}

// Presenter defines events and calls interactor
@Observable
@MainActor
class HomePresenter {
    private let interactor: HomeInteractor

    func onViewAppear(delegate: HomeDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }

    func onSettingsPressed() {
        interactor.trackEvent(event: Event.settingsPressed)
        router.showSettingsView()
    }
}

// View calls presenter
struct HomeView: View {
    @State var presenter: HomePresenter
    let delegate: HomeDelegate

    var body: some View {
        Text("Home")
            .onAppear { presenter.onViewAppear(delegate: delegate) }
            .onDisappear { presenter.onViewDisappear(delegate: delegate) }
    }
}
```
