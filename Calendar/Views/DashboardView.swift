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
                ZStack {
                    Color.white
                    Text("Today's Tasks")
                }
                ZStack {
                    Color.white
                    Text("Leaderboard")
                }
            }
            .background(Color.teal)
    }
}

#Preview {
    DashboardView()
}

