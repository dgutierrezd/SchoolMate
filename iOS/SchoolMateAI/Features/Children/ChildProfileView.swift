import SwiftUI

struct ChildProfileView: View {
    let child: Child
    @StateObject private var viewModel = ChildrenViewModel()
    @State private var isRegeneratingContext = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // Avatar & Info Header
                VStack(spacing: AppSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: child.avatarColor))
                            .frame(width: 100, height: 100)
                        Text(child.avatarEmoji)
                            .font(.system(size: 48))
                    }

                    Text(child.name)
                        .font(.appTitle)
                        .foregroundStyle(Color.textPrimary)

                    HStack(spacing: AppSpacing.md) {
                        Label(child.grade, systemImage: "graduationcap.fill")
                        if let school = child.school {
                            Label(school, systemImage: "building.2.fill")
                        }
                    }
                    .font(.appBody)
                    .foregroundStyle(.secondary)
                }
                .padding(.top, AppSpacing.lg)

                // Subjects
                if let subjects = child.subjects, !subjects.isEmpty {
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text(LocalizedStringKey("subjects"))
                            .font(.appHeadline)
                            .foregroundStyle(Color.textPrimary)

                        ForEach(subjects) { subject in
                            NavigationLink(destination: SubjectDetailView(subject: subject)) {
                                HStack(spacing: AppSpacing.md) {
                                    Text(subject.icon)
                                        .font(.title2)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(subject.name)
                                            .font(.appBody)
                                            .fontWeight(.medium)
                                            .foregroundStyle(.primary)
                                        if let teacher = subject.teacherName {
                                            Text(teacher)
                                                .font(.appCaption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.tertiary)
                                }
                                .cardStyle()
                            }
                        }
                    }
                }

                // AI Study Profile
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack {
                        Label("AI Study Profile", systemImage: "brain")
                            .font(.appHeadline)
                            .foregroundStyle(Color.textPrimary)
                        Spacer()
                        Button {
                            Task {
                                isRegeneratingContext = true
                                await viewModel.regenerateAIContext(childId: child.id)
                                isRegeneratingContext = false
                            }
                        } label: {
                            if isRegeneratingContext {
                                ProgressView()
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                        .tint(Color.primaryPurple)
                    }

                    if let context = child.aiContext {
                        Text(context)
                            .font(.appBody)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Tap refresh to generate an AI profile for \(child.name)")
                            .font(.appBody)
                            .foregroundStyle(.tertiary)
                            .italic()
                    }
                }
                .cardStyle()
            }
            .padding(AppSpacing.md)
        }
        .background(Color.backgroundGray)
        .navigationTitle(child.name)
        .navigationBarTitleDisplayMode(.large)
    }
}
