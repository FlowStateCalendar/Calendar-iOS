//
//  TestTaskModel.swift
//  Calendar
//
//  Created by Rhyse Summers on 11/06/2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Supporting Enums
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
final class TaskModel: ObservableObject, Identifiable, Codable {
    // MARK: - Properties
    let id: UUID
    @Published var name: String
    @Published var taskDescription: String
    @Published var category: TaskCategory
    @Published var energy: Int {
        didSet {
            // Clamp energy value between 1 and 5
            energy = min(max(energy, 1), 5)
        }
    }
//    var notificationType: NotificationType
//    var notificationFrequency: NotificationFrequency
    @Published var createdAt: Date
    
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
        description: String = "",
        category: TaskCategory = .other,
        energy: Int,
//        notificationType: NotificationType = .none,
//        notificationFrequency: NotificationFrequency = .once,
    ) {
        self.id = UUID()
        self.name = name
        self.taskDescription = description
        self.category = category
        self.energy = min(max(energy, 1), 5) // Ensure valid range
//        self.notificationType = notificationType
//        self.notificationFrequency = notificationFrequency
        self.createdAt = Date()
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, name, taskDescription, category, energy, createdAt
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        taskDescription = try container.decode(String.self, forKey: .taskDescription)
        category = try container.decode(TaskCategory.self, forKey: .category)
        energy = try container.decode(Int.self, forKey: .energy)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(taskDescription, forKey: .taskDescription)
        try container.encode(category, forKey: .category)
        try container.encode(energy, forKey: .energy)
        try container.encode(createdAt, forKey: .createdAt)
    }
    
    // MARK: - Methods
    func updateTask(
        name: String? = nil,
        description: String? = nil,
        category: TaskCategory? = nil,
        energy: Int? = nil,
//        notificationType: NotificationType? = nil,
//        notificationFrequency: NotificationFrequency? = nil
    ) {
        if let name = name { self.name = name }
        if let description = description { self.taskDescription = description }
        if let category = category { self.category = category }
        if let energy = energy { self.energy = energy } // didSet will clamp the value
//        if let notificationType = notificationType { self.notificationType = notificationType }
//        if let notificationFrequency = notificationFrequency { self.notificationFrequency = notificationFrequency }
    }
    
    func duplicate() -> TaskModel {
        return TaskModel(
            name: "\(name) (Copy)",
            description: taskDescription,
            category: category,
            energy: energy,
//            notificationType: notificationType,
//            notificationFrequency: notificationFrequency,
//            isCompleted: false
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

// Use for errors - use case: print(task)
extension TaskModel: CustomStringConvertible {
    var description: String {
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
