//
//  DashboardView.swift
//  Calendar
//
//  Created by Rhyse Summers on 06/06/2025.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        ZStack {
            
            Color(red: 0.4627, green: 0.8392, blue: 1.0)
            
            VStack {
                Text("Icon Bar")
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
}

