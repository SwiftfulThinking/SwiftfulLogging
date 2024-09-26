//
//  File.swift
//  SwiftfulLogging
//
//  Created by Nick Sarno on 9/25/24.
//
import SendableDictionary

extension Array where Element == LogService {
    func trackEvent(event: LoggableEvent) {
        diffLogServices { service in
            service.trackEvent(event: event)
        }
    }

    func trackScreenView(event: LoggableEvent) {
        diffLogServices { service in
            service.trackScreenView(event: event)
        }
    }

    func identifyUser(userId: String, name: String?, email: String?) {
        diffLogServices { service in
            service.identifyUser(userId: userId, name: name, email: email)
        }
    }

    func addUserProperties(dict: SendableDict) {
        diffLogServices { service in
            service.addUserProperties(dict: dict)
        }
    }

    func deleteUserProfile() {
        diffLogServices { service in
            service.deleteUserProfile()
        }
    }

    private func diffLogServices(action: @escaping @Sendable (LogService) -> Void) {
        for service in self {
            action(service)
        }
    }
}
