//
//  TasksView.swift
//  Calendar
//
//  Created by Rhyse Summers on 06/06/2025.
//

import SwiftUI

struct TasksView: View {
    @EnvironmentObject var user: UserModel
    @State private var selectedTask: TaskModel?
    // Combine sample tasks and user tasks, removing duplicates by id
    var allTasks: [TaskModel] {
        let combined = TaskModel.sampleTasks + user.tasks
        var seen = Set<UUID>()
        return combined.filter { seen.insert($0.id).inserted }
    }

    // Grid config
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    let itemsPerPage = 6 // 2 columns x 3 rows

    // Split tasks into pages
    var pages: [[TaskModel]] {
        stride(from: 0, to: allTasks.count, by: itemsPerPage).map {
            Array(allTasks[$0..<min($0 + itemsPerPage, allTasks.count)])
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
                        LazyVGrid(columns: columns, spacing: 32) {
                            ForEach(page) { task in
                                ZStack {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 140, height: 140)
                                    VStack(spacing: 8) {
                                        // Category icon
                                        Image(systemName: task.category.filledIconName)
                                            .font(.system(size: 28))
                                            .foregroundColor(.white)
                                            .padding(.top, 8)
                                        // Task name
                                        Text(task.name)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2)
                                            .minimumScaleFactor(0.7)
                                        // Energy bolts
                                        HStack(spacing: 2) {
                                            ForEach(1...5, id: \.self) { i in
                                                Image(systemName: i <= task.energy ? "bolt.fill" : "bolt")
                                                    .foregroundColor(i <= task.energy ? .yellow : .white.opacity(0.5))
                                                    .font(.system(size: 16))
                                            }
                                        }
                                        .padding(.bottom, 4)
                                    }
                                    .frame(width: 120, height: 120)
                                }
                                .onTapGesture {
                                    selectedTask = task
                                }
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
        .fullScreenCover(item: $selectedTask) { task in
            NewTaskView(taskToEdit: task)
                .environmentObject(user)
        }
    }
}

#Preview {
    TasksView()
        .environmentObject(UserModel(name: "Test User", email: "test@example.com"))
}
