//
//  ContentView.swift
//  Calendar
//
//  Created by Rhyse Summers on 05/06/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            //Portrait and landscape?
            Color(red: 0.4627, green: 0.8392, blue: 1.0)
                .ignoresSafeArea()
            
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
        }//.ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
