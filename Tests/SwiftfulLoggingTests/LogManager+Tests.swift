import Testing
import SendableDictionary
@testable import SwiftfulLogging

@MainActor
struct LogManagerTests {

    @Test("LogManager tracks event and forwards the call to all services")
    func testTrackEvent() throws {
        // Given
        let mockService1 = MockLogService()
        let mockService2 = MockLogService()
        let logManager = LogManager(services: [mockService1, mockService2])
        let event = AnyLoggableEvent(eventName: "Test Event", parameters: ["key": "value"], type: .info)

        // When
        logManager.trackEvent(event: event)

        // Then
        #expect(mockService1.lastTrackedEvent?.eventName == "Test Event")
        #expect(mockService2.lastTrackedEvent?.eventName == "Test Event")
    }

    @Test("LogManager tracks screen view and forwards the call to all services")
    func testTrackScreenView() throws {
        // Given
        let mockService1 = MockLogService()
        let mockService2 = MockLogService()
        let logManager = LogManager(services: [mockService1, mockService2])
        let event = AnyLoggableEvent(eventName: "Screen Viewed", parameters: ["screen": "Home"], type: .analytic)

        // When
        logManager.trackScreenView(event: event)

        // Then
        #expect(mockService1.lastTrackedScreenView?.eventName == "Screen Viewed")
        #expect(mockService2.lastTrackedScreenView?.eventName == "Screen Viewed")
    }

    @Test("LogManager identifies user and forwards the call to all services")
    func testIdentifyUser() throws {
        // Given
        let mockService1 = MockLogService()
        let mockService2 = MockLogService()
        let logManager = LogManager(services: [mockService1, mockService2])

        // When
        logManager.identifyUser(userId: "user123", name: "John Doe", email: "john.doe@example.com")

        // Then
        #expect(mockService1.lastIdentifiedUser?.userId == "user123")
        #expect(mockService2.lastIdentifiedUser?.userId == "user123")
    }

    @Test("LogManager adds user properties and forwards the call to all services")
    func testAddUserProperties() throws {
        // Given
        let mockService1 = MockLogService()
        let mockService2 = MockLogService()
        let logManager = LogManager(services: [mockService1, mockService2])
        let dict: [String: Any] = ["property1": "value1", "property2": "value2"]
        let sendableDict = SendableDict(dict: dict)

        // When
        logManager.addUserProperties(dict: sendableDict)

        // Then
        #expect(mockService1.lastAddedUserProperties?.dict["property1"] as? String == "value1")
        #expect(mockService2.lastAddedUserProperties?.dict["property1"] as? String == "value1")
    }

    @Test("LogManager deletes user profile and forwards the call to all services")
    func testDeleteUserProfile() throws {
        // Given
        let mockService1 = MockLogService()
        let mockService2 = MockLogService()
        let logManager = LogManager(services: [mockService1, mockService2])

        // When
        logManager.deleteUserProfile()

        // Then
        #expect(mockService1.didDeleteUserProfile == true)
        #expect(mockService2.didDeleteUserProfile == true)
    }
}

class MockLogService: @unchecked Sendable, LogService  {
    var lastTrackedEvent: LoggableEvent?
    var lastTrackedScreenView: LoggableEvent?
    var lastIdentifiedUser: (userId: String, name: String?, email: String?)?
    var lastAddedUserProperties: SendableDict?
    var didDeleteUserProfile = false

    func trackEvent(event: LoggableEvent) {
        lastTrackedEvent = event
    }

    func trackScreenView(event: LoggableEvent) {
        lastTrackedScreenView = event
    }

    func identifyUser(userId: String, name: String?, email: String?) {
        lastIdentifiedUser = (userId, name, email)
    }

    func addUserProperties(dict: SendableDict) {
        lastAddedUserProperties = dict
    }

    func deleteUserProfile() {
        didDeleteUserProfile = true
    }
}
