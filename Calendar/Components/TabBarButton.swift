//
//  TabBarButton.swift
//  Calendar
//
//  Created by Rhyse Summers on 06/06/2025.
//
import SwiftUI

struct TabBarButton: View {
    let icon: String
    let tab: Tab
    @Binding var selectedTab: Tab

    var body: some View {
        Button(action: {
            withAnimation {
                selectedTab = tab
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(selectedTab == tab ? .black : .gray)
                
                Circle()
                    .fill(selectedTab == tab ? Color.black : Color.clear)
                    .frame(width: 6, height: 6)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
