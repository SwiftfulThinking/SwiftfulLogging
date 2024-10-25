//
//  ConsoleService.swift
//  SwiftfulLogging
//
//  Created by Nick Sarno on 9/25/24.
//

import Foundation
import OSLog
import SendableDictionary

public struct ConsoleService: LogService {

    private var printParameters: Bool
    
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

        LogSystem.log(level: event.type, message: "\(value)")
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

        LogSystem.log(level: .info, message: "\(string)")
    }

    public func addUserProperties(dict: SendableDict) {
        var string = """
📈 Add User Properties
"""

        if printParameters {
            let params = dict.dict
            let sortedKeys = params.keys.sorted()
            for key in sortedKeys {
                if let paramValue = params[key] {
                    string += "\n  (key: \"\(key)\", value: \(paramValue))"
                }
            }
        }

        LogSystem.log(level: .info, message: "\(string)")
    }

    public func deleteUserProfile() {
        let string = """
📈 Delete User Profile
"""

        LogSystem.log(level: .info, message: "\(string)")
    }
}

actor LogSystem {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ConsoleLogger")

    static let instance = LogSystem()

    nonisolated static func log(level: LogType, message: String) {
        let level = level.OSLogType
        Task {
            await LogSystem.instance.log(level: level, message: message)
        }
    }

    private func log(level: OSLogType, message: String) {
        logger.log(level: level, "\(message)")
    }
}

fileprivate extension LogType {
    var OSLogType: OSLogType {
        switch self {
        case .info:
            return .info
        case .analytic:
            return .default
        case .warning:
            return .fault
        case .severe:
            return .error
        }
    }
}
