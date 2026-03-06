import SwiftUI

struct HomeworkListView: View {
    @StateObject private var viewModel = HomeworkViewModel()
    @StateObject private var childrenVM = ChildrenViewModel()
    @State private var selectedChild: Child?
    @State private var showAddHomework = false
    @State private var showCalendarView = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Child selector
                if !childrenVM.children.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppSpacing.sm) {
                            ForEach(childrenVM.children) { child in
                                Button {
                                    selectedChild = child
                                    Task { await viewModel.loadHomework(childId: child.id) }
                                } label: {
                                    HStack(spacing: 6) {
                                        Text(child.avatarEmoji)
                                        Text(child.name)
                                            .font(.appCaption)
                                            .fontWeight(.medium)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedChild?.id == child.id
                                            ? Color.primaryPurple
                                            : Color.backgroundGray
                                    )
                                    .foregroundStyle(
                                        selectedChild?.id == child.id
                                            ? .white
                                            : .primary
                                    )
                                    .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.sm)
                    }
                }

                // Filter bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.sm) {
                        FilterChip(
                            title: "All",
                            isSelected: viewModel.selectedFilter == nil
                        ) {
                            viewModel.selectedFilter = nil
                        }
                        ForEach(HomeworkStatus.allCases, id: \.self) { status in
                            FilterChip(
                                title: status.rawValue.capitalized,
                                isSelected: viewModel.selectedFilter == status
                            ) {
                                viewModel.selectedFilter = status
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.xs)
                }

                // Homework list
                if viewModel.isLoading && viewModel.homework.isEmpty {
                    HomeworkListSkeleton()
                    Spacer()
                } else if viewModel.filteredHomework.isEmpty {
                    Spacer()
                    VStack(spacing: AppSpacing.md) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.accentGreen)
                        Text(LocalizedStringKey("no_homework_today"))
                            .font(.appBody)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.filteredHomework) { homework in
                            NavigationLink(destination: HomeworkDetailView(homework: homework, viewModel: viewModel)) {
                                HomeworkRowView(homework: homework)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    Task { await viewModel.deleteHomework(id: homework.id) }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                if homework.status != .completed {
                                    Button {
                                        Task { await viewModel.markComplete(id: homework.id) }
                                    } label: {
                                        Label("Complete", systemImage: "checkmark.circle")
                                    }
                                    .tint(Color.accentGreen)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Color.backgroundGray)
            .navigationTitle("Homework")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddHomework = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddHomework, onDismiss: {
                if let child = selectedChild {
                    Task { await viewModel.loadHomework(childId: child.id) }
                }
            }) {
                if let child = selectedChild {
                    AddHomeworkView(childId: child.id)
                }
            }
            .task {
                await childrenVM.loadChildren()
                if selectedChild == nil {
                    selectedChild = childrenVM.children.first
                }
                if let child = selectedChild {
                    await viewModel.loadHomework(childId: child.id)
                }
            }
        }
    }
}

struct HomeworkRowView: View {
    let homework: Homework

    private var urgencyColor: Color {
        if homework.isOverdue { return Color.accentRed }
        if homework.isDueToday { return Color.accentOrange }
        return Color.accentGreen
    }

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            RoundedRectangle(cornerRadius: 4)
                .fill(urgencyColor)
                .frame(width: 4, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(homework.title)
                    .font(.appBody)
                    .fontWeight(.medium)
                    .strikethrough(homework.status == .completed)

                HStack(spacing: 8) {
                    if let subject = homework.subjects {
                        Text("\(subject.icon) \(subject.name)")
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                    }
                    Text(homework.dueDate, style: .date)
                        .font(.appCaption)
                        .foregroundStyle(urgencyColor)
                }
            }

            Spacer()

            if homework.priority == .high {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(Color.accentRed)
                    .font(.caption)
            }

            if homework.status == .completed {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.accentGreen)
            }
        }
        .padding(.vertical, 4)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.appCaption)
                .fontWeight(.medium)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isSelected ? Color.primaryPurple : Color.backgroundGray)
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}
