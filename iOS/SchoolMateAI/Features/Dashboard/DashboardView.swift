import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showAddHomework = false
    @State private var showAddChild = false
    @State private var toastData: ToastData?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundGray.ignoresSafeArea()

                if viewModel.isLoading && viewModel.children.isEmpty {
                    ScrollView {
                        DashboardSkeleton()
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: AppSpacing.lg) {
                            // Greeting
                            Text("\(viewModel.greeting)!")
                                .font(.appTitle)
                                .foregroundStyle(Color.textPrimary)

                            // Children Switcher
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: AppSpacing.md) {
                                    ForEach(viewModel.children) { child in
                                        ChildAvatarButton(
                                            child: child,
                                            isSelected: viewModel.selectedChild?.id == child.id
                                        ) {
                                            Task {
                                                await viewModel.selectChild(child)
                                            }
                                        }
                                    }

                                    Button {
                                        showAddChild = true
                                    } label: {
                                        VStack(spacing: 4) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.backgroundGray)
                                                    .frame(width: 56, height: 56)
                                                Image(systemName: "plus")
                                                    .font(.title2)
                                                    .foregroundStyle(Color.primaryPurple)
                                            }
                                            Text(LocalizedStringKey("add_child"))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }

                            // Quick Actions
                            HStack(spacing: AppSpacing.md) {
                                QuickActionButton(
                                    title: "add_homework".localized,
                                    icon: "plus.circle.fill",
                                    color: Color.primaryPurple
                                ) {
                                    if viewModel.selectedChild != nil {
                                        showAddHomework = true
                                    } else {
                                        withAnimation {
                                            toastData = ToastData(
                                                message: "Add a child first to create homework",
                                                style: .warning
                                            )
                                        }
                                    }
                                }

                                NavigationLink {
                                    if let child = viewModel.selectedChild {
                                        FlashcardDeckView(preselectedChild: child)
                                    } else {
                                        Text("Please add a child first")
                                            .foregroundStyle(.secondary)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .background(Color.backgroundGray)
                                    }
                                } label: {
                                    QuickActionCard(
                                        title: "start_study".localized,
                                        icon: "book.fill",
                                        color: Color.accentGreen
                                    )
                                }

                                NavigationLink {
                                    AIChatView(preselectedChild: viewModel.selectedChild)
                                } label: {
                                    QuickActionCard(
                                        title: "ask_ai".localized,
                                        icon: "brain",
                                        color: Color.accentOrange
                                    )
                                }
                            }

                            // Overdue Section
                            if !viewModel.overdueHomework.isEmpty {
                                SectionHeader(
                                    title: "overdue".localized,
                                    color: Color.accentRed
                                )
                                ForEach(viewModel.overdueHomework) { homework in
                                    HomeworkCard(homework: homework, urgency: .overdue)
                                }
                            }

                            // Today's Homework
                            SectionHeader(
                                title: "todays_homework".localized,
                                color: Color.accentOrange
                            )
                            if viewModel.todayHomework.isEmpty {
                                Text(LocalizedStringKey("no_homework_today"))
                                    .font(.appBody)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, AppSpacing.lg)
                            } else {
                                ForEach(viewModel.todayHomework) { homework in
                                    HomeworkCard(homework: homework, urgency: .dueToday)
                                }
                            }

                            // Upcoming
                            if !viewModel.upcomingHomework.isEmpty {
                                SectionHeader(
                                    title: "upcoming".localized,
                                    color: Color.accentGreen
                                )
                                ForEach(viewModel.upcomingHomework) { homework in
                                    HomeworkCard(homework: homework, urgency: .upcoming)
                                }
                            }
                        }
                        .padding(AppSpacing.md)
                    }
                }
            }
            .navigationTitle("SchoolMate AI")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await viewModel.loadData()
            }
            .task {
                await viewModel.loadData()
            }
            .sheet(isPresented: $showAddHomework) {
                if let child = viewModel.selectedChild {
                    AddHomeworkView(childId: child.id)
                }
            }
            .sheet(isPresented: $showAddChild) {
                AddChildView {
                    Task { await viewModel.loadData() }
                }
            }
            .toast($toastData)
        }
    }
}

// MARK: - Supporting Views

struct ChildAvatarButton: View {
    let child: Child
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(Color(hex: child.avatarColor).opacity(isSelected ? 1 : 0.3))
                        .frame(width: 56, height: 56)
                    Text(child.avatarEmoji)
                        .font(.title)
                }
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.primaryPurple : .clear, lineWidth: 3)
                )
                Text(child.name)
                    .font(.caption)
                    .foregroundStyle(isSelected ? Color.primaryPurple : .secondary)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            QuickActionCard(title: title, icon: icon, color: color)
        }
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.md)
        .cardStyle()
    }
}

enum HomeworkUrgency {
    case overdue, dueToday, upcoming

    var color: Color {
        switch self {
        case .overdue: return Color.accentRed
        case .dueToday: return Color.accentOrange
        case .upcoming: return Color.accentGreen
        }
    }
}

struct HomeworkCard: View {
    let homework: Homework
    let urgency: HomeworkUrgency

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            RoundedRectangle(cornerRadius: 4)
                .fill(urgency.color)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 4) {
                Text(homework.title)
                    .font(.appBody)
                    .fontWeight(.medium)
                if let subject = homework.subjects {
                    HStack(spacing: 4) {
                        Text(subject.icon)
                            .font(.caption)
                        Text(subject.name)
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                    }
                }
                Text(homework.dueDate, style: .date)
                    .font(.appCaption)
                    .foregroundStyle(urgency.color)
            }

            Spacer()

            if homework.priority == .high {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(Color.accentRed)
                    .font(.caption)
            }
        }
        .cardStyle()
    }
}

struct SectionHeader: View {
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(title)
                .font(.appHeadline)
                .foregroundStyle(Color.textPrimary)
        }
    }
}
