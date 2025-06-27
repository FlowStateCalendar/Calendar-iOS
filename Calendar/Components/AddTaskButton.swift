//
//  AddTaskButton.swift
//  Calendar
//
//  Created by Rhyse Summers on 08/06/2025.
//

import SwiftUI

struct AddTaskButton: View {
    @State private var showNewTaskView = false
    
    var body: some View {
        HStack {
            Spacer()
                        
            Text("Add Task")
                .font(.headline)
                .foregroundColor(.black)

            Button(action: {
                print("Open new task view")
                showNewTaskView = true
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
        .fullScreenCover(isPresented: $showNewTaskView) {
            NewTaskView(taskToEdit: nil)
        }
    }
}

#Preview {
    AddTaskButton()
}
