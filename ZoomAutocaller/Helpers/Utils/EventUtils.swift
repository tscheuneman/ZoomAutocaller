//
//  EventUtils.swift
//  ZoomAutocaller
//
//  Created by Thomas Scheuneman on 2/1/23.
//

import Foundation
import EventKit

let ringtones = ["ring", "pager", "alarm", ""]

let providers: [String:String] = [
    "ZOOM": "zoom.us",
    "GOOGLE": "meet.google.com"
]

let types: NSTextCheckingResult.CheckingType = .link

let detector = try! NSDataDetector(types: types.rawValue)


func findUrls(text: String) -> String {
    let matches = detector.matches(in: text, options: [], range: NSMakeRange(0, text.count))

    var resolvedUrl: String = ""
    for match in matches {
        let url = match.url?.absoluteString ?? "";
        if(findMatchingUrl(url: url)) {
            resolvedUrl = url
            break
        }
    }
    
    return resolvedUrl
}

func findMatchingUrl(url: String) -> Bool {
    let useZoom = UserDefaults.standard.bool(forKey: "useZoom")
    let useGoogle = UserDefaults.standard.bool(forKey: "useGoogle")

    if(useZoom) {
        if(url.contains(providers["ZOOM"]!)) {
            return true
        }
    }
    
    if(useGoogle) {
        if(url.contains(providers["GOOGLE"]!)) {
            return true
        }
    }
    
    return false
}

func findEvents(eventStore: EKEventStore, calendars: [EKCalendar]) -> [EKEvent] {
    let minusOneHOur = Date(timeIntervalSinceNow: 0)
    let plusOneHour = Date(timeIntervalSinceNow: 3600)
    
    
    let predicate = eventStore.predicateForEvents(withStart: minusOneHOur, end: plusOneHour, calendars: calendars)

    return eventStore.events(matching: predicate)
}

