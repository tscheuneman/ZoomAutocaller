//
//  Meeting.swift
//  ZoomAutocaller
//
//  Created by Thomas Scheuneman on 7/29/21.
//

import Foundation

class Meeting: Hashable {
    var time: Date
    var title: String
    var zoomLink: URL
    
    /// Uniquely identifies a meeting using the scheduled time and url.
    var uniqueKey: String {
        return "\(time.timeIntervalSince1970)#\(zoomLink.absoluteString)"
    }
    
    init(time: Date, title: String, zoomLink: String) {
        self.time = time
        self.title = title
        self.zoomLink = URL(string: zoomLink) ?? URL(string: "https://google.com")!
    }
    
    func getTitle() -> String {
        return self.title;
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(time);
        hasher.combine(title)
    }
    
    static func == (lhs: Meeting, rhs: Meeting) -> Bool {
        let areEqual = lhs.time == rhs.time &&
            lhs.zoomLink == rhs.zoomLink

        return areEqual
    }
}
