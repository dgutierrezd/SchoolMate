import SwiftUI

struct NotificationSettingsView: View {
    @AppStorage("notifyHomeworkDue") private var notifyHomeworkDue = true
    @AppStorage("notifyMorningSummary") private var notifyMorningSummary = true
    @AppStorage("notifyStudyStreak") private var notifyStudyStreak = true
    @AppStorage("notifyWeeklyReport") private var notifyWeeklyReport = true

    var body: some View {
        List {
            Section("Homework") {
                Toggle(isOn: $notifyHomeworkDue) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Due Date Reminders")
                            .font(.appBody)
                        Text("Get notified 1 day before homework is due")
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Daily") {
                Toggle(isOn: $notifyMorningSummary) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Morning Summary")
                            .font(.appBody)
                        Text("Daily overview of tasks at 8:00 AM")
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                    }
                }

                Toggle(isOn: $notifyStudyStreak) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Study Streak")
                            .font(.appBody)
                        Text("Reminder when a study streak might break")
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Weekly") {
                Toggle(isOn: $notifyWeeklyReport) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Weekly Report")
                            .font(.appBody)
                        Text("Weekly summary every Sunday at 6:00 PM")
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .tint(Color.primaryPurple)
        .scrollContentBackground(.hidden)
        .background(Color.backgroundGray)
        .navigationTitle(LocalizedStringKey("notifications"))
    }
}
