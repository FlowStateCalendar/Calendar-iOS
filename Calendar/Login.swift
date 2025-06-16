//
//  Login.swift
//  Calendar
//
//  Created by Rhyse Summers on 06/06/2025.
//

import GoogleSignIn
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
                // Google Login
                handleSignupButton()
            } label: {
                ZStack {
                    Capsule()
                        .foregroundColor(.orange)
                        .frame(width: 150, height: 40)
                    Text("Google Login")
                        .foregroundColor(.white)
                }
            }
            .padding(.bottom, 10)

//            Button {
//                // Navigate to sign-up screen
//                print("Sign up tapped")
//            } label: {
//                ZStack {
//                    Capsule()
//                        .foregroundColor(.orange)
//                        .frame(width: 100, height: 40)
//                    Text("Sign Up")
//                        .foregroundColor(.white)
//                }
//            }
//            .padding(.bottom, 10)
//
//            Button {
//                // Perform login and switch view
//                appState.isLoggedIn = true
//                print("Login tapped")
//            } label: {
//                ZStack {
//                    Capsule()
//                        .foregroundColor(.orange)
//                        .frame(width: 100, height: 40)
//                    Text("Login")
//                        .foregroundColor(.white)
//                }
//            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
        .padding(.horizontal, 20)
        .background(Color.gray.opacity(0.2).ignoresSafeArea())
    }
    
    func handleSignupButton() {
        print("Google Login tapped")
        
        if let rootViewController = getRootViewController() {
            GIDSignIn.sharedInstance.signIn(
                withPresenting: rootViewController
            ) { result, error in
                guard let result else {
                    // Inspect error
                    return
                }
                // do something with result
                let currentUser = UserModel(name: result.user.profile?.name ?? "InvalidName", email: result.user.profile?.email ?? "InvalidEmail")
                currentUser.profile = result.user.profile?.imageURL(withDimension: 200)
                
                print(result.user.profile?.name ?? "InvalidName")
                print(result.user.profile?.email ?? "InvalidEmail")
                print(result.user.profile?.imageURL(withDimension: 200) ?? "InvalidImageURL")
            }
        }
        
    }
}


#Preview {
    Login()
}

func getRootViewController() -> UIViewController? {
    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let rootViewController = scene.windows.first?.rootViewController else {
        return nil
    }
    return getVisibleViewController(from: rootViewController)
}

private func getVisibleViewController(from vc: UIViewController) -> UIViewController {
    if let nav = vc as? UINavigationController {
        return getVisibleViewController(from: nav.visibleViewController!)
    }
    if let tab = vc as? UITabBarController {
        return getVisibleViewController(from: tab.selectedViewController!)
    }
    if let presented = vc.presentedViewController {
        return getVisibleViewController(from: presented)
    }
    return vc
}
