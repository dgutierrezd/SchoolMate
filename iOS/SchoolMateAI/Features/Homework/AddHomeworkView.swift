import SwiftUI

struct AddHomeworkView: View {
    let childId: String
    @StateObject private var viewModel = HomeworkViewModel()
    @StateObject private var subjectsVM = SubjectsViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var dueDate = Date().addingTimeInterval(86400)
    @State private var priority: HomeworkPriority = .medium
    @State private var selectedSubjectId: String?
    @State private var addToCalendar = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    // Title & Description
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Details")
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 4)

                        VStack(spacing: 0) {
                            TextField("Title", text: $title)
                                .padding(AppSpacing.md)

                            Divider()
                                .background(Color.black.opacity(0.05))

                            TextField("Description (optional)", text: $description, axis: .vertical)
                                .lineLimit(3...6)
                                .padding(AppSpacing.md)
                        }
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                    }

                    // Due Date & Priority
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Schedule")
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 4)

                        VStack(spacing: 0) {
                            DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                .padding(AppSpacing.md)

                            Divider()
                                .background(Color.black.opacity(0.05))

                            HStack {
                                Text("Priority")
                                Spacer()
                                Picker("Priority", selection: $priority) {
                                    ForEach(HomeworkPriority.allCases, id: \.self) { p in
                                        HStack {
                                            Circle()
                                                .fill(priorityColor(p))
                                                .frame(width: 8, height: 8)
                                            Text(p.rawValue.capitalized)
                                        }
                                        .tag(p)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(Color.primaryPurple)
                            }
                            .padding(AppSpacing.md)
                        }
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                    }

                    // Subject picker
                    if !subjectsVM.subjects.isEmpty {
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("subjects".localized)
                                .font(.appCaption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 4)

                            HStack {
                                Text("Subject")
                                Spacer()
                                Picker("Subject", selection: $selectedSubjectId) {
                                    Text("None").tag(nil as String?)
                                    ForEach(subjectsVM.subjects) { subject in
                                        HStack {
                                            Text(subject.icon)
                                            Text(subject.name)
                                        }
                                        .tag(subject.id as String?)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(Color.primaryPurple)
                            }
                            .padding(AppSpacing.md)
                            .background(Color.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                        }
                    }

                    // Calendar toggle
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Reminders")
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 4)

                        Toggle(isOn: $addToCalendar) {
                            HStack(spacing: 10) {
                                Image(systemName: "calendar.badge.plus")
                                    .foregroundStyle(Color.primaryPurple)
                                Text("Add to Calendar")
                            }
                        }
                        .tint(Color.primaryPurple)
                        .padding(AppSpacing.md)
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                    }
                }
                .padding(AppSpacing.md)
            }
            .background(Color.backgroundGray.ignoresSafeArea())
            .navigationTitle(LocalizedStringKey("add_homework"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            let request = CreateHomeworkRequest(
                                childId: childId,
                                subjectId: selectedSubjectId,
                                title: title,
                                description: description.isEmpty ? nil : description,
                                dueDate: dueDate,
                                priority: priority.rawValue
                            )
                            await viewModel.createHomework(request)

                            if addToCalendar {
                                await CalendarService.shared.addHomeworkToCalendar(
                                    title: title,
                                    description: description.isEmpty ? nil : description,
                                    dueDate: dueDate,
                                    priority: priority.rawValue
                                )
                            }

                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty)
                }
            }
            .task {
                await subjectsVM.loadSubjects(childId: childId)
            }
        }
    }

    private func priorityColor(_ priority: HomeworkPriority) -> Color {
        switch priority {
        case .low: return Color.accentGreen
        case .medium: return Color.accentOrange
        case .high: return Color.accentRed
        }
    }
}
