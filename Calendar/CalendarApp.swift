//
//  CalendarApp.swift
//  Calendar
//
//  Created by Rhyse Summers on 05/06/2025.
//

import GoogleSignIn
import SwiftUI

@main
struct CalendarApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var user = UserModel(name: "", email: "")
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(user)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        
        }
    }
}
