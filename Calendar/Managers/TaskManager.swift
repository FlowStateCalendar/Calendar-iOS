import Foundation
import SwiftUI

struct TaskManager {
    /// Assigns all sample tasks to the user's task list.
    static func assignSampleTasks(to user: UserModel) {
        user.tasks = TaskModel.sampleTasks
        notifyUserOfTaskAssignment(user: user)
    }

    /// Stub: Triggers an in-app notification for task assignment.
    /// In the future, integrate with NotificationManager and NotificationModel.
    static func notifyUserOfTaskAssignment(user: UserModel) {
        // For now, just print a message or update a property for in-app notification.
        // Example: You could set a @Published property in AppState or UserModel to show an alert.
        print("[In-App Notification] Tasks have been assigned to \(user.name)")
        // TODO: Integrate with NotificationManager and NotificationModel for real notifications.
    }
} 