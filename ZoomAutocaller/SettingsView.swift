//
//  ContentView.swift
//  ZoomAutocaller
//
//  Created by Thomas Scheuneman on 7/29/21.
//

import SwiftUI
import Foundation
import Combine

struct SettingsView: View {
    var latestMeetings = nextMeeting.getMeetings()
    @State private var focused = false

    @AppStorage("useZoom") var useZoom: Bool = false
    @AppStorage("useGoogle") var useGoogle: Bool = false
    @AppStorage("ringtone") var seletedRingtone: Int = 0

    @AppStorage("volume") var volume: Double = 100.0
    
    @Binding var buttonClick: Bool
    @Binding var statusBar: StatusBarController

    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimum = 0
        formatter.maximum = 100
        return formatter
    }()

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Volume")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Slider(
                    value: $volume,
                    in: 0...100
                )
            }
            .padding(15)
            .frame(height: 20)
            HStack {
                VStack {
                    Picker(selection: $seletedRingtone, label: Text("Ringtone")) {
                        Text("Phone (Default)").tag(0)
                        Text("Pager").tag(1)
                        Text("Alarm").tag(2)
                        Text("None").tag(3)
                    }
                }
            }
            .padding(10)
            .frame(height: 45)
            HStack {
                Button("Preview") {
                    self.statusBar.playSound()
                }
            }
            .padding(5)
            Divider()
            .padding(5)
            HStack {
                VStack {
                    Toggle(isOn: $useZoom) {
                        Text("Use Zoom")
                    }
                    Toggle(isOn: $useGoogle) {
                        Text("Use Google Meet")
                    }
                }
            }
            .padding(15)
            .frame(height: 45)
            HStack {
                Button(action: { withAnimation { buttonClick.toggle() } }, label: {
                    Text("Meetings")
                })
            }
            .padding(15)
            .frame(height: 20)
        }
        .padding(.vertical)
    }
}
