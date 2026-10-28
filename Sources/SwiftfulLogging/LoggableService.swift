import Foundation

/// Which user properties a service should receive. Configured per service at
/// `LogManager` composition time, so services don't filter internally.
public enum LogUserPropertyType: Sendable {
    /// Receives no user properties.
    case none
    /// Receives only properties added with `isHighPriority == true`. Use for
    /// services with low user-property limits (e.g. Firebase, Crashlytics).
    case highPriorityOnly
    /// Receives all user properties.
    case all
}

/// A `LogService` paired with the routing it should receive: which event
/// `LogType`s, and which user properties. Both default to "nothing" so routing
/// is always explicit and opt-in.
public struct LoggableService {

    let service: any LogService
    let allowedEventTypes: Set<LogType>
    let allowedUserPropertyTypes: LogUserPropertyType

    public init(
        _ service: any LogService,
        allowedEventTypes: [LogType] = [],
        allowedUserPropertyTypes: LogUserPropertyType = .none
    ) {
        self.service = service
        self.allowedEventTypes = Set(allowedEventTypes)
        self.allowedUserPropertyTypes = allowedUserPropertyTypes
    }

    func allowsEvent(_ type: LogType) -> Bool {
        allowedEventTypes.contains(type)
    }

    func allowsUserProperties(isHighPriority: Bool) -> Bool {
        switch allowedUserPropertyTypes {
        case .none:             return false
        case .highPriorityOnly: return isHighPriority
        case .all:              return true
        }
    }
}
