//
//  Untitled.swift
//  SwiftfulLogging
//
//  Created by Nick Sarno on 9/25/24.
//

import Foundation
import OSLog
import SendableDictionary

struct ConsoleLogger: LogService {

    var printParameters: Bool = true

    func trackEvent(event: LoggableEvent) {
        var value = "\(event.type.emoji) \(event.eventName)"
        if printParameters, let params = event.parameters, !params.isEmpty {
            for param in params {
                value += "\n  \(param)"
            }
        }

        LogSystem.log(level: event.type, message: "\(value)")
    }

    func trackScreenView(event: any LoggableEvent) {
        trackEvent(event: event)
    }

    func identifyUser(userId: String, name: String?, email: String?) {
        let string = """
📈 Identify User
  userId: \(userId)
  name: \(name ?? "unknown")
  email: \(email ?? "unknown")
"""

        LogSystem.log(level: .info, message: "\(string)")

    }

    func addUserProperties(dict: SendableDict) {
        var string = """
📈 Log User Properties
"""

        for attribute in dict.dict {
            string += "\n  \(attribute)"
        }

        LogSystem.log(level: .info, message: "\(string)")
    }

    func deleteUserProfile() {
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
