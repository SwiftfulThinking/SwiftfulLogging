
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
        for service in services {
            service.trackEvent(event: event)
        }
    }
    
    public func trackEvent(event: AnyLoggableEvent) {
        for service in services {
            service.trackEvent(event: event)
        }
    }

    public func trackEvent(event: LoggableEvent) {
        for service in services {
            service.trackEvent(event: event)
        }
    }

    public func trackScreenView(event: LoggableEvent) {
        for service in services {
            service.trackScreenView(event: event)
        }
    }

    public func identifyUser(userId: String, name: String?, email: String?) {
        for service in services {
            service.identifyUser(userId: userId, name: name, email: email)
        }
    }

    public func addUserProperties(dict: [String: Any], isHighPriority: Bool = false) {
        for service in services {
            service.addUserProperties(dict: dict, isHighPriority: isHighPriority)
        }
    }

    public func deleteUserProfile() {
        for service in services {
            service.deleteUserProfile()
        }
    }
}
