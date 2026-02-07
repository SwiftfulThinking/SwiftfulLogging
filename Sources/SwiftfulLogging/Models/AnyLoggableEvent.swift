//
//  MockLoggableEvent.swift
//  SwiftfulLogging
//
//  Created by Nick Sarno on 9/25/24.
//
public struct AnyLoggableEvent: LoggableEvent {
    public var eventName: String
    public var type: LogType
    public var parameters: [String: Any]?

    public init(eventName: String, parameters: [String : Any]? = nil, type: LogType = .analytic) {
        self.eventName = eventName
        self.parameters = parameters
        self.type = type
    }
}

