//
//  CalendarModel.swift
//  Calendar
//
//  Created by Rhyse Summers on 10/06/2025.
//

import SwiftUI
import Foundation

/// A type-safe representation of the different calendar views.
/// CaseIterable allows us to easily use it in a Picker.
enum CalendarScope: String, CaseIterable {
    case month = "Month"
    case week = "Week"
    case day = "Day"
}

/// Represents a single day in the calendar grid.
struct CalendarDay: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let isInCurrentMonth: Bool
}

/// A placeholder model for events that could be displayed in the Day view.
struct Event: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    let color: Color // Example property for event-specific color

    // Sample events for demonstration
    static var sampleEvents: [Event] {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        return [
            Event(title: "Team Standup", date: today, color: .blue),
            Event(title: "Project Deadline", date: today, color: .red),
            Event(title: "Lunch with Sarah", date: today, color: .green),
            Event(title: "Dentist Appointment", date: tomorrow, color: .orange),
            Event(title: "Gym Session", date: yesterday, color: .purple)
        ]
    }
}
