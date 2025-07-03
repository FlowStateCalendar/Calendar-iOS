//
//  ContentView.swift
//  Calendar
//
//  Created by Rhyse Summers on 05/06/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            
            CustomTabBarView()
            
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(UserModel(name: "Test User", email: "test@example.com"))
}
