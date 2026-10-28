import SwiftUI

@MainActor
@Observable
public class LogManager {

    /// Each registered service plus the routing it should receive (which event
    /// `LogType`s, and which user properties). Routing is declared here at
    /// composition time — e.g. `.info` to the console only, analytics to
    /// Mixpanel, only `.severe` to Crashlytics — rather than inside each service.
    /// User-identity operations (identify / delete) are not scoped and always go
    /// to every service.
    private let services: [LoggableService]

    public init(services: [LoggableService]) {
        self.services = services
    }

    public func trackEvent(eventName: String, parameters: [String : Any]? = nil, type: LogType = .analytic) {
        let event = AnyLoggableEvent(eventName: eventName, parameters: parameters, type: type)
        for entry in services where entry.allowsEvent(event.type) {
            entry.service.trackEvent(event: event)
        }
    }

    public func trackEvent(event: AnyLoggableEvent) {
        for entry in services where entry.allowsEvent(event.type) {
            entry.service.trackEvent(event: event)
        }
    }

    public func trackEvent(event: LoggableEvent) {
        for entry in services where entry.allowsEvent(event.type) {
            entry.service.trackEvent(event: event)
        }
    }

    public func trackScreenView(event: LoggableEvent) {
        for entry in services where entry.allowsEvent(event.type) {
            entry.service.trackScreenView(event: event)
        }
    }

    public func identifyUser(userId: String, name: String?, email: String?) {
        for entry in services {
            entry.service.identifyUser(userId: userId, name: name, email: email)
        }
    }

    public func addUserProperties(dict: [String: Any], isHighPriority: Bool = false) {
        for entry in services where entry.allowsUserProperties(isHighPriority: isHighPriority) {
            entry.service.addUserProperties(dict: dict, isHighPriority: isHighPriority)
        }
    }

    public func deleteUserProfile() {
        for entry in services {
            entry.service.deleteUserProfile()
        }
    }
}
