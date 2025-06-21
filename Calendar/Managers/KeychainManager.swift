////
////  KeychainManager.swift
////  Calendar
////
////  Created by Rhyse Summers on 10/06/2025.
////
//
//import Foundation
//import Security
//import SwiftUI
//
//class KeychainManager: ObservableObject {
//    static let shared = KeychainManager()
//    
//    private let service = "com.calendar.app"
//    
//    private init() {}
//    
//    // MARK: - Keychain Operations
//    func saveToKeychain(key: String, data: Data) -> Bool {
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrService as String: service,
//            kSecAttrAccount as String: key,
//            kSecValueData as String: data
//        ]
//        
//        // Delete any existing item
//        SecItemDelete(query as CFDictionary)
//        
//        // Add new item
//        let status = SecItemAdd(query as CFDictionary, nil)
//        return status == errSecSuccess
//    }
//    
//    func loadFromKeychain(key: String) -> Data? {
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrService as String: service,
//            kSecAttrAccount as String: key,
//            kSecReturnData as String: true,
//            kSecMatchLimit as String: kSecMatchLimitOne
//        ]
//        
//        var result: AnyObject?
//        let status = SecItemCopyMatching(query as CFDictionary, &result)
//        
//        return (result as? Data)
//    }
//    
//    func deleteFromKeychain(key: String) -> Bool {
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrService as String: service,
//            kSecAttrAccount as String: key
//        ]
//        
//        let status = SecItemDelete(query as CFDictionary)
//        return status == errSecSuccess
//    }
//    
//    // MARK: - User Persistence
//    func saveUser(_ user: UserModel) {
//        do {
//            let userData = try JSONEncoder().encode(user)
//            let success = saveToKeychain(key: "userData", data: userData)
//            
//            if success {
//                // Save login state
//                let loginState = ["isLoggedIn": true, "email": user.email, "name": user.name] as [String : Any]
//                let loginData = try JSONSerialization.data(withJSONObject: loginState)
//                _ = saveToKeychain(key: "loginState", data: loginData)
//            }
//        } catch {
//            print("Error saving user to keychain: \(error)")
//        }
//    }
//    
//    func loadUser() -> UserModel? {
//        guard let userData = loadFromKeychain(key: "userData") else {
//            return nil
//        }
//        
//        do {
//            let user = try JSONDecoder().decode(UserModel.self, from: userData)
//            return user
//        } catch {
//            print("Error loading user from keychain: \(error)")
//            return nil
//        }
//    }
//    
//    func isUserLoggedIn() -> Bool {
//        guard let loginData = loadFromKeychain(key: "loginState") else {
//            return false
//        }
//        
//        do {
//            let loginState = try JSONSerialization.jsonObject(with: loginData) as? [String: Any]
//            return loginState?["isLoggedIn"] as? Bool ?? false
//        } catch {
//            return false
//        }
//    }
//    
//    func clearUserData() {
//        _ = deleteFromKeychain(key: "userData")
//        _ = deleteFromKeychain(key: "loginState")
//    }
//    
//    // MARK: - Secure Token Storage
//    func saveAuthToken(_ token: String) -> Bool {
//        guard let tokenData = token.data(using: .utf8) else { return false }
//        return saveToKeychain(key: "authToken", data: tokenData)
//    }
//    
//    func getAuthToken() -> String? {
//        guard let tokenData = loadFromKeychain(key: "authToken") else { return nil }
//        return String(data: tokenData, encoding: .utf8)
//    }
//    
//    func deleteAuthToken() -> Bool {
//        return deleteFromKeychain(key: "authToken")
//    }
//} 
