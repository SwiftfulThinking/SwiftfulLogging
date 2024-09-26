//
//  LogType.swift
//  SwiftfulLogging
//
//  Created by Nick Sarno on 9/25/24.
//
import Foundation

public enum LogType: Int, CaseIterable, Sendable {
    /// Use 'info' for informative tasks, such as tracking functions. These logs should not be considered issues or errors.
    case info // 0
    /// Use 'analytic'' for all analytic events.
    case analytic // 1
    /// Use 'warning' for issues or errors that should not occur, but will not negatively affect user experience.
    case warning // 2
    /// Use 'severe' for issues or errors that will negatively affect user experience, such as crashes or failing scenarios. Production builds should not have any 'severe' occurrences.
    case severe // 3

    var emoji: String {
        switch self {
        case .info:
            return "👋"
        case .analytic:
            return "📈"
        case .warning:
            return "⚠️"
        case .severe:
            return "🚨"
        }
    }

    var asString: String {
        switch self {
        case .info: return "info"
        case .analytic: return "analytic"
        case .warning: return "warning"
        case .severe: return "severe"
        }
    }
}
