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
    //@StateObject private var user = UserModel(name: "", email: "")
    @StateObject private var user: UserModel
    @StateObject private var storageManager = StorageManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    
    init() {
        // Try to load existing user data, or create a new user
        if let savedUser = StorageManager.shared.loadUser() {
            _user = StateObject(wrappedValue: savedUser)
        } else {
            _user = StateObject(wrappedValue: UserModel(name: "", email: ""))
        }
        // Request notification permission and update status on app launch
        NotificationManager.shared.requestNotificationPermission()
        NotificationManager.shared.updateAuthorizationStatus()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(user)
                .environmentObject(storageManager)
                .environmentObject(notificationManager)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    // Save user data when app goes to background
                    if !user.name.isEmpty && !user.email.isEmpty {
                        storageManager.saveUser(user)
                    }
                }
        }
    }
}
