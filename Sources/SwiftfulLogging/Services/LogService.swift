//
//  LogService.swift
//  SwiftfulLogging
//
//  Created by Nick Sarno on 9/25/24.
//
import SendableDictionary

public protocol LogService: Sendable {
    func identifyUser(userId: String, name: String?, email: String?)
    func addUserProperties(dict: [String: Any], isHighPriority: Bool)
    func deleteUserProfile()

    func trackEvent(event: LoggableEvent)
    func trackScreenView(event: LoggableEvent)
}
