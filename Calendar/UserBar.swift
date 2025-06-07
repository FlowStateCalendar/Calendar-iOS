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
    
    var body: some View {
        ZStack{
            HStack{
                Spacer()
                
                //Middle - User Profile
                VStack(spacing: 4){
                    //User Icon and Level Progress
                    ZStack{
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                            .frame(width: 50, height: 50)
                        
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(Color.green, lineWidth: 4)
                            .rotationEffect(.degrees(-90))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "person.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    }
                    // Level pill
                    Text("Lv \(level)")
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.1))
                        .clipShape(Capsule())
                }
                
                Spacer()
            }
            
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
                HStack(spacing: 6) {
                    ZStack{
                        Circle()
                            .foregroundColor(Color.gray.opacity(0.15))
                            .padding(22)
                        Image(systemName: "dollarsign.ring")
                            .foregroundColor(.yellow)
                    }
                    
                    Text("\(coins)")
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(Capsule())
                }
                
            }
            .frame(height: 80)
            .padding(.horizontal)
        }
    }
}

#Preview {
    UserBar()
}
