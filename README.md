# SwiftfulLogging

A reusable logger for Swift applications, built for Swift 6. `LogManager` coordinates multiple `LogService` implementations (Console, Firebase, Mixpanel, etc.) through a single API. Includes `@Observable` support.

## Setup

<details>
<summary> Details (Click to expand) </summary>
<br>

Add SwiftfulLogging to your project.

```
https://github.com/SwiftfulThinking/SwiftfulLogging.git
```

Import the package.

```swift
import SwiftfulLogging
```

Create an instance of `LogManager` with one or more services:

```swift
// Development — console only
let logger = LogManager(services: [ConsoleService()])

// Production — multiple services
let logger = LogManager(services: [
    ConsoleService(),
    FirebaseAnalyticsService(),
    FirebaseCrashlyticsService(),
    MixpanelService(token: "your_token")
])
```

Optionally add to the SwiftUI environment:

```swift
Text("Hello, world!")
    .environment(logger)
```

</details>

## Services

<details>
<summary> Details (Click to expand) </summary>
<br>

`LogManager` is initialized with an array of `LogService`. `ConsoleService` is included in the package. Other services are separate packages so you can pick and choose:

- **Console** — included, prints to console via OSLog or stdout
- **Mixpanel** — [SwiftfulLoggingMixpanel](https://github.com/SwiftfulThinking/SwiftfulLoggingMixpanel)
- **Firebase Analytics** — [SwiftfulLoggingFirebaseAnalytics](https://github.com/SwiftfulThinking/SwiftfulLoggingFirebaseAnalytics)
- **Firebase Crashlytics** — [SwiftfulLoggingFirebaseCrashlytics](https://github.com/SwiftfulThinking/SwiftfulLoggingFirebaseCrashlytics)

### ConsoleService

```swift
// Default — prints parameters, uses stdout
let console = ConsoleService()

// Custom — hide parameters, use OSLog
let console = ConsoleService(printParameters: false, system: .osLog)
```

### Custom LogService

Create your own by conforming to the protocol:

```swift
public protocol LogService: Sendable {
    func identifyUser(userId: String, name: String?, email: String?)
    func addUserProperties(dict: [String: Any], isHighPriority: Bool)
    func deleteUserProfile()
    func trackEvent(event: LoggableEvent)
    func trackScreenView(event: LoggableEvent)
}
```

</details>

## Track Events

<details>
<summary> Details (Click to expand) </summary>
<br>

Log events with a name, optional parameters, and a log type:

```swift
logger.trackEvent(eventName: "ButtonTapped")
logger.trackEvent(eventName: "ButtonTapped", parameters: ["button_id": "save"])
logger.trackEvent(eventName: "ButtonTapped", parameters: ["button_id": "save"], type: .analytic)
```

Use `AnyLoggableEvent` for convenience:

```swift
let event = AnyLoggableEvent(eventName: "ButtonTapped", parameters: ["button_id": "save"], type: .analytic)
logger.trackEvent(event: event)
```

**Recommended:** Use the `LoggableEvent` protocol with custom enums for type-safe events:

```swift
enum Event: LoggableEvent {
    case screenDidAppear(title: String)
    case buttonTapped(id: String)
    case screenError(error: Error)

    var eventName: String {
        switch self {
        case .screenDidAppear:  return "ScreenAppear"
        case .buttonTapped:     return "ButtonTapped"
        case .screenError:      return "ScreenError"
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .screenDidAppear(let title):
            return ["title": title]
        case .buttonTapped(let id):
            return ["button_id": id]
        case .screenError(let error):
            return ["error_description": error.localizedDescription]
        }
    }

    var type: LogType {
        switch self {
        case .screenDidAppear, .buttonTapped:
            return .analytic
        case .screenError:
            return .severe
        }
    }
}
```

```swift
logger.trackEvent(event: Event.screenDidAppear(title: "Home"))
```

</details>

## Log Types

<details>
<summary> Details (Click to expand) </summary>
<br>

Every event has a `LogType` that classifies its severity:

```swift
logger.trackEvent(eventName: "UserLoaded", type: .info)      // Informational, not an issue
logger.trackEvent(eventName: "ScreenAppear", type: .analytic) // Standard analytics (default)
logger.trackEvent(eventName: "RetryFailed", type: .warning)   // Non-breaking issue
logger.trackEvent(eventName: "CrashDetected", type: .severe)  // Breaks user experience
```

| Type | Purpose |
|---|---|
| `.info` | Informational logging, not issues or errors |
| `.analytic` | Standard analytics events (default) |
| `.warning` | Issues that should not occur but don't break UX |
| `.severe` | Critical errors that affect user experience |

Services can use the log type to handle events differently. For example, `FirebaseCrashlyticsService` only records `.severe` events as errors.

</details>

## Track Screen Views

<details>
<summary> Details (Click to expand) </summary>
<br>

Track screen views separately from events. Some analytics services (e.g. Firebase Analytics) have dedicated screen view tracking.

```swift
let event = AnyLoggableEvent(eventName: "HomeScreen", type: .analytic)
logger.trackScreenView(event: event)

// Or with a custom LoggableEvent enum
logger.trackScreenView(event: Event.screenDidAppear(title: "Home"))
```

</details>

## Manage User Profile

<details>
<summary> Details (Click to expand) </summary>
<br>

Identify the current user (log them in to all services):

```swift
logger.identifyUser(userId: "abc123", name: "Nick", email: "hello@swiftful-thinking.com")
```

Add user properties for analytics segmentation:

```swift
logger.addUserProperties(dict: ["is_premium": true, "plan": "annual"])
logger.addUserProperties(dict: ["account_type": "pro"], isHighPriority: true)
```

Note: `isHighPriority` matters for services with limited user property slots (e.g. Firebase Analytics only sets properties when `isHighPriority` is `true`).

Delete user profile:

```swift
logger.deleteUserProfile()
```

</details>

## Claude Code

This package includes a `.claude/swiftful-logging-rules.md` with usage guidelines, event patterns, and integration advice for projects using [Claude Code](https://claude.ai/claude-code).

## Platform Support

- **iOS 17.0+**
- **macOS 14.0+**

## License

SwiftfulLogging is available under the MIT license.
