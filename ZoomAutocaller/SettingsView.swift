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
    @State private var schedule = NotificationScheduleStore.load()

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
                    self.statusBar.playSound(ignoreSchedule: true)
                }
            }
            .padding(5)
            Divider()
            .padding(5)
            ScheduleSection(schedule: $schedule)
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
        .padding(.vertical, 24)
        .onChange(of: schedule) { newValue in
            NotificationScheduleStore.save(newValue)
        }
    }
}

struct ScheduleSection: View {
    @Binding var schedule: NotificationSchedule
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ringtone Schedule")
                .font(.headline)
            Text("Choose the days and time windows when Zoom Autocaller is allowed to ring.")
                .font(.caption)
                .foregroundColor(.secondary)
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Weekday.allCases) { weekday in
                        DailyScheduleRow(weekday: weekday, schedule: $schedule)
                            .padding(.vertical, 4)
                        Divider()
                    }
                }
            }
            .frame(height: 170)
        }
        .padding(12)
    }
}

struct DailyScheduleRow: View {
    let weekday: Weekday
    @Binding var schedule: NotificationSchedule
    
    var body: some View {
        let dayBinding = Binding<DailySchedule>(
            get: { schedule.schedule(for: weekday) },
            set: { schedule.setSchedule($0, for: weekday) }
        )
        
        let enabledBinding = Binding<Bool>(
            get: { dayBinding.wrappedValue.enabled },
            set: {
                var updated = dayBinding.wrappedValue
                updated.enabled = $0
                dayBinding.wrappedValue = updated
            }
        )
        
        let startBinding = Binding<Date>(
            get: { dayBinding.wrappedValue.startDate },
            set: {
                var updated = dayBinding.wrappedValue
                updated.startDate = $0
                dayBinding.wrappedValue = updated
            }
        )
        
        let endBinding = Binding<Date>(
            get: { dayBinding.wrappedValue.endDate },
            set: {
                var updated = dayBinding.wrappedValue
                updated.endDate = $0
                dayBinding.wrappedValue = updated
            }
        )
        
        return VStack(alignment: .leading, spacing: 4) {
            Toggle(isOn: enabledBinding) {
                Text(weekday.displayName)
            }
            HStack {
                Text("From")
                DatePicker("", selection: startBinding, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                Text("to")
                DatePicker("", selection: endBinding, displayedComponents: .hourAndMinute)
                    .labelsHidden()
            }
            .font(.caption)
            .opacity(dayBinding.wrappedValue.enabled ? 1 : 0.4)
            .disabled(!dayBinding.wrappedValue.enabled)
        }
    }
}
