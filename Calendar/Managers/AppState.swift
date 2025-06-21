//
//  AppState.swift
//  Calendar
//
//  Created by Rhyse Summers on 07/06/2025.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    
    private let storageManager = StorageManager.shared
    
    init() {
        // Load login state on initialization
        self.isLoggedIn = storageManager.isUserLoggedIn()
    }
    
    func setLoggedIn(_ loggedIn: Bool) {
        self.isLoggedIn = loggedIn
    }
    
    func logout() {
        self.isLoggedIn = false
        storageManager.clearUserData()
    }
}
