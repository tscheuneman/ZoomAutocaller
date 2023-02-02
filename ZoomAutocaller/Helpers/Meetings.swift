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
    
    init() {
        meetings = []
    }
    
    public func clearMeetings() {
        meetings = []
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
        
        return returnMeetings
    }
    
    public func addMeeting(resolvedUrl: String, event: EKEvent) {
        if(!self.exists(link: resolvedUrl, time: event.startDate)) {
            let meeting = Meeting(time: event.startDate, title: event.title, zoomLink: resolvedUrl);
            
            meetings.append(meeting)
        }
    }
}
