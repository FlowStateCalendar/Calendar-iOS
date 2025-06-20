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
        GeometryReader { geometry in
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
                        AquariumView()
                    case .settings:
                        SettingsView()
                    }
                }
                
                // Tab Bar
                HStack {
                    TabBarButton(icon: "house", tab: .home, selectedTab: $selectedTab)
                    TabBarButton(icon: "calendar", tab: .calendar, selectedTab: $selectedTab)
                    TabBarButton(icon: "list.clipboard", tab: .tasks, selectedTab: $selectedTab)
                    TabBarButton(icon: "gamecontroller", tab: .game, selectedTab: $selectedTab)
                    TabBarButton(icon: "gear", tab: .settings, selectedTab: $selectedTab)
                }
                .padding(.top, 10)
                .padding(.bottom, 2)
                .padding(.horizontal, 20)
                .background(Color.white.ignoresSafeArea(edges: .bottom))
                .frame(maxWidth: .infinity)
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: -1)
            }
        }
    }
}

#Preview {
    CustomTabBarView()
}
