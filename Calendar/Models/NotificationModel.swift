//
//  NotificationModel.swift
//  Calendar
//
//  Created by Rhyse Summers on 15/06/2025.
//

import Foundation

// MARK: - Notification Frequency
enum NotificationFrequency: String, Codable, CaseIterable {
    case none = "None"
    case once = "Once"
    case custom = "Custom"
    
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Notification Type
enum NotificationType: String, Codable, CaseIterable {
    case none = "None"
    case local = "Local"
    
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Notification Sound
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
    
    var displayName: String {
        switch self {
        case .defaultSound: return "Default"
        case .chime: return "Chime"
        case .alert: return "Alert"
        }
    }
}

// MARK: - Notification Timing
struct NotificationTiming: Codable, Hashable {
    let minutesBeforeEvent: Int // Negative value means before, positive means after
    let isEnabled: Bool
    
    init(minutesBeforeEvent: Int, isEnabled: Bool = true) {
        self.minutesBeforeEvent = minutesBeforeEvent
        self.isEnabled = isEnabled
    }
    
    var displayText: String {
        if minutesBeforeEvent == 0 {
            return "At event time"
        } else if minutesBeforeEvent > 0 {
            return "\(minutesBeforeEvent) min after"
        } else {
            return "\(abs(minutesBeforeEvent)) min before"
        }
    }
}

// MARK: - Notification Model
struct NotificationModel: Codable, Hashable {
    var frequency: NotificationFrequency
    var type: NotificationType
    var sound: NotificationSound
    var content: String
    var timings: [NotificationTiming] // Multiple notification times
    
    init(frequency: NotificationFrequency = .once, 
         type: NotificationType = .local, 
         sound: NotificationSound = .defaultSound, 
         content: String = "",
         timings: [NotificationTiming] = [NotificationTiming(minutesBeforeEvent: -15)]) {
        self.frequency = frequency
        self.type = type
        self.sound = sound
        self.content = content
        self.timings = timings
    }
    
    // Convenience initializer for common notification patterns
    static func standard() -> NotificationModel {
        return NotificationModel(
            frequency: .once,
            type: .local,
            sound: .defaultSound,
            content: "Your task is starting soon!",
            timings: [NotificationTiming(minutesBeforeEvent: -15)]
        )
    }
    
    static func reminder() -> NotificationModel {
        return NotificationModel(
            frequency: .once,
            type: .local,
            sound: .chime,
            content: "Don't forget your task!",
            timings: [
                NotificationTiming(minutesBeforeEvent: -10)   // 10 minutes before
            ]
        )
    }
} 
