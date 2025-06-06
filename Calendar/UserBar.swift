//
//  UserBar.swift
//  Calendar
//
//  Created by Rhyse Summers on 06/06/2025.
//

import SwiftUI

struct UserBar: View {
    var coins: Int = 100
    
    var body: some View {
        HStack{
            Button(action: {
                // handle menu tap
                print("Open menu")
            }) {
                Image(systemName: "line.3.horizontal")
            }
            
            Spacer()
            
            VStack{
                Image(systemName: "person.circle")
                ZStack(alignment: .leading) {
                    Capsule()
                        .frame(width: 60, height: 6)
                        .foregroundColor(Color.gray.opacity(0.3))
                    Capsule()
                        .frame(width: CGFloat(2) * 6, height: 6)
                        .foregroundColor(.green)
                }
            }
            
            
            Spacer()
            
            HStack{
                Image(systemName: "dollarsign.ring")
                Text("\(coins)")
                    .fontWeight(.bold)
            }
        }
    }
}

#Preview {
    UserBar()
}
