
import Foundation
import SwiftUI

// MARK: - Task Event Model
struct TaskEvent: Identifiable, Codable, Hashable {
    let id: UUID
    let taskId: UUID
    let taskName: String
    let scheduledDate: Date
    let category: TaskCategory
    let energy: Int
    let notificationType: NotificationType
    var isCompleted: Bool
    var completedAt: Date?
    
    init(from task: TaskModel, scheduledDate: Date) {
        self.id = UUID()
        self.taskId = task.id
        self.taskName = task.name
        self.scheduledDate = scheduledDate
        self.category = task.category
        self.energy = task.energy
        self.notificationType = task.notificationType
        self.isCompleted = false
        self.completedAt = nil
    }
    
    mutating func markCompleted() {
        isCompleted = true
        completedAt = Date()
    }
    
    var isOverdue: Bool {
        !isCompleted && scheduledDate < Date()
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(scheduledDate)
    }
    
    var isUpcoming: Bool {
        scheduledDate > Date() && !Calendar.current.isDateInToday(scheduledDate)
    }
}

// MARK: - User Model
@Observable
final class UserModel: Identifiable, Codable {
    // MARK: - Properties
    let id: UUID
    var name: String
    var email: String
    var profile: URL? = nil
    var createdAt: Date
    var tasks: [TaskModel]
    var events: [TaskEvent]
    var preferences: UserPreferences
    
    // MARK: - Computed Properties
    var activeTasks: [TaskModel] {
        tasks.filter { !$0.isCompleted }
    }
    
    var completedTasks: [TaskModel] {
        tasks.filter { $0.isCompleted }
    }
    
    var todayEvents: [TaskEvent] {
        events.filter { $0.isToday }.sorted { $0.scheduledDate < $1.scheduledDate }
    }
    
    var upcomingEvents: [TaskEvent] {
        events.filter { $0.isUpcoming }.sorted { $0.scheduledDate < $1.scheduledDate }
    }
    
    var overdueEvents: [TaskEvent] {
        events.filter { $0.isOverdue }.sorted { $0.scheduledDate < $1.scheduledDate }
    }
    
//    var completedEvents: [TaskEvent] {
//        events.filter { $0.isCompleted }.sorted { $0.completedAt ?? Date() }
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
        self.preferences = UserPreferences()
    }
    
    // MARK: - Task Management
    func addTask(_ task: TaskModel) {
        tasks.append(task)
        generateEventsForTask(task)
    }
    
    func removeTask(_ task: TaskModel) {
        tasks.removeAll { $0.id == task.id }
        events.removeAll { $0.taskId == task.id }
    }
    
    func updateTask(_ task: TaskModel) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            // Remove old events and regenerate
            events.removeAll { $0.taskId == task.id }
            generateEventsForTask(task)
        }
    }
    
    // MARK: - Event Generation
    func generateEventsForTask(_ task: TaskModel) {
        guard task.notificationType != .none else { return }
        
        let startDate = preferences.eventGenerationStartDate
        let endDate = Calendar.current.date(byAdding: .month, value: preferences.eventGenerationMonths, to: startDate) ?? startDate
        
        switch task.notificationFrequency {
        case .once:
            generateOnceEvent(for: task, startDate: startDate)
        case .daily:
            generateDailyEvents(for: task, from: startDate, to: endDate)
        case .weekly:
            generateWeeklyEvents(for: task, from: startDate, to: endDate)
        }
    }
    
    private func generateOnceEvent(for task: TaskModel, startDate: Date) {
        let scheduledDate = preferences.preferredTimeOfDay.appliedTo(date: startDate)
        let event = TaskEvent(from: task, scheduledDate: scheduledDate)
        events.append(event)
    }
    
    private func generateDailyEvents(for task: TaskModel, from startDate: Date, to endDate: Date) {
        let calendar = Calendar.current
        var currentDate = startDate
        
        while currentDate <= endDate {
            let scheduledDate = preferences.preferredTimeOfDay.appliedTo(date: currentDate)
            let event = TaskEvent(from: task, scheduledDate: scheduledDate)
            events.append(event)
            
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
    }
    
    private func generateWeeklyEvents(for task: TaskModel, from startDate: Date, to endDate: Date) {
        let calendar = Calendar.current
        var currentDate = startDate
        
        // Align to preferred day of week if set
        if let preferredWeekday = preferences.preferredWeekday {
            let currentWeekday = calendar.component(.weekday, from: currentDate)
            let daysToAdd = (preferredWeekday - currentWeekday + 7) % 7
            currentDate = calendar.date(byAdding: .day, value: daysToAdd, to: currentDate) ?? currentDate
        }
        
        while currentDate <= endDate {
            let scheduledDate = preferences.preferredTimeOfDay.appliedTo(date: currentDate)
            let event = TaskEvent(from: task, scheduledDate: scheduledDate)
            events.append(event)
            
            guard let nextDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
    }
    
    // MARK: - Event Management
    func completeEvent(_ event: TaskEvent) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index].markCompleted()
        }
    }
    
    func regenerateAllEvents() {
        events.removeAll()
        for task in activeTasks {
            generateEventsForTask(task)
        }
    }
    
    // MARK: - Analytics
    func getCompletionRate(for period: DateInterval) -> Double {
        let periodEvents = events.filter { period.contains($0.scheduledDate) }
        guard !periodEvents.isEmpty else { return 0.0 }
        
        let completedCount = periodEvents.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(periodEvents.count)
    }
    
    func getEnergyDistribution() -> [TaskCategory: Int] {
        var distribution: [TaskCategory: Int] = [:]
        
        for task in tasks {
            distribution[task.category, default: 0] += task.energy
        }
        
        return distribution
    }
    
    func getTaskCountByCategory() -> [TaskCategory: Int] {
        var counts: [TaskCategory: Int] = [:]
        
        for task in tasks {
            counts[task.category, default: 0] += 1
        }
        
        return counts
    }
}

