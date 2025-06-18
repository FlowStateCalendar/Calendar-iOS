//
//  PreferenceModel.swift
//  Calendar
//
//  Created by Rhyse Summers on 17/06/2025.
//

import SwiftUI

//// MARK: - User Preferences
//struct UserPreferences: Codable {
//    var eventGenerationStartDate: Date
//    var eventGenerationMonths: Int
//    var preferredTimeOfDay: TimeOfDay
//    var preferredWeekday: Int? // 1 = Sunday, 2 = Monday, etc.
//    var enableNotifications: Bool
//    var notificationTimeOffset: TimeInterval // seconds before event
//
//    init() {
//        self.eventGenerationStartDate = Date()
//        self.eventGenerationMonths = 3
//        self.preferredTimeOfDay = .morning
//        self.preferredWeekday = nil
//        self.enableNotifications = true
//        self.notificationTimeOffset = 15 * 60 // 15 minutes
//    }
//}
//
//// MARK: - Time of Day Helper
//enum TimeOfDay: String, CaseIterable, Codable {
//    case morning = "morning"
//    case afternoon = "afternoon"
//    case evening = "evening"
//
//    var defaultHour: Int {
//        switch self {
//        case .morning: return 9
//        case .afternoon: return 14
//        case .evening: return 19
//        }
//    }
//
//    var displayName: String {
//        switch self {
//        case .morning: return "Morning"
//        case .afternoon: return "Afternoon"
//        case .evening: return "Evening"
//        }
//    }
//
//    func appliedTo(date: Date) -> Date {
//        let calendar = Calendar.current
//        var components = calendar.dateComponents([.year, .month, .day], from: date)
//        components.hour = defaultHour
//        components.minute = 0
//        components.second = 0
//
//        return calendar.date(from: components) ?? date
//    }
//}
