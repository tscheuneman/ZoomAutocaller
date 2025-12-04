//
//  Meetings.swift
//  ZoomAutocaller
//
//  Created by Thomas Scheuneman on 7/29/21.
//

import Foundation
import EventKit

let meetings = Meetings()

class Meetings {
    var meetings: [Meeting];
    private var handledMeetingKeys: [String: Date]
    private let handledRetentionWindow: TimeInterval = 60 * 60 * 6 // 6 hours
    
    init() {
        meetings = []
        handledMeetingKeys = [:]
    }
    
    public func clearMeetings() {
        meetings = []
    }
    
    public func resetAll() {
        meetings = []
        handledMeetingKeys = [:]
    }
    
    public func exists(link: String, time: Date) -> Bool {
        let results = self.meetings.filter { $0.time == time && $0.zoomLink.absoluteString == link }
        return results.count > 0
    }
    
    public func getCurrentMeetings() -> [Meeting] {
        let currentDate = Date(timeIntervalSinceNow: -30)
        let oneMinLater = Date(timeIntervalSinceNow: 40)
        let returnMeetings: [Meeting] = self.meetings.filter { $0.time >= currentDate && $0.time <= oneMinLater }
        
        self.meetings = Array(Set(self.meetings).subtracting(returnMeetings))
        markMeetingsHandled(returnMeetings)
        
        return returnMeetings
    }
    
    public func addMeeting(resolvedUrl: String, event: EKEvent) {
        let meeting = Meeting(time: event.startDate, title: event.title, zoomLink: resolvedUrl);
        if handledMeetingKeys[meeting.uniqueKey] != nil {
            return
        }
        
        if(!self.exists(link: resolvedUrl, time: event.startDate)) {
            self.meetings.append(meeting)
        }
    }
    
    private func markMeetingsHandled(_ meetings: [Meeting]) {
        for meeting in meetings {
            handledMeetingKeys[meeting.uniqueKey] = meeting.time
        }
        purgeHandledMeetings()
    }
    
    private func purgeHandledMeetings() {
        let cutoff = Date(timeIntervalSinceNow: -handledRetentionWindow)
        handledMeetingKeys = handledMeetingKeys.reduce(into: [:]) { result, entry in
            if entry.value >= cutoff {
                result[entry.key] = entry.value
            }
        }
    }
}
