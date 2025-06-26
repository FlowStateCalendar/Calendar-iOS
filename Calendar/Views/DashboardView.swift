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

                // Today's Tasks Section
                ZStack {
                    Color.white
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Today's Tasks")
                            .font(.headline)
                            .padding([.top, .horizontal])
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(user.tasks.filter { Calendar.current.isDate($0.taskDate, inSameDayAs: Date()) }) { task in
                                    HStack(spacing: 12) {
                                        Image(systemName: task.category.filledIconName)
                                            .font(.title2)
                                            .foregroundColor(.accentColor)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(task.name)
                                                .font(.body)
                                                .fontWeight(.medium)
                                            Text(task.category.displayName)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        HStack(spacing: 2) {
                                            ForEach(1...task.energy, id: \.self) { _ in
                                                Image(systemName: "bolt.fill")
                                                    .foregroundColor(.yellow)
                                                    .font(.caption)
                                            }
                                        }
                                    }
                                    .padding(8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                }
                                if user.tasks.filter({ Calendar.current.isDate($0.taskDate, inSameDayAs: Date()) }).isEmpty {
                                    Text("No tasks for today!")
                                        .foregroundColor(.secondary)
                                        .padding()
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxHeight: UIScreen.main.bounds.height * 0.4)
                    }
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
