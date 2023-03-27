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
    @State private var score = volume
    @State private var focused = false
    @State private var selectedProvider = provider
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
                TextField("Enter your score", value: $score, formatter: formatter)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onReceive(Just(score)) { newValue in
                        if(newValue != volume) {
                            volume = newValue
                            self.statusBar.changedSetting()
                            DispatchQueue.main.async {
                                NSApp.keyWindow?.makeFirstResponder(nil)
                            }
                        }
                    }
                    .focusable(focused)
                
            }
            .padding(15)
            .frame(height: 20)
            HStack {
                VStack {
                    if #available(macOS 11.0, *) {
                        Picker(selection: $selectedProvider, label: Text("Providers")) {
                            Text("Zoom").tag(0)
                            Text("Google Meet").tag(1)
                        }
                        .onChange(of: selectedProvider) { _ in provider = selectedProvider }
                    } else {
                        // Fallback on earlier versions
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
