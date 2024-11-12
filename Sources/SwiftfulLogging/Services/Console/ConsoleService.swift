//
//  ConsoleService.swift
//  SwiftfulLogging
//
//  Created by Nick Sarno on 9/25/24.
//

import Foundation
import SendableDictionary

public struct ConsoleService: LogService {

    private var printParameters: Bool
    private let logger = LogSystem()
    
    public init(printParameters: Bool = true) {
        self.printParameters = printParameters
    }

    public func trackEvent(event: LoggableEvent) {
        var value = "\(event.type.emoji) \(event.eventName)"
        if printParameters, let params = event.parameters, !params.isEmpty {
            let sortedKeys = params.keys.sorted()
            for key in sortedKeys {
                if let paramValue = params[key] {
                    value += "\n  (key: \"\(key)\", value: \(paramValue))"
                }
            }
        }

        logger.log(level: event.type, message: "\(value)")
    }

    public func trackScreenView(event: any LoggableEvent) {
        trackEvent(event: event)
    }

    public func identifyUser(userId: String, name: String?, email: String?) {
        var string = """
📈 Identify User
  userId: \(userId)
"""
        if printParameters {
            string += """

  name: \(name ?? "nil")
  email: \(email ?? "nil")
"""
        }

        logger.log(level: .info, message: "\(string)")
    }

    public func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        var string = """
📈 Add User Properties: (isHighPriority: \(isHighPriority.description)"
"""

        if printParameters {
            let sortedKeys = dict.keys.sorted()
            for key in sortedKeys {
                if let paramValue = dict[key] {
                    string += "\n  (key: \"\(key)\", value: \(paramValue))"
                }
            }
        }

        logger.log(level: .info, message: "\(string)")
    }

    public func deleteUserProfile() {
        let string = """
📈 Delete User Profile
"""

        logger.log(level: .info, message: "\(string)")
    }
}
