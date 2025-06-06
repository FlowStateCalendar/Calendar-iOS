//
//  ContentView.swift
//  Calendar
//
//  Created by Rhyse Summers on 05/06/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView{
           DashboardView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Dashboard")
                }
            
            CalendarView()
                 .tabItem {
                     Image(systemName: "calendar")
                     Text("Calendar")
                 }
            
            TasksView()
                 .tabItem {
                     //chart.line.text.clipboard.fill
                     Image(systemName: "list.clipboard.fill")
                     Text("Tasks")
                 }
            	
            Text("Game")
                 .tabItem {
                     Image(systemName: "gamecontroller")
                     Text("Game")
                 }
            
            SettingsView()
                 .tabItem {
                     //gearshape or gear
                     Image(systemName: "gear")
                     Text("Settings")
                 }
        }
    }
}

#Preview {
    ContentView()
}
