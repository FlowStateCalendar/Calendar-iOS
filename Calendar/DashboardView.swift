//
//  DashboardView.swift
//  Calendar
//
//  Created by Rhyse Summers on 06/06/2025.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
            VStack {
                UserBar()
                Text("Date Bubbles")
                ZStack {
                    Color.white
                    Text("Calendar")
                }
                ZStack {
                    Color.white
                    Text("Leaderboard")
                }
            }
    }
}

#Preview {
    DashboardView()
}

