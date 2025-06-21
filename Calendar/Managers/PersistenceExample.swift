////
////  PersistenceExample.swift
////  Calendar
////
////  Created by Rhyse Summers on 10/06/2025.
////
//
//import SwiftUI
//
//// MARK: - Persistence Strategy Example
//class PersistenceExample {
//    
//    // MARK: - UserDefaults Example (Recommended for your use case)
//    static func userDefaultsExample() {
//        let storageManager = StorageManager.shared
//        
//        // Create a user
//        let user = UserModel(name: "John Doe", email: "john@example.com")
//        user.addTask(TaskModel(
//            name: "Morning Workout",
//            description: "30-minute cardio",
//            frequency: .none,
//            category: .health,
//            energy: 4,
//            taskDate: Date()
//        ))
//        
//        // Save user
//        storageManager.saveUser(user)
//        
//        // Load user later
//        if let loadedUser = storageManager.loadUser() {
//            print("Loaded user: \(loadedUser.name)")
//        }
//        
//        // Check login state
//        if storageManager.isUserLoggedIn() {
//            print("User is logged in")
//        }
//    }
//    
//    // MARK: - Keychain Example (For sensitive data)
//    static func keychainExample() {
//        let keychainManager = KeychainManager.shared
//        
//        // Save authentication token
//        keychainManager.saveAuthToken("your-secure-token-here")
//        
//        // Load token later
//        if let token = keychainManager.getAuthToken() {
//            print("Auth token: \(token)")
//        }
//    }
//}
//
//// MARK: - Usage in Views
//struct LoginView: View {
//    @EnvironmentObject var user: UserModel
//    @EnvironmentObject var appState: AppState
//    @EnvironmentObject var storageManager: StorageManager
//    
//    var body: some View {
//        VStack {
//            Text("Login")
//            
//            Button("Login with Google") {
//                // After successful login
//                user.name = "John Doe"
//                user.email = "john@example.com"
//                
//                // Save user data
//                storageManager.saveUser(user)
//                
//                // Update app state
//                appState.setLoggedIn(true)
//            }
//        }
//    }
//}
//
//struct LogoutView: View {
//    @EnvironmentObject var appState: AppState
//    
//    var body: some View {
//        Button("Logout") {
//            appState.logout()
//        }
//    }
//} 
