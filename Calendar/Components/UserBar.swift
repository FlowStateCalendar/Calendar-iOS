//
//  UserBar.swift
//  Calendar
//
//  Created by Rhyse Summers on 06/06/2025.
//

import SwiftUI

struct UserBar: View {
    @EnvironmentObject var user: UserModel
    
    var backdrop: Color = .gray
    
    var body: some View {
        HStack{
            //Left - Hamburger Menu
            Button(action: {
                // handle menu tap
                print("Open menu")
            }) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            //Right - Coins (Padding needs work)
            HStack(spacing: 4) {
                
                // Coin Icon
                ZStack{
                    Circle()
                        .foregroundColor(backdrop)
                        .frame(width: 30, height: 30)
                    Image(systemName: "dollarsign.ring")
                        .foregroundColor(.yellow)
                }
                
                //Coin Value
                Text("\(user.coins)")
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(backdrop)
                    .clipShape(Capsule())
            }
            
        }
        .frame(height: 80)
        .padding(.horizontal)
        .overlay {
            //Middle - User Profile
            VStack(spacing: 4){
                //User Icon and Level Progress
                ZStack{
                    Circle()
                        .foregroundColor(backdrop)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .stroke(backdrop, lineWidth: 4)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0, to: user.levelProgress)
                        .stroke(Color.green, lineWidth: 4)
                        .rotationEffect(.degrees(-90))
                        .frame(width: 50, height: 50)
                    
                    // Profile Picture
                    ProfileImageView(profileURL: user.profile, size: 46)
                }
                // Level pill
                Text("Lv \(user.level)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(backdrop)
                    .clipShape(Capsule())
                    //.offset(y: -12)
            }
        }
    }
}

// MARK: - Profile Image Component
struct ProfileImageView: View {
    let profileURL: URL?
    let size: CGFloat
    
    var body: some View {
        Group {
            if let url = profileURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        // Loading state
                        ProgressView()
                            .frame(width: size, height: size)
                    case .success(let image):
                        // Successfully loaded image
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                    case .failure(_):
                        // Failed to load - show default avatar
                        DefaultAvatarView(size: size)
                    @unknown default:
                        DefaultAvatarView(size: size)
                    }
                }
            } else {
                // No URL provided - show default avatar
                DefaultAvatarView(size: size)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

// MARK: - Default Avatar Component
struct DefaultAvatarView: View {
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: size, height: size)
            
            Image(systemName: "person.fill")
                .font(.system(size: size * 0.5))
                .foregroundColor(.blue)
        }
    }
}

#Preview {
    UserBar()
        .environmentObject(UserModel(name: "John Doe", email: "john@example.com"))
}
