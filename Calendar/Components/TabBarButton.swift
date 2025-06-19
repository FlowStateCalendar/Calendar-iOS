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
            VStack(spacing: 0) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(selectedTab == tab ? .black : .gray)
            }
            .frame(height: 32)
            .frame(maxWidth: .infinity)
            
        }
    }
}
