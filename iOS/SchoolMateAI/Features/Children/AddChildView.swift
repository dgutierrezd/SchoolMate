import SwiftUI

struct AddChildView: View {
    var onChildAdded: (() -> Void)? = nil
    @StateObject private var viewModel = ChildrenViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var grade = ""
    @State private var school = ""
    @State private var selectedEmoji = "🎒"
    @State private var selectedColor = "#6366F1"
    @State private var toastData: ToastData?

    private let emojis = ["🎒", "📚", "🎓", "⭐️", "🚀", "🎨", "⚽️", "🎵", "🔬", "🌟"]
    private let colors = [
        "#6366F1", "#EC4899", "#10B981", "#F59E0B",
        "#3B82F6", "#8B5CF6", "#EF4444", "#14B8A6",
    ]

    private let grades = [
        "Pre-K", "Kindergarten",
        "1st", "2nd", "3rd", "4th", "5th", "6th",
        "7th", "8th", "9th", "10th", "11th", "12th",
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    // Avatar Preview
                    ZStack {
                        Circle()
                            .fill(Color(hex: selectedColor))
                            .frame(width: 80, height: 80)
                        Text(selectedEmoji)
                            .font(.system(size: 40))
                    }
                    .padding(.top, AppSpacing.md)

                    // Name
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("child_name".localized)
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 4)

                        TextField(
                            "child_name".localized,
                            text: $name
                        )
                        .padding(AppSpacing.md)
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                    }

                    // Grade
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("grade".localized)
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 4)

                        HStack {
                            Text("grade".localized)
                            Spacer()
                            Picker("grade".localized, selection: $grade) {
                                Text("Select").tag("")
                                ForEach(grades, id: \.self) { g in
                                    Text(g).tag(g)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(Color.primaryPurple)
                        }
                        .padding(AppSpacing.md)
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                    }

                    // School
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("school".localized)
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 4)

                        TextField(
                            "school".localized,
                            text: $school
                        )
                        .padding(AppSpacing.md)
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                    }

                    // Avatar Emoji selector
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Avatar")
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 4)

                        VStack(spacing: AppSpacing.md) {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                                ForEach(emojis, id: \.self) { emoji in
                                    Button {
                                        selectedEmoji = emoji
                                    } label: {
                                        Text(emoji)
                                            .font(.title)
                                            .padding(8)
                                            .background(
                                                selectedEmoji == emoji
                                                    ? Color.primaryPurple.opacity(0.3)
                                                    : Color.clear
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            Divider()
                                .background(Color.black.opacity(0.05))

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                                ForEach(colors, id: \.self) { color in
                                    Button {
                                        selectedColor = color
                                    } label: {
                                        Circle()
                                            .fill(Color(hex: color))
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Circle()
                                                    .stroke(
                                                        selectedColor == color
                                                            ? Color.textPrimary
                                                            : Color.clear,
                                                        lineWidth: 3
                                                    )
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(AppSpacing.md)
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                    }
                }
                .padding(AppSpacing.md)
            }
            .background(Color.backgroundGray.ignoresSafeArea())
            .navigationTitle(LocalizedStringKey("add_child"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.addChild(
                                name: name,
                                grade: grade,
                                school: school.isEmpty ? nil : school,
                                avatarColor: selectedColor,
                                avatarEmoji: selectedEmoji
                            )
                            if let error = viewModel.errorMessage {
                                withAnimation {
                                    toastData = ToastData(message: error, style: .error)
                                }
                                viewModel.errorMessage = nil
                            } else {
                                onChildAdded?()
                                dismiss()
                            }
                        }
                    }
                    .disabled(name.isEmpty || grade.isEmpty || viewModel.isLoading)
                }
            }
            .toast($toastData)
        }
    }
}
