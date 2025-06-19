//
//  CalendarViewModel.swift
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
    
    // Schedule a notification for an event
    func scheduleNotification(for event: EventModel, notification: NotificationModel) {
        let content = UNMutableNotificationContent()
        content.title = event.taskName
        content.body = notification.content
        if let fileName = notification.sound.fileName {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: fileName))
        } else {
            content.sound = .default
        }
        
        // Trigger at the event's scheduled date
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: event.scheduledDate)
        let repeats = notification.frequency != .once
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: repeats)
        
        let request = UNNotificationRequest(identifier: event.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}

// Example usage:
// NotificationManager.shared.requestNotificationPermission { granted in
//     if granted {
//         NotificationManager.shared.scheduleNotification(for: event, notification: notificationModel)
//     }
// } 
