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
//    let category: TaskCategory
//    let energy: Int
//    let notificationType: NotificationType
    var isCompleted: Bool
//    var completedAt: Date?
    
    init(from task: TaskModel, scheduledDate: Date) {
        self.id = UUID()
        self.taskId = task.id
        self.taskName = task.name
        self.scheduledDate = scheduledDate
//        self.category = task.category
//        self.energy = task.energy
//        self.notificationType = task.notificationType
        self.isCompleted = false
//        self.completedAt = nil
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


