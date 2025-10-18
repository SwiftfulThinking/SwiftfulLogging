# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

SwiftfulLogging is a production-ready, plugin-based logging framework for Swift 6 applications. It provides a unified interface for integrating multiple logging services (console, analytics, crash reporting) with thread-safe, actor-based implementation and full SwiftUI integration.

## Common Development Commands

### Building and Testing
```bash
# Build the library
swift build

# Run all tests
swift test

# Run a specific test
swift test --filter LogManagerTests

# Clean build artifacts
swift package clean

# Resolve package dependencies
swift package resolve

# Generate Xcode project (if needed)
swift package generate-xcodeproj
```

### Development Workflow
```bash
# Format code (if swift-format is installed)
swift-format -i Sources/**/*.swift Tests/**/*.swift

# Build in release mode for performance testing
swift build -c release

# Run tests with verbose output
swift test --verbose
```

## Architecture and Structure

### Core Architecture Pattern
The framework uses a **plugin-based service architecture** with these key components:

1. **LogManager** (`Sources/SwiftfulLogging/LogManager.swift`):
   - Main actor-isolated orchestrator that maintains an array of `LogService` instances
   - Dispatches all logging operations to registered services
   - Observable for SwiftUI environment integration

2. **LogService Protocol** (`Sources/SwiftfulLogging/Services/LogService.swift`):
   - Core abstraction that all logging backends must implement
   - Defines interface for event tracking, screen views, and user management
   - Marked as `Sendable` for Swift concurrency safety

3. **LoggableEvent Protocol** (`Sources/SwiftfulLogging/Models/LoggableEvent.swift`):
   - Defines structure for type-safe events with name, parameters, and log type
   - Typically implemented as enums for compile-time safety
   - `AnyLoggableEvent` provided for dynamic event creation

4. **Actor-Based Thread Safety** (`Sources/SwiftfulLogging/Services/Console/LogSystem.swift`):
   - `LogSystem` actor ensures thread-safe console logging
   - Wraps OSLog with proper concurrency handling

### Service Integration Pattern
External services are integrated by:
1. Implementing the `LogService` protocol
2. Adding the service to LogManager's services array
3. All method calls are automatically forwarded to all registered services

Example service packages:
- `SwiftfulLoggingMixpanel` - Mixpanel analytics
- `SwiftfulLoggingFirebaseAnalytics` - Firebase Analytics
- `SwiftfulLoggingFirebaseCrashlytics` - Crash reporting

### Key Design Decisions

1. **Main Actor Isolation**: LogManager is `@MainActor` isolated to ensure UI-safe operations and SwiftUI compatibility.

2. **Protocol-Based Events**: Events use protocols rather than structs to allow enum-based implementation with associated values, enabling type-safe event definitions.

3. **Sendable Conformance**: All public types conform to `Sendable` for Swift 6 concurrency safety.

4. **No External Dependencies**: Core library has zero external dependencies, making it lightweight and reducing version conflicts.

5. **Log Type Mapping**: Custom `LogType` enum maps to `OSLogType` for native integration while providing framework-specific semantics.

## Testing Strategy

Tests use Apple's new Testing framework (Swift 6) with `@Test` macro. The test suite includes:
- Mock service implementation that captures all method calls
- Verification that LogManager correctly forwards to all services
- Main actor isolation testing

To add new tests:
1. Add test methods to `Tests/SwiftfulLoggingTests/LogManager+Tests.swift`
2. Use `MockLogService` to verify service interactions
3. Mark tests with `@MainActor` for UI-related code

## Adding New Features

### Adding a New LogService Method
1. Add method signature to `LogService` protocol
2. Implement in `LogManager` to forward to all services
3. Implement in `ConsoleService` with appropriate logging
4. Add corresponding test in `LogManager+Tests.swift`
5. Update MockLogService to track the new method

### Creating Custom Event Types
Implement `LoggableEvent` protocol as an enum:
```swift
enum MyEvents: LoggableEvent {
    case userAction(name: String, value: Int)

    var eventName: String { /* return event name */ }
    var parameters: [String: Any]? { /* return parameters */ }
    var type: LogType { /* return .info/.analytic/.warning/.severe */ }
}
```

### Platform Requirements
- Swift 6.0+
- iOS 17.0+ / macOS 14.0+
- Uses SwiftUI's `@Observable` macro (requires iOS 17/macOS 14)