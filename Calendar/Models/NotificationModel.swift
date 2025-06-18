import Foundation

// MARK: - Notification Frequency
enum NotificationFrequency: String, Codable, CaseIterable {
    case once
    case twice
    case custom // For future expansion
}

// MARK: - Notification Type
enum NotificationType: String, Codable, CaseIterable {
    case none
    case local
    case push
}

// MARK: - Notification Type
enum NotificationSound: String, Codable, CaseIterable {
    case defaultSound = "default"
    case chime = "chime.caf"
    case alert = "alert.caf"
    // Add more as needed

    var fileName: String? {
        switch self {
        case .defaultSound:
            return nil // Use system default
        default:
            return self.rawValue
        }
    }
}

// MARK: - Notification Model
struct NotificationModel: Codable, Hashable {
    var frequency: NotificationFrequency
    var type: NotificationType
    var sound: NotificationSound // Name of the sound file or system sound
    var content: String // The message/content of the notification
    
    init(frequency: NotificationFrequency, type: NotificationType, sound: NotificationSound, content: String) {
        self.frequency = frequency
        self.type = type
        self.sound = sound
        self.content = content
    }
} 
