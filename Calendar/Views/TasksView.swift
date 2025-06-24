//
//  TasksView.swift
//  Calendar
//
//  Created by Rhyse Summers on 06/06/2025.
//

import SwiftUI

struct Task: Identifiable {
    let id = UUID()
    let title: String
}

struct TasksView: View {
    
    let tasks = (1...15).map { Task(title: "Task \($0)") }

    // Grid config
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    let itemsPerPage = 9 // 3 columns x 3 rows

    // Split tasks into pages
    var pages: [[Task]] {
        stride(from: 0, to: tasks.count, by: itemsPerPage).map {
            Array(tasks[$0..<min($0 + itemsPerPage, tasks.count)])
        }
    }
    
    var body: some View {
        VStack {
            UserBar()
            Text("Your Tasks")
            
            // Container with styling
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                // Task grid inside paged TabView
                TabView {
                    ForEach(pages.indices, id: \.self) { index in
                        let page = pages[index]
                        LazyVGrid(columns: columns, spacing: 24) {
                            ForEach(page) { task in
                                Text(task.title)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 100, height: 100)
                                    .background(Color.green)
                                    .clipShape(Circle())
                            }
                        }
                        .padding()
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .padding()
            }
            .frame(height: 450)
            .padding(.horizontal)
            
            AddTaskButton()
            
            Spacer()
        }
        .background(Image("fishBackground").resizable().edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    TasksView()
        .environmentObject(UserModel(name: "Test User", email: "test@example.com"))
}
