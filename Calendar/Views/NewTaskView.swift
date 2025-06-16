//
//  NewTaskView.swift
//  Calendar
//
//  Created by Rhyse Summers on 08/06/2025.
//

import SwiftUI

struct NewTaskView: View {
    @State private var taskMins: Int = 0
    @State private var taskHours: Int = 0
    
    var body: some View {
        VStack{
            
            UserBar()
            
            ZStack{
                // Background colour
                //Color(.gray.opacity(0.80)).ignoresSafeArea()
                    
                
                
                
                // Close Button
                VStack{
                    HStack{
                        Spacer()
                        
                        Button(action: {
                            // Add action here
                        }) {
                            Circle()
                                .fill(Color.gray.opacity(0.80))
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Image(systemName: "xmark")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.black)
                                )
                        }
                    }
                    Spacer ()
                }
                
                VStack{
                    Text("Create a New Task")
                        .padding(.top, 30)
                    
                    // Icon Section
                    HStack{
                        // Energy level
                        Image("bolt") // bolt.fill
                            .foregroundColor(.black)
                        
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
                    
                    ScrollView{
                    
                    // Task Description
                    VStack{
                        // Title
                        Text("Task Description")
                        // Input Box
                        Rectangle()
                            .fill(Color.black.opacity(0.3))
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity, maxHeight: 300)
                    }
                    
                    VStack{
                        // Title
                        Text("Task Length")
                        HStack{
                            // Hour Input
                            Picker("Select Time", selection: $taskMins)
                            {
                                Text("0").tag(0)
                                Text("1").tag(1)
                                Text("2").tag(2)
                                Text("3").tag(3)
                                Text("4").tag(4)
                                Text("5").tag(5)
                                Text("6").tag(6)
                                Text("7").tag(7)
                                Text("8").tag(8)
                            }
                            .pickerStyle(.wheel)
                            Text("hours")
                            
                            // Minute Input
                            Picker("Select Time", selection: $taskMins)
                            {
                                Text("15").tag(15)
                                Text("30").tag(30)
                                Text("45").tag(45)
                            }
                            .pickerStyle(.wheel)
                            Text("min")
                        }
                    }
                    
                    VStack{
                        //Title
                        Text("Notifications")
                    }
                    
                    
                    
                    Spacer()
                }
                
            }
            .background {
                UnevenRoundedRectangle(
                    topLeadingRadius: 20,
                    topTrailingRadius: 20
                )
                .fill(.gray)
                .ignoresSafeArea()
            }
            }
    
        }
        .background(Color(.teal))
    }
}


#Preview {
    NewTaskView()
}
