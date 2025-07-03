//
//  UserModel.swift
//  Calendar
//
//  Created by Rhyse Summers on 10/06/2025.
//

import SwiftUI
import Foundation
import Combine

// MARK: - User Model

final class UserModel: ObservableObject, Identifiable, Codable {
    // MARK: - Properties
    let id: UUID
    @Published var name: String
    @Published var email: String
    @Published var profile: URL?
    @Published var createdAt: Date
    @Published var tasks: [TaskModel]
    @Published var events: [EventModel]
    @Published var xp: Int
    @Published var level: Int // User's current level
    @Published var coins: Int
    @Published var xpEarnedToday: Int // XP earned today (for daily cap)
    @Published var lastXPAwardDate: Date? // Last date XP was awarded
//    var preferences: UserPreferences
    
    // Combine cancellable for observing events changes
    private var eventsCancellable: AnyCancellable?
    // Store previous events for diffing
    private var previousEvents: [EventModel] = []
    
    // MARK: - XP/Level System
    /// Returns the XP required to reach the next level (exponential curve)
    func requiredXP(for level: Int) -> Int {
        let baseXP = 100
        let growthFactor = 1.14
        return Int(Double(baseXP) * pow(growthFactor, Double(level - 1)))
    }
    
    /// Awards XP for a completed event, respecting the daily XP cap (default 200 XP/day)
    func awardXPForEvent(_ event: EventModel, xpCap: Int = 200) {
        let today = Calendar.current.startOfDay(for: Date())
        if let lastDate = lastXPAwardDate, Calendar.current.isDate(lastDate, inSameDayAs: today) {
            // Same day, do nothing
        } else {
            // New day, reset
            xpEarnedToday = 0
        }
        let xpToAward = min(RewardCalculator.xp(for: event, completion: event.completionPercentage), xpCap - xpEarnedToday)
        if xpToAward > 0 {
            addXP(xpToAward)
            xpEarnedToday += xpToAward
            lastXPAwardDate = today
        }
    }
    
    /// Adds XP and handles level up logic
    func addXP(_ amount: Int) {
        xp += amount
        while xp >= requiredXP(for: level) {
            xp -= requiredXP(for: level)
            level += 1
            // Optionally: trigger level up notification here
        }
    }
    /// Progress to next level (0.0 - 1.0)
    var levelProgress: Double {
        Double(xp) / Double(requiredXP(for: level))
    }
    
    // MARK: - Coin System
    /// Awards coins for a completed task (no daily cap)
    func awardCoinsForTask(_ task: TaskModel) {
        let coinsToAward = RewardCalculator.coins(for: task)
        coins += coinsToAward
    }
    
    /// Awards coins for a completed event (no daily cap)
    func awardCoinsForEvent(_ event: EventModel) {
        let coinsToAward = RewardCalculator.coins(for: event, completion: event.completionPercentage)
        coins += coinsToAward
    }
    
    // MARK: - Daily Reward System (commented out)
    // Uncomment to enable daily bonus for first task completion each day
    // @Published var lastDailyRewardDate: Date? // Already present for XP, reused for coins
    // let dailyBonusAmount = 20 // Amount of bonus coins for daily reward
    // /// Checks and awards daily bonus coins if not already awarded today
    // func checkAndAwardDailyBonus() {
    //     let today = Calendar.current.startOfDay(for: Date())
    //     if lastDailyRewardDate == nil || !Calendar.current.isDate(lastDailyRewardDate!, inSameDayAs: today) {
    //         coins += dailyBonusAmount
    //         lastDailyRewardDate = today
    //         // Optionally: show animation or message here
    //     }
    // }
    // Call checkAndAwardDailyBonus() when a task is completed to trigger the daily bonus
    
