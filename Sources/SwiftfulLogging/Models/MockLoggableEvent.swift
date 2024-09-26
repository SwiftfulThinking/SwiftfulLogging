//
//  MockLoggableEvent.swift
//  SwiftfulLogging
//
//  Created by Nick Sarno on 9/25/24.
//
import SendableDictionary

public struct AnyLoggableEvent: LoggableEvent {
    public var eventName: String
    public var type: LogType

    public var parameters: [String : Any]? {
        sendableDict?.dict
    }

    private var sendableDict: SendableDict?

    public init(eventName: String, parameters: [String : Any]? = nil, type: LogType = .analytic) {
        self.eventName = eventName
        self.sendableDict = parameters?.sendable()
        self.type = type
    }
}

