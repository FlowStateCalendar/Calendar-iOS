import Foundation
import SwiftUI

enum NotificationType: String, CaseIterable, Codable {
    case none, local, push
}

enum NotificationFrequency: String, CaseIterable, Codable {
    case once, daily, weekly
}

enum TaskCategory: String, CaseIterable, Codable {
    case work, health, personal, study, other
}

class TaskModel: ObservableObject, Identifiable, Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case category
        case energy
        case notificationType
        case notificationFrequency
    }

    // MARK: - Properties
    @Published var id = UUID()
    @Published var name: String
    @Published var description: String
    @Published var category: TaskCategory
    @Published var energy: Int
    @Published var notificationType: NotificationType
    @Published var notificationFrequency: NotificationFrequency

    // MARK: - Init
    init(
        name: String,
        description: String,
        category: TaskCategory,
        energy: Int,
        notificationType: NotificationType,
        notificationFrequency: NotificationFrequency
    ) {
        self.name = name
        self.description = description
        self.category = category
        self.energy = energy
        self.notificationType = notificationType
        self.notificationFrequency = notificationFrequency
    }

    // MARK: - Codable Conformance
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        category = try container.decode(TaskCategory.self, forKey: .category)
        energy = try container.decode(Int.self, forKey: .energy)
        notificationType = try container.decode(NotificationType.self, forKey: .notificationType)
        notificationFrequency = try container.decode(NotificationFrequency.self, forKey: .notificationFrequency)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(category, forKey: .category)
        try container.encode(energy, forKey: .energy)
        try container.encode(notificationType, forKey: .notificationType)
        try container.encode(notificationFrequency, forKey: .notificationFrequency)
    }

    // MARK: - Example Mutators
    func updateName(to newName: String) {
        self.name = newName
    }

    func configureTask(name: String, description: String, category: TaskCategory, energy: Int) {
        self.name = name
        self.description = description
        self.category = category
        self.energy = min(max(energy, 1), 5)
    }
}
