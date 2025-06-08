//
//  CreateTaskButton.swift
//  Calendar
//
//  Created by Rhyse Summers on 08/06/2025.
//

import SwiftUI

struct CreateTaskButton: View {
    var body: some View {
        HStack {
            Spacer()
                        
            Text("Create your own")
                .font(.headline)
                .foregroundColor(.black)

            Button(action: {
                // Add task action here
            }) {
                Circle()
                    .fill(Color.gray.opacity(0.80))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                    )
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    CreateTaskButton()
}
