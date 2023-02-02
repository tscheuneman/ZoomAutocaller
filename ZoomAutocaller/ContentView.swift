//
//  ContentView.swift
//  ZoomAutocaller
//
//  Created by Thomas Scheuneman on 7/29/21.
//

import SwiftUI
import Foundation
import Combine

struct BlueButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(8)
            .background(Color(red: 3/255, green: 115/255, blue: 200/255, opacity: 100))
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}

struct ContentView: View {
    var latestMeetings = nextMeeting.getMeetings()
    @State private var score = volume
    var statusBar: StatusBarController
    init(_ statusBar: StatusBarController) {
        self.statusBar = statusBar;
    }
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimum = 0
        formatter.maximum = 100
        return formatter
    }()
    var body: some View {
        VStack(spacing: 8) {
            ForEach(latestMeetings, id: \.self) { meeting in
                HStack {
                    Text(meeting.title)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Button("Open") {
                        NSWorkspace.shared.open(meeting.zoomLink)
                        self.statusBar.openedMeeting()
                    }
                    .buttonStyle(BlueButton())
                }
                .padding(15)
                .frame(height: 50)
            }
            Divider()
            HStack {
                Text("Volume")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                TextField("Enter your score", value: $score, formatter: formatter)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onReceive(Just(score)) { newValue in
                        volume = newValue
                    }
                
            }
            .padding(15)
            .frame(height: 20)
        }
        .padding(.vertical)
    }
}
