//
//  EventModel.swift
//  Calendar
//
//  Created by Rhyse Summers on 10/06/2025.
//

import Foundation
import SwiftUI

// MARK: - Task Event Model
struct EventModel: Identifiable, Codable, Hashable {
    let id: UUID
    let taskId: UUID
    let taskName: String
    let scheduledDate: Date
    let length: TimeInterval // in seconds
    var completionPercentage: Double // 0.0 to 1.0
    let energy: Int
    let taskCategory: TaskCategory
    var isCompleted: Bool
    // Placeholder for future notification model
    // var notification: NotificationModel?

    init(from task: TaskModel, scheduledDate: Date, length: TimeInterval) {
        self.id = UUID()
        self.taskId = task.id
        self.taskName = task.name
        self.scheduledDate = scheduledDate
        self.length = length
        self.completionPercentage = 0.0
        self.energy = task.energy
        self.taskCategory = task.category
        self.isCompleted = false
        // self.notification = nil // For future use
    }
    
//    mutating func markCompleted() {
//        isCompleted = true
//        completedAt = Date()
//    }
    
//    var isOverdue: Bool {
//        !isCompleted && scheduledDate < Date()
//    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(scheduledDate)
    }
}


