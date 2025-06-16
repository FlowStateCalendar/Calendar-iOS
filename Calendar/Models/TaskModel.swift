//
//  TestTaskModel.swift
//  Calendar
//
//  Created by Rhyse Summers on 11/06/2025.
//

import Foundation
import SwiftUI

// MARK: - Supporting Enums
enum NotificationType: String, CaseIterable, Codable {
    case none, local, push
    
    var displayName: String {
        switch self {
        case .none: return "None"
        case .local: return "Local"
        case .push: return "Push"
        }
    }
}

enum NotificationFrequency: String, CaseIterable, Codable {
    case once, daily, weekly
    
    var displayName: String {
        switch self {
        case .once: return "Once"
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        }
    }
}

enum TaskCategory: String, CaseIterable, Codable {
    case work, health, personal, study, other
    
    var displayName: String {
        switch self {
        case .work: return "Work"
        case .health: return "Health"
        case .personal: return "Personal"
        case .study: return "Study"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .work: return "briefcase"
        case .health: return "heart"
        case .personal: return "person"
        case .study: return "book"
        case .other: return "folder"
        }
    }
}

// MARK: - Task Model
@Observable
final class TaskModel: Identifiable, Codable {
    // MARK: - Properties
    let id: UUID
    var name: String
    var taskDescription: String // Changed from 'description' to 'taskDescription'
    var category: TaskCategory
    var energy: Int {
        didSet {
            // Clamp energy value between 1 and 5
            energy = min(max(energy, 1), 5)
        }
    }
    var notificationType: NotificationType
    var notificationFrequency: NotificationFrequency
    var createdAt: Date
    var isCompleted: Bool
    
    // MARK: - Computed Properties
    var energyDescription: String {
        switch energy {
        case 1: return "Very Low"
        case 2: return "Low"
        case 3: return "Medium"
        case 4: return "High"
        case 5: return "Very High"
        default: return "Unknown"
        }
    }
    
    // MARK: - Initialization
    init(
        name: String,
        description: String = "", // Keep the parameter name for ease of use
        category: TaskCategory = .other,
        energy: Int = 3,
        notificationType: NotificationType = .none,
        notificationFrequency: NotificationFrequency = .once,
        isCompleted: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.taskDescription = description // Assign to renamed property
        self.category = category
        self.energy = min(max(energy, 1), 5) // Ensure valid range
        self.notificationType = notificationType
        self.notificationFrequency = notificationFrequency
        self.createdAt = Date()
        self.isCompleted = isCompleted
    }
    
    // MARK: - Methods
    func updateTask(
        name: String? = nil,
        description: String? = nil,
        category: TaskCategory? = nil,
        energy: Int? = nil,
        notificationType: NotificationType? = nil,
        notificationFrequency: NotificationFrequency? = nil
    ) {
        if let name = name { self.name = name }
        if let description = description { self.taskDescription = description } // Updated reference
        if let category = category { self.category = category }
        if let energy = energy { self.energy = energy } // didSet will clamp the value
        if let notificationType = notificationType { self.notificationType = notificationType }
        if let notificationFrequency = notificationFrequency { self.notificationFrequency = notificationFrequency }
    }
    
    func toggleCompletion() {
        isCompleted.toggle()
    }
    
    func duplicate() -> TaskModel {
        return TaskModel(
            name: "\(name) (Copy)",
            description: taskDescription, // Updated reference
            category: category,
            energy: energy,
            notificationType: notificationType,
            notificationFrequency: notificationFrequency,
            isCompleted: false
        )
    }
}

// MARK: - TaskModel Extensions
extension TaskModel: Hashable {
    static func == (lhs: TaskModel, rhs: TaskModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension TaskModel: CustomStringConvertible {
    var description: String { // This satisfies CustomStringConvertible protocol
        return "Task(name: \(name), category: \(category.displayName), energy: \(energy))"
    }
}

// MARK: - Sample Data
extension TaskModel {
    static let sampleTasks: [TaskModel] = [
        TaskModel(name: "Morning Workout", description: "30-minute cardio session", category: .health, energy: 4),
        TaskModel(name: "Review Code", description: "Review pull requests", category: .work, energy: 3),
        TaskModel(name: "Read Book", description: "Read 20 pages", category: .personal, energy: 2),
        TaskModel(name: "Study Swift", description: "Learn new SwiftUI features", category: .study, energy: 4)
    ]
}
