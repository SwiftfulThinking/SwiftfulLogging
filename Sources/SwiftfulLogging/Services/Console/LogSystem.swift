//
//  LogSystem.swift
//  SwiftfulLogging
//
//  Created by Nick Sarno on 10/25/24.
//
import Foundation
import OSLog

/// Protocol defining the interface for logging systems
public protocol LogSystem: Sendable {
    /// Logs a message with the specified log level
    /// - Parameters:
    ///   - level: The LogType indicating the severity of the message
    ///   - message: The message to log
    func log(level: LogType, message: String)
}

/// Types of available logging systems
public enum LogSystemType {
    case osLog
    case stdout

    /// Creates the appropriate LogSystem implementation
    func createSystem() -> any LogSystem {
        switch self {
        case .osLog:
            return OSLogSystem()
        case .stdout:
            return STDLogSystem()
        }
    }
}

/// Default implementation using Apple's OSLog framework
actor OSLogSystem: LogSystem {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ConsoleLogger")

    private func log(level: OSLogType, message: String) {
        logger.log(level: level, "\(message)")
    }

    nonisolated func log(level: LogType, message: String) {
        Task {
            await log(level: level.OSLogType, message: message)
        }
    }
}

/// Implementation using standard output (print statements)
actor STDLogSystem: LogSystem {
    private func logToStdout(message: String) {
        print(message)
    }
    
    nonisolated func log(level: LogType, message: String) {
        Task {
            await logToStdout(message: message)
        }
    }
}
