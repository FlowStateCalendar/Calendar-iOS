//
//  DashboardView.swift
//  Calendar
//
//  Created by Rhyse Summers on 06/06/2025.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var storageManager: StorageManager
    @EnvironmentObject var user: UserModel
    
    var body: some View {
            VStack {
                UserBar()
                Text("Hi, \(user.name.isEmpty ? "User" : user.name)!")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.top, 8)
                
                Button("Logout"){
                    storageManager.clearUserData()
                    print("User data cleared")
                    user.logout()
                    appState.isLoggedIn = false
                    print("User logged out")
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.8))
                .cornerRadius(8)

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
        .environmentObject(StorageManager.shared)
        .environmentObject(UserModel(name: "John Doe", email: "john@example.com"))
}
