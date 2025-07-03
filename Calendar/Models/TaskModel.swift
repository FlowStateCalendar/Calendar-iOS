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
    
    var iconName: String {
        switch self {
        case .work: return "briefcase"
        case .health: return "heart"
        case .personal: return "person"
        case .study: return "book"
        case .other: return "folder"
        }
    }
    
    var filledIconName: String {
        switch self {
        case .work: return "briefcase.fill"
        case .health: return "heart.fill"
        case .personal: return "person.fill"
        case .study: return "book.fill"
        case .other: return "folder.fill"
        }
    }
}

enum TaskFrequency: String, CaseIterable, Codable {
    case none, daily, weekly, monthly
}

protocol Rewardable {
    var rewardFrequency: TaskFrequency { get }
    var rewardEnergy: Int { get }
    var rewardLength: TimeInterval { get }
}

// MARK: - Task Model
final class TaskModel: ObservableObject, Identifiable, Codable {
    // MARK: - Properties
    let id: UUID
    @Published var name: String
    @Published var taskDescription: String
    @Published var lengthMins: TimeInterval
    @Published var category: TaskCategory
    @Published var frequency: TaskFrequency
    @Published var energy: Int {
        didSet {
            // Clamp energy value between 1 and 5
            energy = min(max(energy, 1), 5)
        }
    }
    @Published var notification: NotificationModel
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
        lengthMins: TimeInterval = 0,
        frequency: TaskFrequency,
        category: TaskCategory = .other,
        energy: Int,
        taskDate: Date,
        notification: NotificationModel = NotificationModel.standard(),
    ) {
        self.id = UUID()
        self.name = name
        self.taskDescription = description
        self.lengthMins = lengthMins
        self.frequency = frequency
        self.category = category
        self.energy = min(max(energy, 1), 5) // Ensure valid range
        self.taskDate = taskDate
        self.notification = notification
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, name, taskDescription, lengthMins, category, frequency, energy, notification, taskDate
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        taskDescription = try container.decode(String.self, forKey: .taskDescription)
        lengthMins = try container.decode(TimeInterval.self, forKey: .lengthMins)
        category = try container.decode(TaskCategory.self, forKey: .category)
        frequency = try container.decode(TaskFrequency.self, forKey: .frequency)
        energy = try container.decode(Int.self, forKey: .energy)
        taskDate = try container.decode(Date.self, forKey: .taskDate)
        notification = try container.decode(NotificationModel.self, forKey: .notification)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(taskDescription, forKey: .taskDescription)
        try container.encode(lengthMins, forKey: .lengthMins)
        try container.encode(category, forKey: .category)
        try container.encode(frequency, forKey: .frequency)
        try container.encode(energy, forKey: .energy)
        try container.encode(taskDate, forKey: .taskDate)
        try container.encode(notification, forKey: .notification)
    }
    
    // MARK: - Methods
    func updateTask(
        name: String? = nil,
        description: String? = nil,
        category: TaskCategory? = nil,
        frequency: TaskFrequency? = nil,
        energy: Int? = nil,
        taskDate: Date? = nil,
        notification: NotificationModel? = nil,
    ) {
        if let name = name { self.name = name }
        if let description = description { self.taskDescription = description }
        if let category = category { self.category = category }
        if let frequency = frequency { self.frequency = frequency }
        if let energy = energy { self.energy = energy } // didSet will clamp the value
        if let notification = notification { self.notification = notification }
    }
    
    func duplicate() -> TaskModel {
        return TaskModel(
            name: "\(name) (Copy)",
            description: taskDescription,
            frequency: frequency,
            category: category,
            energy: energy,
            taskDate: taskDate,
            notification: notification,
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
        // Daily recurring tasks
        TaskModel(
            name: "Morning Workout", 
            description: "30-minute cardio session with stretching", 
            lengthMins: 30 * 60, // 30 minutes
            frequency: .daily, 
            category: .health, 
            energy: 4,
            taskDate: Calendar.current.date(byAdding: .day, value: 0, to: Date()) ?? Date(),
            notification: NotificationModel.reminder()
        ),
        TaskModel(
            name: "Review Code", 
            description: "Review pull requests and team code", 
            lengthMins: 45 * 60, // 45 minutes
            frequency: .daily, 
            category: .work, 
            energy: 3,
            taskDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
            notification: NotificationModel.standard()
        ),
        
        // Weekly recurring tasks
        TaskModel(
            name: "Read Book", 
            description: "Read 20 pages of current book", 
            lengthMins: 60 * 60, // 1 hour
            frequency: .weekly, 
            category: .personal, 
            energy: 2,
            taskDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
            notification: NotificationModel(
                frequency: .once,
                type: .local,
                sound: .chime,
                content: "Time to read!",
                timings: [NotificationTiming(minutesBeforeEvent: -30)]
            )
        ),
        TaskModel(
            name: "Team Meeting", 
            description: "Weekly team standup and planning", 
            lengthMins: 60 * 60, // 1 hour
            frequency: .weekly, 
            category: .work, 
            energy: 3,
            taskDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
            notification: NotificationModel.standard()
        ),
        TaskModel(
            name: "Grocery Shopping", 
            description: "Weekly grocery run and meal prep", 
            lengthMins: 90 * 60, // 1.5 hours
            frequency: .weekly, 
            category: .personal, 
            energy: 2,
            taskDate: Calendar.current.date(byAdding: .day, value: 4, to: Date()) ?? Date(),
            notification: NotificationModel.reminder()
        ),
        
        // Monthly recurring tasks
        TaskModel(
            name: "Budget Review", 
            description: "Review monthly expenses and budget planning", 
            lengthMins: 45 * 60, // 45 minutes
            frequency: .monthly, 
            category: .personal, 
            energy: 3,
            taskDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
            notification: NotificationModel.standard()
        ),
        TaskModel(
            name: "Dentist Appointment", 
            description: "Regular dental checkup and cleaning", 
            lengthMins: 60 * 60, // 1 hour
            frequency: .monthly, 
            category: .health, 
            energy: 2,
            taskDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date(),
            notification: NotificationModel(
                frequency: .once,
                type: .local,
                sound: .chime,
                content: "Dentist appointment reminder",
                timings: [NotificationTiming(minutesBeforeEvent: -60)]
            )
        ),
        
        // One-time tasks
        TaskModel(
            name: "Study Swift", 
            description: "Learn new SwiftUI features and iOS 18 updates", 
            lengthMins: 120 * 60, // 2 hours
            frequency: .none, 
            category: .study, 
            energy: 4,
            taskDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(),
            notification: NotificationModel.standard()
        ),
        TaskModel(
            name: "Project Presentation", 
            description: "Present quarterly project results to stakeholders", 
            lengthMins: 90 * 60, // 1.5 hours
            frequency: .none, 
            category: .work, 
            energy: 5,
            taskDate: Calendar.current.date(byAdding: .day, value: 8, to: Date()) ?? Date(),
            notification: NotificationModel(
                frequency: .once,
                type: .local,
                sound: .chime,
                content: "Project presentation in 30 minutes",
                timings: [NotificationTiming(minutesBeforeEvent: -30)]
            )
        ),
        TaskModel(
            name: "Doctor Checkup", 
            description: "Annual physical examination and health review", 
            lengthMins: 60 * 60, // 1 hour
            frequency: .none, 
            category: .health, 
            energy: 2,
            taskDate: Calendar.current.date(byAdding: .day, value: 12, to: Date()) ?? Date(),
            notification: NotificationModel.reminder()
        ),
        TaskModel(
            name: "Birthday Party Planning", 
            description: "Plan and organize friend's birthday celebration", 
            lengthMins: 180 * 60, // 3 hours
            frequency: .none, 
            category: .personal, 
            energy: 3,
            taskDate: Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date(),
            notification: NotificationModel.standard()
        ),
        
        // Future tasks (next month)
        TaskModel(
            name: "Conference Preparation", 
            description: "Prepare slides and materials for tech conference", 
            lengthMins: 240 * 60, // 4 hours
            frequency: .none, 
            category: .work, 
            energy: 5,
            taskDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(),
            notification: NotificationModel(
                frequency: .once,
                type: .local,
                sound: .chime,
                content: "Conference prep reminder",
                timings: [NotificationTiming(minutesBeforeEvent: -120)]
            )
        ),
        TaskModel(
            name: "Holiday Planning", 
            description: "Research and book summer vacation", 
            lengthMins: 120 * 60, // 2 hours
            frequency: .none, 
            category: .personal, 
            energy: 2,
            taskDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(),
            notification: NotificationModel.standard()
        )
    ]
}

extension TaskModel: Rewardable {
    var rewardFrequency: TaskFrequency { self.frequency }
    var rewardEnergy: Int { self.energy }
    var rewardLength: TimeInterval { self.lengthMins }
}
