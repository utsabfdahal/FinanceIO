//
//  NotificationManager.swift
//  FinanceIO
//
//  Created on 2/23/26.
//

import Foundation
import UserNotifications

/// Handles scheduling and canceling the daily expense reminder notification.
struct NotificationManager {

    static let reminderIdentifier = "daily-expense-reminder"

    /// Requests notification permission and, if granted, schedules the daily 9 PM reminder.
    static func enableDailyReminder() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            scheduleDailyReminder()
        }
    }

    /// Schedules a repeating local notification every day at 9:00 PM.
    static func scheduleDailyReminder() {
        let center = UNUserNotificationCenter.current()

        // Remove any existing reminder first
        center.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])

        let content = UNMutableNotificationContent()
        content.title = "Log Your Expenses"
        content.body = "Take a moment to record today's expenses in FinanceIO."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 21  // 9 PM
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: reminderIdentifier,
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error {
                print("NotificationManager: Failed to schedule reminder - \(error.localizedDescription)")
            }
        }
    }

    /// Cancels the daily reminder notification.
    static func cancelDailyReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
    }

    /// Checks whether the daily reminder is currently scheduled.
    static func isReminderScheduled(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let found = requests.contains { $0.identifier == reminderIdentifier }
            DispatchQueue.main.async {
                completion(found)
            }
        }
    }
}
