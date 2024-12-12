### 🚀 Learn how to build and use this package: https://www.swiftful-thinking.com/offers/REyNLwwH

# Logger for Swift 6 🪓

A reusable logger for Swift applications, built for Swift 6. Includes `@Observable` support.

Pre-built dependencies*:

- Console: Included
- Mixpanel: https://github.com/SwiftfulThinking/SwiftfulLoggingMixpanel
- Firebase Analytics: https://github.com/SwiftfulThinking/SwiftfulLoggingFirebaseAnalytics.git
- Firebase Crashlytics: https://github.com/SwiftfulThinking/SwiftfulLoggingFirebaseCrashlytics.git

\* Created another? Send the url in [Issues](https://github.com/SwiftfulThinking/SwiftfulLogging/issues)! 🥳

## Setup

<details>
<summary> Details (Click to expand) </summary>
<br>
    
#### Create an instance of LogManager:

```swift
let logger = LogManager(services: [any LogService])

// Example dev
let logger = LogManager(services: [ConsoleService()])

// Example prod
let logger = LogManager(services: [MixpanelService(), FirebaseAnalyticsService(), FirebaseCrashlyticsService()])
```

#### Optionally add to SwiftUI environment as an @Observable

```swift
Text("Hello, world!")
    .environment(logger)
```

</details>

## Inject dependencies

<details>
<summary> Details (Click to expand) </summary>
<br>
    
`LogManager` is initialized by an array of `LogService`. This is a public protocol you can use to create your own dependencies.

`ConsoleLogger` is included within the package, which uses the `OSLog` framework to print to the console.

```swift
let consoleService = ConsoleService(printParameters: true)
let logger = LogManager(services: [consoleService])
```

Other services are not directly included, so that the developer can pick-and-choose which dependencies to add to the project. 

You can create your own `LogService` by conforming to the protocol:

```swift
public protocol LogService: Sendable {
    func identifyUser(userId: String, name: String?, email: String?)
    func addUserProperties(dict: SendableDict)
    func deleteUserProfile()
    func trackEvent(event: LoggableEvent)
    func trackScreenView(event: LoggableEvent)
}
```

</details>

## Track events

<details>
<summary> Details (Click to expand) </summary>
<br>
    
#### Log events manually:

```swift
logger.trackEvent(eventName: "EventName")
logger.trackEvent(eventName: "EventName", parameters: ["ParameterName":true])
logger.trackEvent(eventName: "EventName", parameters: ["ParameterName":true], type: .analytic)
```

#### Use `AnyLoggableEvent` for convenience:

```swift
let event = AnyLoggableEvent(eventName: "EventName", parameters: ["ParameterName":true], type: .analytic)
logger.trackEvent(event: event)
```

#### Use `LoggableEvent` protocol to send your own types. Recommended approach:

```swift
enum Event: LoggableEvent {
    case screenDidLoad
    case screenDidAppear(title: String)
    case screenError(error: Error)
    
    var eventName: String {
        switch self {
        case .screenDidLoad:                return "ScreenLoad"
        case .screenDidAppear(let title):   return "ScreenAppear"
        case .screenError(let error):       return "ScreenError"
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .screenDidLoad:
            return nil
        case .screenDidAppear(let title):
            return ["title": title]
        case .screenError(let error):
            return [
                "error_description": error.localizedDescription
            ]
        }
    }
    
    var type: LogType {
        switch self {
        case .screenDidLoad, .screenDidAppear:
            return .analytic
        case .screenError:
            return .severe
        }
    }
}
```
```swift
let event = Event.screenDidAppear(title: "Title")
logger.trackEvent(event: event)
```

#### Optionally use the event's `LogType` to handle different types of events in your `LogService`.

```swift
logger.trackEvent(eventName: "EventName", type .info) // Informational only
logger.trackEvent(eventName: "EventName", type .analytics) // For typical analytics
logger.trackEvent(eventName: "EventName", type .warning) // Warnings or issues that should not occur, but don't break the user experience
logger.trackEvent(eventName: "EventName", type .severe) // Errors that break the user experience
```

</details>

## Track screen views

<details>
<summary> Details (Click to expand) </summary>
<br>
    
The same logic as `trackEvent` above, except calling `trackScreenView` method. This is used in case the developer wants to do something unique for screen views (ie. some analytics services have a unique way of tracking these).

```swift
// Manual
logger.trackScreenView(eventName: "EventName")
logger.trackScreenView(eventName: "EventName", parameters: ["ParameterName":true])
logger.trackScreenView(eventName: "EventName", parameters: ["ParameterName":true], type: .analytic)

// Using AnyLoggableEvent
let event = AnyLoggableEvent(eventName: "EventName", parameters: ["ParameterName":true], type: .analytic)
logger.trackScreenView(event: event)

// Using LoggableEvent
let event = Event.screenDidAppear(title: "Title")
logger.trackScreenView(event: event)
```

</details>


## Manage user profile

<details>
<summary> Details (Click to expand) </summary>
<br>
    
#### Identify the current user (aka log them in to injected Services)

```swift
logger.identifyUser(userId: String, name: String?, email: String?)
logger.identifyUser(userId: "abc123", name: "Nick", email: "hello@swiftful-thinking.com)
```

#### Add user properties

```swift
logger.addUserProperties(dict: [String: Any])
logger.addUserProperties(dict: SendableDict)
```

#### Delete user 

```swift
logger.deleteUserProfile()
```

</details>


