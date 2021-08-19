//
//  NewMeeting.swift
//  ZoomAutocaller
//
//  Created by Thomas Scheuneman on 8/5/21.
//

import Foundation

let nextMeeting = NextMeeting()

class NextMeeting {
    var meetings: [Meeting] = [];
    
    init() {
    }
    
    public func write(meetings: [Meeting]) {
        self.meetings = meetings
    }
    
    public func getMeetings() -> [Meeting] {
        return self.meetings
    }
}
