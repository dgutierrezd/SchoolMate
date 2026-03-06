import SwiftUI

struct SubjectsView: View {
    let childId: String
    @StateObject private var viewModel = SubjectsViewModel()
    @State private var showAddSubject = false

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.subjects.isEmpty {
                VStack(spacing: AppSpacing.md) {
                    Image(systemName: "books.vertical")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.primaryPurple.opacity(0.5))
                    Text("No subjects yet")
                        .font(.appBody)
                        .foregroundStyle(.secondary)
                    Button("Add Subject") {
                        showAddSubject = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.primaryPurple)
                }
            } else {
                List {
                    ForEach(viewModel.subjects) { subject in
                        NavigationLink(destination: SubjectDetailView(subject: subject)) {
                            HStack(spacing: AppSpacing.md) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: subject.color).opacity(0.2))
                                        .frame(width: 40, height: 40)
                                    Text(subject.icon)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(subject.name)
                                        .font(.appBody)
                                        .fontWeight(.medium)
                                    if let teacher = subject.teacherName {
                                        Text(teacher)
                                            .font(.appCaption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                Task { await viewModel.deleteSubject(id: subject.id) }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.backgroundGray)
            }
        }
        .navigationTitle(LocalizedStringKey("subjects"))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddSubject = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddSubject) {
            AddSubjectView(childId: childId, viewModel: viewModel)
        }
        .task {
            await viewModel.loadSubjects(childId: childId)
        }
    }
}

struct AddSubjectView: View {
    let childId: String
    @ObservedObject var viewModel: SubjectsViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var teacherName = ""
    @State private var selectedIcon = "📚"
    @State private var selectedColor = "#6366F1"

    private let icons = ["📚", "🧮", "🔬", "🌍", "🎨", "🎵", "💻", "📐", "🏃", "📝"]
    private let colors = [
        "#6366F1", "#EC4899", "#10B981", "#F59E0B",
        "#3B82F6", "#8B5CF6", "#EF4444", "#14B8A6",
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Subject Name", text: $name)
                    TextField("Teacher Name (optional)", text: $teacherName)
                }

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(icons, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Text(icon)
                                    .font(.title)
                                    .padding(6)
                                    .background(
                                        selectedIcon == icon
                                            ? Color.primaryPurple.opacity(0.2)
                                            : Color.clear
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(colors, id: \.self) { color in
                            Button {
                                selectedColor = color
                            } label: {
                                Circle()
                                    .fill(Color(hex: color))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle().stroke(
                                            selectedColor == color ? Color.primary : Color.clear,
                                            lineWidth: 3
                                        )
                                    )
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.backgroundGray)
            .navigationTitle("Add Subject")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.addSubject(
                                childId: childId,
                                name: name,
                                teacherName: teacherName.isEmpty ? nil : teacherName,
                                color: selectedColor,
                                icon: selectedIcon
                            )
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
        .preferredColorScheme(.light)
    }
}
