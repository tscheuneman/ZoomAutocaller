//
//  ZoomAutocallerTests.swift
//  ZoomAutocallerTests
//
//  Created by Thomas Scheuneman on 7/29/21.
//

import XCTest
import EventKit
@testable import ZoomAutocaller

final class ZoomAutocallerTests: XCTestCase {
    private var eventStore: EKEventStore!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        eventStore = EKEventStore()
        meetings.resetAll()
        nextMeeting.clearMeetings()
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "useZoom")
        defaults.set(true, forKey: "useGoogle")
    }
    
    override func tearDownWithError() throws {
        eventStore = nil
        meetings.resetAll()
        nextMeeting.clearMeetings()
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "useZoom")
        defaults.removeObject(forKey: "useGoogle")
        try super.tearDownWithError()
    }
    
    func testMeetingEqualityAndHashValue() {
        let date = Date()
        let meetingA = Meeting(time: date, title: "Standup", zoomLink: "https://zoom.us/j/xyz")
        let meetingB = Meeting(time: date, title: "Standup", zoomLink: "https://zoom.us/j/xyz")
        let meetingC = Meeting(time: date.addingTimeInterval(60), title: "Retro", zoomLink: "https://zoom.us/j/xyz")
        
        XCTAssertEqual(meetingA, meetingB)
        XCTAssertEqual(meetingA.hashValue, meetingB.hashValue)
        XCTAssertNotEqual(meetingA, meetingC)
        XCTAssertNotEqual(meetingA.uniqueKey, meetingC.uniqueKey)
    }
    
    func testFindUrlsReturnsFirstSupportedProvider() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "useZoom")
        defaults.set(false, forKey: "useGoogle")
        let text = "Join us https://zoom.us/j/12345 and https://meet.google.com/abc"
        
        let resolved = findUrls(text: text)
        
        XCTAssertEqual(resolved, "https://zoom.us/j/12345")
    }
    
    func testFindUrlsRespectsProviderSettings() {
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "useZoom")
        defaults.set(false, forKey: "useGoogle")
        let text = "Dial in https://zoom.us/j/12345"
        
        XCTAssertEqual(findUrls(text: text), "")
        
        defaults.set(true, forKey: "useGoogle")
        let googleText = "https://meet.google.com/room123"
        XCTAssertEqual(findUrls(text: googleText), "https://meet.google.com/room123")
    }
    
    func testFindMatchingUrlHonorsProviderToggles() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "useZoom")
        defaults.set(false, forKey: "useGoogle")
        
        XCTAssertTrue(findMatchingUrl(url: "https://zoom.us/j/12345"))
        XCTAssertFalse(findMatchingUrl(url: "https://meet.google.com/room123"))
        
        defaults.set(true, forKey: "useGoogle")
        XCTAssertTrue(findMatchingUrl(url: "https://meet.google.com/room123"))
    }
    
    func testNextMeetingWriteAndClear() {
        let meeting = Meeting(time: Date(), title: "Planning", zoomLink: "https://zoom.us/j/123")
        nextMeeting.write(meetings: [meeting])
        
        XCTAssertTrue(nextMeeting.hasMeetings())
        XCTAssertEqual(nextMeeting.getMeetings().first?.title, "Planning")
        
        nextMeeting.clearMeetings()
        XCTAssertFalse(nextMeeting.hasMeetings())
    }
    
    func testMeetingsAddsUniqueEventsOnlyOnce() {
        let startDate = Date(timeIntervalSinceNow: 10)
        let event = makeEvent(title: "Daily", startDate: startDate)
        
        meetings.addMeeting(resolvedUrl: "https://zoom.us/j/111", event: event)
        meetings.addMeeting(resolvedUrl: "https://zoom.us/j/111", event: event)
        
        XCTAssertEqual(meetings.meetings.count, 1)
    }
    
    func testGetCurrentMeetingsReturnsAndRemovesEvents() {
        let startDate = Date(timeIntervalSinceNow: 10)
        let event = makeEvent(title: "Check-in", startDate: startDate)
        meetings.addMeeting(resolvedUrl: "https://zoom.us/j/234", event: event)
        
        let current = meetings.getCurrentMeetings()
        XCTAssertEqual(current.count, 1)
        XCTAssertEqual(current.first?.title, "Check-in")
        
        let secondPull = meetings.getCurrentMeetings()
        XCTAssertTrue(secondPull.isEmpty)
    }
    
    func testHandledMeetingNotRequeuedAfterRefresh() {
        let startDate = Date(timeIntervalSinceNow: 5)
        let event = makeEvent(title: "1:1", startDate: startDate)
        meetings.addMeeting(resolvedUrl: "https://zoom.us/j/789", event: event)
        
        XCTAssertEqual(meetings.getCurrentMeetings().count, 1)
        meetings.addMeeting(resolvedUrl: "https://zoom.us/j/789", event: event)
        
        XCTAssertTrue(meetings.getCurrentMeetings().isEmpty)
        XCTAssertEqual(meetings.meetings.count, 0)
    }
    
    // MARK: - Helpers
    
    private func makeEvent(title: String, startDate: Date) -> EKEvent {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = startDate.addingTimeInterval(600)
        return event
    }
}
