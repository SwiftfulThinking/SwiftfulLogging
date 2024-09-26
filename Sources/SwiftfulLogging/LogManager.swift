
import SwiftUI
import SendableDictionary

@MainActor
@Observable
public class LogManager {
    private let services: [LogService]

    public init(services: [LogService] = []) {
        self.services = services
    }
    
    public func trackEvent(eventName: String, parameters: [String : Any]? = nil, type: LogType = .analytic) {
        let event = AnyLoggableEvent(eventName: eventName, parameters: parameters, type: type)
        services.trackEvent(event: event)
    }
    
    public func trackEvent(event: AnyLoggableEvent) {
        services.trackEvent(event: event)
    }

    public func trackEvent(event: LoggableEvent) {
        services.trackEvent(event: event)
    }

    public func trackScreenView(event: LoggableEvent) {
        services.trackScreenView(event: event)
    }

    public func identifyUser(userId: String, name: String?, email: String?) {
        services.identifyUser(userId: userId, name: name, email: email)
    }

    public func addUserProperties(dict: SendableDict) {
        services.addUserProperties(dict: dict)
    }

    public func deleteUserProfile() {
        services.deleteUserProfile()
    }
}
