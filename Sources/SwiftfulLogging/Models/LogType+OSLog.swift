//
//  LogType+OSLog.swift
//  SwiftfulLogging
//
//  Created by Nick Sarno on 10/25/24.
//
import OSLog

extension LogType {
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
