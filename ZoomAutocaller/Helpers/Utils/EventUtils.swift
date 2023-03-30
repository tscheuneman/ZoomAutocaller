//
//  EventUtils.swift
//  ZoomAutocaller
//
//  Created by Thomas Scheuneman on 2/1/23.
//

import Foundation
import EventKit

let providers: [String] = [
    "zoom.us",
    "meet.google.com"
]

let types: NSTextCheckingResult.CheckingType = .link

let detector = try! NSDataDetector(types: types.rawValue)

var volume = Float(100)
var provider = 0

func findUrls(text: String) -> String {
    let matches = detector.matches(in: text, options: [], range: NSMakeRange(0, text.count))

    var resolvedUrl: String = ""
    for match in matches {
        let zoomUrl = match.url?.absoluteString ?? "";
        if(zoomUrl.contains(providers[provider])) {
            resolvedUrl = zoomUrl
            break
        }
    }
    
    return resolvedUrl
}

func findEvents(eventStore: EKEventStore, calendars: [EKCalendar]) -> [EKEvent] {
    let minusOneHOur = Date(timeIntervalSinceNow: 0)
    let plusOneHour = Date(timeIntervalSinceNow: 3600)
    
    
    let predicate = eventStore.predicateForEvents(withStart: minusOneHOur, end: plusOneHour, calendars: calendars)

    return eventStore.events(matching: predicate)
}

