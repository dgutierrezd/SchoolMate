import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    private let api = APIClient.shared

    private init() {}

    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            return false
        }
    }

    func registerDeviceToken(_ token: String) async throws {
        struct RegisterRequest: Codable {
            let token: String
            let platform: String
        }

        try await api.requestVoid(
            path: "/notifications/register",
            method: "POST",
            body: RegisterRequest(token: token, platform: "ios")
        )
    }

    func unregisterDeviceToken(_ token: String) async throws {
        struct UnregisterRequest: Codable {
            let token: String
        }

        try await api.requestVoid(
            path: "/notifications/unregister",
            method: "DELETE",
            body: UnregisterRequest(token: token)
        )
    }

    func scheduleLocalHomeworkReminder(
        homeworkId: String,
        title: String,
        childName: String,
        dueDate: Date
    ) {
        let content = UNMutableNotificationContent()
        content.title = "homework_reminder_title".localized(childName)
        content.body = title
        content.sound = .default

        // Reminder: 1 day before due date at 8:00 AM
        var reminderDate = Calendar.current.date(byAdding: .day, value: -1, to: dueDate) ?? dueDate
        reminderDate = Calendar.current.date(
            bySettingHour: 8,
            minute: 0,
            second: 0,
            of: reminderDate
        ) ?? reminderDate

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminderDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "homework-\(homeworkId)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func removeHomeworkReminder(homeworkId: String) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["homework-\(homeworkId)"])
    }
}
