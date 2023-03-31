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

    @AppStorage("provider") var selectedProvider: Int = 0
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
                    Picker(selection: $selectedProvider, label: Text("Providers")) {
                        Text("Zoom").tag(0)
                        Text("Google Meet").tag(1)
                    }
                }
            }
            .padding(15)
            .frame(height: 20)
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
