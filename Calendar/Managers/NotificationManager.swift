//
//  NotificationManager.swift
//  Calendar
//
//  Created by Rhyse Summers on 10/06/2025.
//

import Foundation
import UserNotifications
import SwiftUI


class NotificationManager {
    static let shared = NotificationManager()
    private init() {}
    
    // Request notification permission
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    // Schedule multiple notifications for an event based on notification model
    func scheduleNotifications(for event: EventModel, notification: NotificationModel) {
        // Cancel any existing notifications for this event first
        cancelNotifications(for: event)
        
        // Only schedule if notification type is not none
        guard notification.type != .none else { return }
        
        // Schedule a notification for each timing
        for (index, timing) in notification.timings.enumerated() {
            guard timing.isEnabled else { continue }
            
            let content = UNMutableNotificationContent()
            content.title = event.taskName
            content.body = notification.content.isEmpty ? "Your task is starting soon!" : notification.content
            
            // Set sound
            if let fileName = notification.sound.fileName {
                content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: fileName))
            } else {
                content.sound = .default
            }
            
            // Calculate notification time based on timing
            let notificationDate = Calendar.current.date(byAdding: .minute, value: timing.minutesBeforeEvent, to: event.scheduledDate) ?? event.scheduledDate
            
            // Only schedule if the notification time is in the future
            guard notificationDate > Date() else { continue }
            
            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            // Create unique identifier for each notification
            let identifier = "\(event.id.uuidString)_notification_\(index)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                } else {
                    print("Scheduled notification for \(event.taskName) at \(notificationDate)")
                }
            }
        }
    }
    
    // Cancel all notifications for a specific event
    func cancelNotifications(for event: EventModel) {
        let identifiers = notificationIdentifiers(for: event)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        print("Cancelled notifications for event: \(event.taskName)")
    }
    
    // Get all notification identifiers for an event
    private func notificationIdentifiers(for event: EventModel) -> [String] {
        // Generate identifiers for up to 10 possible notifications per event
        return (0..<10).map { "\(event.id.uuidString)_notification_\($0)" }
    }
    
    // Cancel all notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("Cancelled all pending notifications")
    }
    
    // Get pending notifications count
    func getPendingNotificationsCount(completion: @escaping (Int) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests.count)
            }
        }
    }
}

// Example usage:
// NotificationManager.shared.requestNotificationPermission { granted in
//     if granted {
//         NotificationManager.shared.scheduleNotifications(for: event, notification: task.notification)
//     }
// } 
