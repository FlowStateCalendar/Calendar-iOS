//
//  CustomTabBar.swift
//  Calendar
//
//  Created by Rhyse Summers on 06/06/2025.
//

import SwiftUI

enum Tab {
    case home
    case calendar
    case tasks
    case game
    case settings
}

struct CustomTabBarView: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content
            Group {
                switch selectedTab {
                case .home:
                    DashboardView()
                case .calendar:
                    CalendarView()
                case .tasks:
                    TasksView()
                case .game:
                    Text("Game View")
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            
            // Tab Bar
            HStack {
                TabBarButton(icon: "house", tab: .home, selectedTab: $selectedTab)
                TabBarButton(icon: "calendar", tab: .calendar, selectedTab: $selectedTab)
                TabBarButton(icon: "list.clipboard", tab: .tasks, selectedTab: $selectedTab)
                TabBarButton(icon: "gamecontroller", tab: .game, selectedTab: $selectedTab)
                TabBarButton(icon: "gear", tab: .settings, selectedTab: $selectedTab)
            }
            .padding(.horizontal, 25)
            .padding(.top, 10)
            .padding(.bottom, 20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -2)
            .padding(.horizontal, 10)
        }
        .ignoresSafeArea(.keyboard)
    }
}
