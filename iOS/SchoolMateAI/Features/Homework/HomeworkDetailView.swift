import SwiftUI

struct HomeworkDetailView: View {
    @State var homework: Homework
    @ObservedObject var viewModel: HomeworkViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isCompleting = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                // Status Badge
                HStack {
                    StatusBadge(status: homework.status)
                    Spacer()
                    PriorityBadge(priority: homework.priority)
                }

                // Title
                Text(homework.title)
                    .font(.appTitle)
                    .foregroundStyle(Color.textPrimary)

                // Subject
                if let subject = homework.subjects {
                    HStack(spacing: 8) {
                        Text(subject.icon)
                        Text(subject.name)
                            .font(.appBody)
                            .foregroundStyle(Color(hex: subject.color))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hex: subject.color).opacity(0.1))
                    .clipShape(Capsule())
                }

                // Due Date
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .foregroundStyle(Color.primaryPurple)
                    Text(homework.dueDate, style: .date)
                    Text(homework.dueDate, style: .time)
                }
                .font(.appBody)
                .foregroundStyle(.secondary)

                // Description
                if let description = homework.description {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.appHeadline)
                            .foregroundStyle(Color.textPrimary)
                        Text(description)
                            .font(.appBody)
                            .foregroundStyle(.secondary)
                    }
                    .cardStyle()
                }

                // AI Summary
                if let summary = homework.aiSummary {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "brain")
                                .foregroundStyle(Color.primaryPurple)
                            Text("AI Summary")
                                .font(.appHeadline)
                                .foregroundStyle(Color.textPrimary)
                        }
                        Text(summary)
                            .font(.appBody)
                            .foregroundStyle(.secondary)
                    }
                    .cardStyle()
                }

                // Complete Button
                if homework.status != .completed {
                    Button {
                        Task {
                            isCompleting = true
                            await viewModel.markComplete(id: homework.id)
                            homework.status = .completed
                            isCompleting = false
                        }
                    } label: {
                        HStack {
                            if isCompleting {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Mark as Complete")
                            }
                        }
                        .font(.appButtonLabel)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentGreen)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                    }
                    .disabled(isCompleting)
                } else {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.accentGreen)
                        Text("Completed")
                            .font(.appButtonLabel)
                            .foregroundStyle(Color.accentGreen)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentGreen.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                }
            }
            .padding(AppSpacing.md)
        }
        .background(Color.backgroundGray)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StatusBadge: View {
    let status: HomeworkStatus

    private var color: Color {
        switch status {
        case .pending: return Color.accentOrange
        case .inProgress: return Color.primaryPurple
        case .completed: return Color.accentGreen
        case .overdue: return Color.accentRed
        }
    }

    var body: some View {
        Text(status.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
            .font(.appCaption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

struct PriorityBadge: View {
    let priority: HomeworkPriority

    private var color: Color {
        switch priority {
        case .low: return Color.accentGreen
        case .medium: return Color.accentOrange
        case .high: return Color.accentRed
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: priority == .high ? "exclamationmark.triangle.fill" : "flag.fill")
                .font(.caption2)
            Text(priority.rawValue.capitalized)
                .font(.appCaption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(color.opacity(0.15))
        .foregroundStyle(color)
        .clipShape(Capsule())
    }
}
