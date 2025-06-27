//
//  UserModel.swift
//  Calendar
//
//  Created by Rhyse Summers on 10/06/2025.
//

import SwiftUI
import Foundation
import Combine

// MARK: - User Model

final class UserModel: ObservableObject, Identifiable, Codable {
    // MARK: - Properties
    let id: UUID
    @Published var name: String
    @Published var email: String
    @Published var profile: URL?
    @Published var createdAt: Date
    @Published var tasks: [TaskModel]
    @Published var events: [EventModel]
    @Published var xp: Int
    @Published var level: Int // User's current level
    @Published var coins: Int
//    var preferences: UserPreferences
    
    // MARK: - XP/Level System
    /// Returns the XP required to reach the next level (exponential curve)
    func requiredXP(for level: Int) -> Int {
        let baseXP = 100
        let growthFactor = 1.14
        return Int(Double(baseXP) * pow(growthFactor, Double(level - 1)))
    }
    /// Adds XP and handles level up logic
    func addXP(_ amount: Int) {
        xp += amount
        while xp >= requiredXP(for: level) {
            xp -= requiredXP(for: level)
            level += 1
            // Optionally: trigger level up notification here
        }
    }
    /// Progress to next level (0.0 - 1.0)
    var levelProgress: Double {
        Double(xp) / Double(requiredXP(for: level))
    }
    
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
        self.events = []
        self.xp = 0
        self.level = 1
        self.coins = 0
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
    
    func logout() {
        self.name = ""
        self.email = ""
        self.profile = nil
        self.tasks = []
        self.events = []
        self.xp = 0
        self.coins = 0
    }
    
//    func updateTask(_ task: TaskModel) {
//        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
//            tasks[index] = task
//            // Remove old events and regenerate
//            events.removeAll { $0.taskId == task.id }
//            generateEventsForTask(task)
//        }
//    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, name, email, profile, createdAt, tasks, events, xp, level, coins
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
        profile = try container.decodeIfPresent(URL.self, forKey: .profile)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        tasks = try container.decode([TaskModel].self, forKey: .tasks)
        events = try container.decode([EventModel].self, forKey: .events)
        xp = try container.decode(Int.self, forKey: .xp)
        level = try container.decodeIfPresent(Int.self, forKey: .level) ?? 1
        coins = try container.decode(Int.self, forKey: .coins)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encode(profile, forKey: .profile)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(tasks, forKey: .tasks)
        try container.encode(events, forKey: .events)
        try container.encode(xp, forKey: .xp)
        try container.encode(level, forKey: .level)
        try container.encode(coins, forKey: .coins)
    }
}

// MARK: - Usage Example
extension UserModel {
    static func createSampleUser() -> UserModel {
        let user = UserModel(name: "John Doe", email: "john@example.com")
        
        // Add some sample tasks
        let workoutTask = TaskModel(
            name: "Morning Workout",
            description: "30-minute cardio session",
            frequency: .none,
            category: .health,
            energy: 4,
            taskDate: Date(),
//            notificationType: .local,
//            notificationFrequency: .daily
        )
        
        let codeReviewTask = TaskModel(
            name: "Code Review",
            description: "Review team's pull requests",
            frequency: .none,
            category: .work,
            energy: 3,
            taskDate: Date(),
//            notificationType: .push,
//            notificationFrequency: .daily
        )
        
        let weeklyPlanningTask = TaskModel(
            name: "Weekly Planning",
            description: "Plan tasks for the upcoming week",
            frequency: .none,
            category: .work,
            energy: 2,
            taskDate: Date(),
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
