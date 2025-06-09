//
//  UserBar.swift
//  Calendar
//
//  Created by Rhyse Summers on 06/06/2025.
//

import SwiftUI

struct UserBar: View {
    var coins: Int = 100
    var progress: Double = 0.65
    var level: Int = 12
    var backdrop: Color = .gray.opacity(0.60)
    
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
                Text("\(coins)")
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
                        .trim(from: 0, to: progress)
                        .stroke(Color.green, lineWidth: 4)
                        .rotationEffect(.degrees(-90))
                        .frame(width: 50, height: 50)
                    
                    //Insert the profile picture here
                    Image(systemName: "person.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                }
                // Level pill
                Text("Lv \(level)")
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

#Preview {
    UserBar()
}
