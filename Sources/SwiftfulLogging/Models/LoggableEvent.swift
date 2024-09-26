//
//  LoggableEvent.swift
//  SwiftfulLogging
//
//  Created by Nick Sarno on 9/25/24.
//

public protocol LoggableEvent: Sendable {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
    var type: LogType { get }
}
