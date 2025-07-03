//
//  EventModel.swift
//  Calendar
//
//  Created by Rhyse Summers on 12/06/2025.
//

import Foundation
import SwiftUI

// MARK: - Task Event Model
struct EventModel: Identifiable, Codable, Hashable {
    let id: UUID
    let taskId: UUID
    let taskName: String
    var scheduledDate: Date
    var length: TimeInterval // in seconds
    var completionPercentage: Double // 0.0 to 1.0
    let energy: Int
    let taskCategory: TaskCategory
    let frequency: TaskFrequency
    // Store the inherited notification settings from the task
    var notification: NotificationModel
    var baseXP: Int
    var baseCoins: Int

    init(from task: TaskModel, scheduledDate: Date) {
        self.id = UUID()
        self.taskId = task.id
        self.taskName = task.name
        self.scheduledDate = scheduledDate
        self.length = task.lengthMins
        self.completionPercentage = 0.0
        self.energy = task.energy
        self.taskCategory = task.category
        self.frequency = task.frequency
        self.notification = task.notification
        // Inherit base reward values from the task
        self.baseXP = RewardCalculator.baseXP(rewardFrequency: task.frequency, rewardEnergy: task.energy)
        self.baseCoins = RewardCalculator.baseCoins(rewardFrequency: task.frequency, rewardEnergy: task.energy)
    }
    
    // Update notification settings (useful when task notification settings change)
    mutating func updateNotification(from task: TaskModel) {
        self.notification = task.notification
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(scheduledDate)
    }
    
    // Returns true if the event is fully completed
    var isComplete: Bool {
        completionPercentage == 1.0
    }
    // Returns true if the event has not been started
    var isUnstarted: Bool {
        completionPercentage == 0.0
    }
    
    @available(*, deprecated, message: "Use the isComplete property instead.")
    func isCompleted() -> Bool {
        return isComplete
    }
}

extension EventModel: Rewardable {
    var rewardFrequency: TaskFrequency { self.frequency }
    var rewardEnergy: Int { self.energy }
    var rewardLength: TimeInterval { self.length }
}


