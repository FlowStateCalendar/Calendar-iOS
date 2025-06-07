//
//  CalendarApp.swift
//  Calendar
//
//  Created by Rhyse Summers on 05/06/2025.
//

import SwiftUI

@main
struct CalendarApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
