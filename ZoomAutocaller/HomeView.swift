//
//  ContentView.swift
//  ZoomAutocaller
//
//  Created by Thomas Scheuneman on 7/29/21.
//

import SwiftUI
import Foundation
import Combine

struct HomeView: View {
    @State var settingView = false;
    @State var statusBar: StatusBarController
    init(_ statusBar: StatusBarController) {
        self.statusBar = statusBar;
    }
    var body: some View {
        VStack {
            if self.settingView {
                SettingsView(buttonClick: $settingView, statusBar: $statusBar)
            } else {
                ContentView(buttonClick: $settingView, statusBar: $statusBar)
            }
        }
    }
}
