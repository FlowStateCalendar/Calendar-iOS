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

enum TaskFrequency: String, CaseIterable, Codable {
    case none, daily, weekly, monthly
}

// MARK: - Task Model
final class TaskModel: ObservableObject, Identifiable, Codable {
    // MARK: - Properties
    let id: UUID
    @Published var name: String
    @Published var taskDescription: String
    @Published var category: TaskCategory
    @Published var frequency: TaskFrequency
    @Published var energy: Int {
        didSet {
            // Clamp energy value between 1 and 5
            energy = min(max(energy, 1), 5)
        }
    }
//    var notificationType: NotificationType
//    var notificationFrequency: NotificationFrequency
    @Published var taskDate: Date
    
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
        frequency: TaskFrequency,
        category: TaskCategory = .other,
        energy: Int,
        taskDate: Date,
//        notificationType: NotificationType = .none,
//        notificationFrequency: NotificationFrequency = .once,
    ) {
        self.id = UUID()
        self.name = name
        self.taskDescription = description
        self.frequency = frequency
        self.category = category
        self.energy = min(max(energy, 1), 5) // Ensure valid range
//        self.notificationType = notificationType
//        self.notificationFrequency = notificationFrequency
        self.taskDate = taskDate
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, name, taskDescription, category, frequency, energy, taskDate
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        taskDescription = try container.decode(String.self, forKey: .taskDescription)
        category = try container.decode(TaskCategory.self, forKey: .category)
        frequency = try container.decode(TaskFrequency.self, forKey: .frequency)
        energy = try container.decode(Int.self, forKey: .energy)
        taskDate = try container.decode(Date.self, forKey: .taskDate)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(taskDescription, forKey: .taskDescription)
        try container.encode(category, forKey: .category)
        try container.encode(frequency, forKey: .frequency)
        try container.encode(energy, forKey: .energy)
        try container.encode(taskDate, forKey: .taskDate)
    }
    
    // MARK: - Methods
    func updateTask(
        name: String? = nil,
        description: String? = nil,
        category: TaskCategory? = nil,
        frequency: TaskFrequency? = nil,
        energy: Int? = nil,
        taskDate: Date? = nil,
//        notificationType: NotificationType? = nil,
//        notificationFrequency: NotificationFrequency? = nil
    ) {
        if let name = name { self.name = name }
        if let description = description { self.taskDescription = description }
        if let category = category { self.category = category }
        if let frequency = frequency { self.frequency = frequency }
        if let energy = energy { self.energy = energy } // didSet will clamp the value
//        if let notificationType = notificationType { self.notificationType = notificationType }
//        if let notificationFrequency = notificationFrequency { self.notificationFrequency = notificationFrequency }
    }
    
    func duplicate() -> TaskModel {
        return TaskModel(
            name: "\(name) (Copy)",
            description: taskDescription,
            frequency: frequency,
            category: category,
            energy: energy,
            taskDate: taskDate,
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
        TaskModel(name: "Morning Workout", description: "30-minute cardio session", frequency: .daily, category: .health, energy: 4, taskDate: Calendar.current.date(byAdding: .day, value: 0, to: Date()) ?? Date()),
        TaskModel(name: "Review Code", description: "Review pull requests", frequency: .daily, category: .work, energy: 3, taskDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()),
        TaskModel(name: "Read Book", description: "Read 20 pages", frequency: .weekly, category: .personal, energy: 2, taskDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date()),
        TaskModel(name: "Study Swift", description: "Learn new SwiftUI features", frequency: .none, category: .study, energy: 4, taskDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date())
    ]
}
