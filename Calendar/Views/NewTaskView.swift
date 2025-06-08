//
//  NewTaskView.swift
//  Calendar
//
//  Created by Rhyse Summers on 08/06/2025.
//

import SwiftUI

struct NewTaskView: View {
    var body: some View {
        VStack{
            
            UserBar()
            
            ZStack{
                // Background colour
                Color(.gray.opacity(0.80))
                
                // Close Button
                VStack{
                    HStack{
                        Spacer()
                        
                        Button(action: {
                            // Add action here
                        }) {
                            Circle()
                                .fill(Color.gray.opacity(0.80))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: "xmark")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.black)
                                )
                        }
                    }
                    Spacer ()
                }
                
                VStack{
                    Text("Create a New Task")
                    
                    // Icon Section
                    HStack{
                        // Energy level
                        Image("bolt") // bolt.fill
                        
                        // Icon
                        Circle()
                            .fill(Color.green.opacity(0.80))
                            .frame(width: 50, height: 50)
                        
                        // Add task type images below
                    }
                    
                    // Name Section
                    HStack{
                        Spacer()
                        
                        Text("Task Name")
                        
                        Spacer()
                    }
                    
                    // Task Description
                    VStack{
                        // Title
                        Text("Task Description")
                        // Input Box
                        Rectangle()
                    }
                    
                    VStack{
                        // Title
                        Text("Task Length")
                        // Picker Input
                    }
                    
                    
                    
                    Spacer()
                }
                
            }
            
        }
        .background(Color(.teal))
    }
}


#Preview {
    NewTaskView()
}