// MARK: - User Preferences
struct UserPreferences: Codable {
    var eventGenerationStartDate: Date
    var eventGenerationMonths: Int
    var preferredTimeOfDay: TimeOfDay
    var preferredWeekday: Int? // 1 = Sunday, 2 = Monday, etc.
    var enableNotifications: Bool
    var notificationTimeOffset: TimeInterval // seconds before event
    
    init() {
        self.eventGenerationStartDate = Date()
        self.eventGenerationMonths = 3
        self.preferredTimeOfDay = .morning
        self.preferredWeekday = nil
        self.enableNotifications = true
        self.notificationTimeOffset = 15 * 60 // 15 minutes
    }
}

// MARK: - Time of Day Helper
enum TimeOfDay: String, CaseIterable, Codable {
    case morning = "morning"
    case afternoon = "afternoon"
    case evening = "evening"
    
    var defaultHour: Int {
        switch self {
        case .morning: return 9
        case .afternoon: return 14
        case .evening: return 19
        }
    }
    
    var displayName: String {
        switch self {
        case .morning: return "Morning"
        case .afternoon: return "Afternoon"
        case .evening: return "Evening"
        }
    }
    
    func appliedTo(date: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = defaultHour
        components.minute = 0
        components.second = 0
        
        return calendar.date(from: components) ?? date
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
            category: .health,
            energy: 4,
            notificationType: .local,
            notificationFrequency: .daily
        )
        
        let codeReviewTask = TaskModel(
            name: "Code Review",
            description: "Review team's pull requests",
            category: .work,
            energy: 3,
            notificationType: .push,
            notificationFrequency: .daily
        )
        
        let weeklyPlanningTask = TaskModel(
            name: "Weekly Planning",
            description: "Plan tasks for the upcoming week",
            category: .work,
            energy: 2,
            notificationType: .local,
            notificationFrequency: .weekly
        )
        
        user.addTask(workoutTask)
        user.addTask(codeReviewTask)
        user.addTask(weeklyPlanningTask)
        
        // Set preferences
        user.preferences.preferredWeekday = 2 // Monday for weekly tasks
        user.preferences.preferredTimeOfDay = .morning
        
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
        return "User(name: \(name), tasks: \(tasks.count), events: \(events.count))"
    }
}
