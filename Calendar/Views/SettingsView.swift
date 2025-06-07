//
//  SettingsView.swift
//  Calendar
//
//  Created by Rhyse Summers on 06/06/2025.
//

import SwiftUI

struct SettingsView: View {
    @State private var emailAlerts = true
        @State private var pushNotifications = false
        @State private var selectedLanguage = "English"

    var body: some View {
        ZStack {
            // Background Color
            Color.teal
                .ignoresSafeArea()
            
            //Expandable settings tabs
            ScrollView {
                VStack(spacing: 12) {
                    //Page title
                    Text("App Settings")
                    
                    ExpandableSection(title: "General") {
                        
                    }
                    
                    ExpandableSection(title: "Audio (move to general?)") {
                        
                    }
                    
                    ExpandableSection(title: "Notifications") {
                        VStack(alignment: .leading) {
                            Toggle("Email Alerts", isOn: $emailAlerts)
                            Toggle("Push Notifications", isOn: $pushNotifications)
                        }
                    }
                    
                    ExpandableSection(title: "Dashboard") {
                        
                    }
                    
                    ExpandableSection(title: "Calendar") {
                        
                    }
                    
                    ExpandableSection(title: "Tasks") {
                        
                    }
                    
                    ExpandableSection(title: "Game") {
                        
                    }
                    
                    ExpandableSection(title: "Account") {
                        VStack(alignment: .leading) {
                            Text("Email: user@example.com")
                            Button("Sign Out", role: .destructive) {
                                // Sign out action
                            }
                        }
                    }
                    
                }
                .padding(.top)
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
