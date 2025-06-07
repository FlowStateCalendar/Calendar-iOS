//
//  RootView.swift
//  Calendar
//
//  Created by Rhyse Summers on 07/06/2025.
//
import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        if appState.isLoggedIn {
            ContentView()
        } else {
            Login()
        }
    }
}
