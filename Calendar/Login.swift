//
//  Login.swift
//  Calendar
//
//  Created by Rhyse Summers on 06/06/2025.
//

import SwiftUI

struct Login: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack {
            Text("Flowstate Calendar")
                .font(.largeTitle)
                .padding()

//            Image("Logo")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 150, height: 150)

            Spacer()

            Button {
                // Navigate to sign-up screen
                print("Sign up tapped")
            } label: {
                ZStack {
                    Capsule()
                        .foregroundColor(.orange)
                        .frame(width: 100, height: 40)
                    Text("Sign Up")
                        .foregroundColor(.white)
                }
            }
            .padding(.bottom, 10)

            Button {
                // Perform login and switch view
                appState.isLoggedIn = true
                print("Login tapped")
            } label: {
                ZStack {
                    Capsule()
                        .foregroundColor(.orange)
                        .frame(width: 100, height: 40)
                    Text("Login")
                        .foregroundColor(.white)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
        .padding(.horizontal, 20)
        .background(Color.gray.opacity(0.2).ignoresSafeArea())
    }
}


#Preview {
    Login()
}
