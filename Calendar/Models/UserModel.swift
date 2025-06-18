//
//  UserModel.swift
//  Calendar
//
//  Created by Rhyse Summers on 10/06/2025.
//

import SwiftUI
import Foundation

// MARK: - User Model

@Observable final class UserModel: Identifiable, Codable {
    // MARK: - Properties
    let id: UUID
    var name: String
    var email: String
    var profile: URL?
    var createdAt: Date
    var tasks: [TaskModel]	
    //var events: [EventModel]
    //var preferences: UserPreferences
    
    // MARK: - Computed Properties
//    var activeTasks: [TaskModel] {
//        tasks.filter { !$0.isCompleted }
//    }
//
//    var todayEvents: [TaskEvent] {
//        events.filter { $0.isToday }.sorted { $0.scheduledDate < $1.scheduledDate }
//    }

    
    // MARK: - Initialization
    init(name: String, email: String) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.profile = nil
        self.createdAt = Date()
        self.tasks = []
//        self.events = []
//        self.preferences = UserPreferences()
    }
    
    // MARK: - Task Management
    func addTask(_ task: TaskModel) {
        tasks.append(task)
        //generateEventsForTask(task)
    }
    
    func removeTask(_ task: TaskModel) {
        tasks.removeAll { $0.id == task.id }
        //events.removeAll { $0.taskId == task.id }
    }
    
//    func updateTask(_ task: TaskModel) {
//        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
//            tasks[index] = task
//            // Remove old events and regenerate
//            events.removeAll { $0.taskId == task.id }
//            generateEventsForTask(task)
//        }
//    }
    
//    // MARK: - Event Generation
//    func generateEventsForTask(_ task: TaskModel) {
//        guard task.notificationType != .none else { return }
//        
//        let startDate = preferences.eventGenerationStartDate
//        let endDate = Calendar.current.date(byAdding: .month, value: preferences.eventGenerationMonths, to: startDate) ?? startDate
//        
//        switch task.notificationFrequency {
//        case .once:
//            generateOnceEvent(for: task, startDate: startDate)
//        case .daily:
//            generateDailyEvents(for: task, from: startDate, to: endDate)
//        case .weekly:
//            generateWeeklyEvents(for: task, from: startDate, to: endDate)
//        }
//    }
    
//    private func generateOnceEvent(for task: TaskModel, startDate: Date) {
//        let scheduledDate = preferences.preferredTimeOfDay.appliedTo(date: startDate)
//        let event = TaskEvent(from: task, scheduledDate: scheduledDate)
//        events.append(event)
//    }
//    
//    private func generateDailyEvents(for task: TaskModel, from startDate: Date, to endDate: Date) {
//        let calendar = Calendar.current
//        var currentDate = startDate
//        
//        while currentDate <= endDate {
//            let scheduledDate = preferences.preferredTimeOfDay.appliedTo(date: currentDate)
//            let event = TaskEvent(from: task, scheduledDate: scheduledDate)
//            events.append(event)
//            
//            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
//            currentDate = nextDate
//        }
//    }
    
//    private func generateWeeklyEvents(for task: TaskModel, from startDate: Date, to endDate: Date) {
//        let calendar = Calendar.current
//        var currentDate = startDate
//        
//        // Align to preferred day of week if set
//        if let preferredWeekday = preferences.preferredWeekday {
//            let currentWeekday = calendar.component(.weekday, from: currentDate)
//            let daysToAdd = (preferredWeekday - currentWeekday + 7) % 7
//            currentDate = calendar.date(byAdding: .day, value: daysToAdd, to: currentDate) ?? currentDate
//        }
//        
//        while currentDate <= endDate {
//            let scheduledDate = preferences.preferredTimeOfDay.appliedTo(date: currentDate)
//            let event = TaskEvent(from: task, scheduledDate: scheduledDate)
//            events.append(event)
//            
//            guard let nextDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) else { break }
//            currentDate = nextDate
//        }
//    }
}

// MARK: - Usage Example
extension UserModel {
    static func createSampleUser() -> UserModel {
        let user = UserModel(name: "John Doe", email: "john@example.com")
        
        // Add some sample tasks
        let workoutTask = TaskModel(
            name: "Morning Workout",
            description: "30-minute cardio session",
            category: .health,
            energy: 4,
//            notificationType: .local,
//            notificationFrequency: .daily
        )
        
        let codeReviewTask = TaskModel(
            name: "Code Review",
            description: "Review team's pull requests",
            category: .work,
            energy: 3,
//            notificationType: .push,
//            notificationFrequency: .daily
        )
        
        let weeklyPlanningTask = TaskModel(
            name: "Weekly Planning",
            description: "Plan tasks for the upcoming week",
            category: .work,
            energy: 2,
//            notificationType: .local,
//            notificationFrequency: .weekly
        )
        
        user.addTask(workoutTask)
        user.addTask(codeReviewTask)
        user.addTask(weeklyPlanningTask)
        
        // Set preferences
//        user.preferences.preferredWeekday = 2 // Monday for weekly tasks
//        user.preferences.preferredTimeOfDay = .morning
        
        return user
    }
}

// MARK: - UserModel Extensions
extension UserModel: Hashable {
    static func == (lhs: UserModel, rhs: UserModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension UserModel: CustomStringConvertible {
    var description: String {
        return "User(name: \(name), tasks: \(tasks.count))" //, events: \(events.count)
    }
}
