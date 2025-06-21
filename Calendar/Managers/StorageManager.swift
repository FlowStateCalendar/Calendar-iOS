//
//  StorageManager.swift
//  Calendar
//
//  Created by Rhyse Summers on 10/06/2025.
//

import Foundation
import SwiftUI

class StorageManager: ObservableObject {
    static let shared = StorageManager()
    
    private let userDefaults = UserDefaults.standard
    
    // MARK: - User Data Keys
    private enum Keys {
        static let userData = "userData"
        static let isLoggedIn = "isLoggedIn"
        static let userEmail = "userEmail"
        static let userName = "userName"
    }
    
    private init() {}
    
    // MARK: - User Persistence
    func saveUser(_ user: UserModel) {
        do {
            let userData = try JSONEncoder().encode(user)
            userDefaults.set(userData, forKey: Keys.userData)
            userDefaults.set(true, forKey: Keys.isLoggedIn)
            userDefaults.set(user.email, forKey: Keys.userEmail)
            userDefaults.set(user.name, forKey: Keys.userName)
        } catch {
            print("Error saving user: \(error)")
        }
    }
    
    func loadUser() -> UserModel? {
        guard let userData = userDefaults.data(forKey: Keys.userData) else {
            return nil
        }
        
        do {
            let user = try JSONDecoder().decode(UserModel.self, from: userData)
            return user
        } catch {
            print("Error loading user: \(error)")
            return nil
        }
    }
    
    func isUserLoggedIn() -> Bool {
        return userDefaults.bool(forKey: Keys.isLoggedIn)
    }
    
    func clearUserData() {
        userDefaults.removeObject(forKey: Keys.userData)
        userDefaults.removeObject(forKey: Keys.isLoggedIn)
        userDefaults.removeObject(forKey: Keys.userEmail)
        userDefaults.removeObject(forKey: Keys.userName)
    }
    
    // MARK: - Quick Access Methods
    func getStoredUserEmail() -> String? {
        return userDefaults.string(forKey: Keys.userEmail)
    }
    
    func getStoredUserName() -> String? {
        return userDefaults.string(forKey: Keys.userName)
    }
}
