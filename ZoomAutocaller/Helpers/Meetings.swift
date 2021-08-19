//
//  Meetings.swift
//  ZoomAutocaller
//
//  Created by Thomas Scheuneman on 7/29/21.
//

import Foundation

let meetings = Meetings()

class Meetings {
    var meetings: [Meeting];
    
    init() {
        meetings = Array()
    }
    
    public func addMeeting(meeting: Meeting) {
        meetings.append(meeting)
    }
    
    public func exists(link: String, time: Date) -> Bool {
        let results = self.meetings.filter { $0.time == time && $0.zoomLink.absoluteString == link }
        return results.count > 0
    }
    
    public func getCurrentMeetings(start: Date, end: Date) -> [Meeting] {
        let returnMeetings: [Meeting] = self.meetings.filter { $0.time >= start && $0.time <= end }
        
        self.meetings = Array(Set(self.meetings).subtracting(returnMeetings))
        
        return returnMeetings
    }
}
