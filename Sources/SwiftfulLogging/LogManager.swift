import SwiftUI

@MainActor
@Observable
public class LogManager {

    /// Each registered service paired with the set of `LogType`s it should
    /// receive. Events are only forwarded to a service when its allowed set
    /// contains the event's type, so routing (e.g. `.info` to the console only,
    /// analytics to Mixpanel) is declared here at composition time rather than
    /// inside each service. User-identity operations are not type-scoped and are
    /// always forwarded to every service.
    private let services: [(service: any LogService, allowedTypes: Set<LogType>)]

    /// Convenience initializer — every service receives every `LogType`.
    /// Back-compatible with existing call sites.
    public init(services: [any LogService] = []) {
        self.services = services.map { ($0, Set(LogType.allCases)) }
    }

    /// Routing initializer — each service receives only the `LogType`s in its
    /// allowed list. For example:
    /// ```
    /// LogManager(services: [
    ///     (ConsoleService(), LogType.allCases),
    ///     (MixpanelService(token: token), [.analytic, .warning, .severe]),
    ///     (FirebaseCrashlyticsService(), [.severe]),
    /// ])
    /// ```
    public init(services: [(any LogService, [LogType])]) {
        self.services = services.map { ($0.0, Set($0.1)) }
    }

    public func trackEvent(eventName: String, parameters: [String : Any]? = nil, type: LogType = .analytic) {
        let event = AnyLoggableEvent(eventName: eventName, parameters: parameters, type: type)
        for entry in services where entry.allowedTypes.contains(event.type) {
            entry.service.trackEvent(event: event)
        }
    }

    public func trackEvent(event: AnyLoggableEvent) {
        for entry in services where entry.allowedTypes.contains(event.type) {
            entry.service.trackEvent(event: event)
        }
    }

    public func trackEvent(event: LoggableEvent) {
        for entry in services where entry.allowedTypes.contains(event.type) {
            entry.service.trackEvent(event: event)
        }
    }

    public func trackScreenView(event: LoggableEvent) {
        for entry in services where entry.allowedTypes.contains(event.type) {
            entry.service.trackScreenView(event: event)
        }
    }

    public func identifyUser(userId: String, name: String?, email: String?) {
        for entry in services {
            entry.service.identifyUser(userId: userId, name: name, email: email)
        }
    }

    public func addUserProperties(dict: [String: Any], isHighPriority: Bool = false) {
        for entry in services {
            entry.service.addUserProperties(dict: dict, isHighPriority: isHighPriority)
        }
    }

    public func deleteUserProfile() {
        for entry in services {
            entry.service.deleteUserProfile()
        }
    }
}
