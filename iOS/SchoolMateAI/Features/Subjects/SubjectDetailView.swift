import SwiftUI

struct SubjectDetailView: View {
    let subject: Subject

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                // Header
                HStack(spacing: AppSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: subject.color).opacity(0.2))
                            .frame(width: 64, height: 64)
                        Text(subject.icon)
                            .font(.system(size: 32))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(subject.name)
                            .font(.appTitle)
                            .foregroundStyle(Color.textPrimary)
                        if let teacher = subject.teacherName {
                            Label(teacher, systemImage: "person.fill")
                                .font(.appBody)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Notes
                if let notes = subject.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.appHeadline)
                            .foregroundStyle(Color.textPrimary)
                        Text(notes)
                            .font(.appBody)
                            .foregroundStyle(.secondary)
                    }
                    .cardStyle()
                }

                // Quick Actions
                VStack(spacing: AppSpacing.md) {
                    NavigationLink {
                        HomeworkListView()
                    } label: {
                        ActionRow(
                            icon: "list.clipboard",
                            title: "View Homework",
                            color: Color.primaryPurple
                        )
                    }

                    NavigationLink {
                        FlashcardDeckView()
                    } label: {
                        ActionRow(
                            icon: "rectangle.stack",
                            title: "Study Flashcards",
                            color: Color.accentGreen
                        )
                    }
                }
            }
            .padding(AppSpacing.md)
        }
        .background(Color.backgroundGray)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ActionRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 32)
            Text(title)
                .font(.appBody)
                .foregroundStyle(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .cardStyle()
    }
}
