//
//  CalendarViewModel.swift
//  Calendar
//
//  Created by Rhyse Summers on 10/06/2025.
//

import Foundation

class CalendarManager {
    /// Generates events for a given task from a start date for a specified number of days ahead.
    static func generateEvents(for task: TaskModel, from startDate: Date, daysAhead: Int) -> [EventModel] {
        var events: [EventModel] = []
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: .day, value: daysAhead, to: startDate) ?? startDate
        var currentDate = startDate
        
        // Helper to get next date based on frequency
        func nextDate(from date: Date, frequency: TaskFrequency) -> Date? {
            switch frequency {
            case .none:
                return nil
            case .daily:
                return calendar.date(byAdding: .day, value: 1, to: date)
            case .weekly:
                return calendar.date(byAdding: .weekOfYear, value: 1, to: date)
            case .monthly:
                return calendar.date(byAdding: .month, value: 1, to: date)
            }
        }
        
        // Assume task.frequency exists and is of type TaskFrequency
        let frequency = task.frequency
        let eventLength: TimeInterval = 60 * 60 // Default 1 hour, adjust as needed
        
        if frequency == .none {
            // One-off event
            let event = EventModel(from: task, scheduledDate: startDate, length: eventLength)
            events.append(event)
        } else {
            // Recurring events
            while currentDate <= endDate {
                let event = EventModel(from: task, scheduledDate: currentDate, length: eventLength)
                events.append(event)
                if let next = nextDate(from: currentDate, frequency: frequency) {
                    currentDate = next
                } else {
                    break
                }
            }
        }
        return events
    }

    /// Ensures the user's events array contains events for all tasks up to the given end date.
    static func ensureEvents(for user: UserModel, upTo endDate: Date) {
        for task in user.tasks {
            // Find the latest event for this task
            let taskEvents = user.events.filter { $0.taskId == task.id }
            let latestDate = taskEvents.map { $0.scheduledDate }.max() ?? Date()
            if latestDate < endDate {
                let newEvents = generateEvents(for: task, from: latestDate, daysAhead: Calendar.current.dateComponents([.day], from: latestDate, to: endDate).day ?? 0)
                user.events.append(contentsOf: newEvents)
            }
        }
    }
}