    // MARK: - Computed Properties
//    var activeTasks: [TaskModel] {
//        tasks.filter { !$0.isCompleted }
//    }
//
//    var todayEvents: [TaskEvent] {
//        events.filter { $0.isToday }.sorted { $0.scheduledDate < $1.scheduledDate }
//    }

    
    // MARK: - Initialization
    init(name: String, email: String) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.profile = nil
        self.createdAt = Date()
        self.tasks = []
        self.events = []
        self.xp = 0
        self.level = 1
        self.coins = 0
        self.xpEarnedToday = 0
        self.lastXPAwardDate = nil
//        self.preferences = UserPreferences()
        observeEventsForNotifications()
    }
    
    // MARK: - Task Management
    func addTask(_ task: TaskModel) {
        tasks.append(task)
        //generateEventsForTask(task)
    }
    
    func removeTask(_ task: TaskModel) {
        tasks.removeAll { $0.id == task.id }
        // Remove associated events and cancel their notifications
        let eventsToRemove = events.filter { $0.taskId == task.id }
        for event in eventsToRemove {
            NotificationManager.shared.cancelNotifications(for: event)
        }
        events.removeAll { $0.taskId == task.id }
    }
    
    // Update event notifications when task notification settings change
    func updateEventNotifications(for task: TaskModel) {
        for i in events.indices {
            if events[i].taskId == task.id {
                // Update the event's notification settings
                events[i].updateNotification(from: task)
                // Reschedule notifications for this event
                NotificationManager.shared.scheduleNotifications(for: events[i], notification: events[i].notification)
            }
        }
    }
    
    func logout() {
        self.name = ""
        self.email = ""
        self.profile = nil
        self.tasks = []
        self.events = []
        self.xp = 0
        self.coins = 0
    }
    
    func updateTask(_ task: TaskModel) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            // Update event notifications for this task
            updateEventNotifications(for: task)
        }
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, name, email, profile, createdAt, tasks, events, xp, level, coins, xpEarnedToday, lastXPAwardDate
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
        profile = try container.decodeIfPresent(URL.self, forKey: .profile)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        tasks = try container.decode([TaskModel].self, forKey: .tasks)
        events = try container.decode([EventModel].self, forKey: .events)
        xp = try container.decode(Int.self, forKey: .xp)
        level = try container.decodeIfPresent(Int.self, forKey: .level) ?? 1
        coins = try container.decode(Int.self, forKey: .coins)
        xpEarnedToday = try container.decodeIfPresent(Int.self, forKey: .xpEarnedToday) ?? 0
        lastXPAwardDate = try container.decodeIfPresent(Date.self, forKey: .lastXPAwardDate)
        observeEventsForNotifications()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encode(profile, forKey: .profile)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(tasks, forKey: .tasks)
        try container.encode(events, forKey: .events)
        try container.encode(xp, forKey: .xp)
        try container.encode(level, forKey: .level)
        try container.encode(coins, forKey: .coins)
        try container.encode(xpEarnedToday, forKey: .xpEarnedToday)
        try container.encode(lastXPAwardDate, forKey: .lastXPAwardDate)
    }

    // Observe events array for changes and schedule/cancel notifications
    private func observeEventsForNotifications() {
        eventsCancellable = $events
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newEvents in
                self?.handleEventNotifications(newEvents: newEvents)
            }
    }

    // Handle scheduling/cancelling notifications based on event changes
    private func handleEventNotifications(newEvents: [EventModel]) {
        let now = Date()
        let thirtyDaysFromNow = Calendar.current.date(byAdding: .day, value: 30, to: now) ?? now
        // Only consider events within the next 30 days
        let upcomingEvents = newEvents.filter { $0.scheduledDate >= now && $0.scheduledDate <= thirtyDaysFromNow }
        let previousUpcomingEvents = previousEvents.filter { $0.scheduledDate >= now && $0.scheduledDate <= thirtyDaysFromNow }
        // Cancel notifications for removed events
        let removedEvents = previousUpcomingEvents.filter { !upcomingEvents.contains($0) }
        for event in removedEvents {
            NotificationManager.shared.cancelNotifications(for: event)
        }
        // Schedule notifications for new events using the inherited notification settings
        for event in upcomingEvents {
            NotificationManager.shared.scheduleNotifications(for: event, notification: event.notification)
        }
        // Update previousEvents
        previousEvents = newEvents
    }
}

// MARK: - Usage Example
extension UserModel {
    static func createSampleUser() -> UserModel {
        let user = UserModel(name: "John Doe", email: "john@example.com")
        
        // Add some sample tasks
        let workoutTask = TaskModel(
            name: "Morning Workout",
            description: "30-minute cardio session",
            frequency: .none,
            category: .health,
            energy: 4,
            taskDate: Date(),
//            notificationType: .local,
//            notificationFrequency: .daily
        )
        
        let codeReviewTask = TaskModel(
            name: "Code Review",
            description: "Review team's pull requests",
            frequency: .none,
            category: .work,
            energy: 3,
            taskDate: Date(),
//            notificationType: .push,
//            notificationFrequency: .daily
        )
        
        let weeklyPlanningTask = TaskModel(
            name: "Weekly Planning",
            description: "Plan tasks for the upcoming week",
            frequency: .none,
            category: .work,
            energy: 2,
            taskDate: Date(),
//            notificationType: .local,
//            notificationFrequency: .weekly
        )
        
        user.addTask(workoutTask)
        user.addTask(codeReviewTask)
        user.addTask(weeklyPlanningTask)
        
        // Set preferences
//        user.preferences.preferredWeekday = 2 // Monday for weekly tasks
//        user.preferences.preferredTimeOfDay = .morning
        
        return user
    }
}

// MARK: - UserModel Extensions
extension UserModel: Hashable {
    static func == (lhs: UserModel, rhs: UserModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension UserModel: CustomStringConvertible {
    var description: String {
        return "User(name: \(name), tasks: \(tasks.count))" //, events: \(events.count)
    }
}
