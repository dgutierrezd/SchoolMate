import SwiftUI

struct GenerateFlashcardsView: View {
    let childId: String
    @ObservedObject var viewModel: FlashcardsViewModel
    @StateObject private var subjectsVM = SubjectsViewModel()
    @StateObject private var consentManager = AIConsentManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var topic = ""
    @State private var selectedSubjectId: String?
    @State private var cardCount = 10
    @State private var showAIConsent = false

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.lg) {
                // Header
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.primaryPurple)
                    Text(LocalizedStringKey("generate_with_ai"))
                        .font(.appHeadline)
                }
                .padding(.top, AppSpacing.lg)

                // Topic Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Topic")
                        .font(.appBody)
                        .fontWeight(.medium)
                    TextField(
                        "enter_topic".localized,
                        text: $topic,
                        axis: .vertical
                    )
                    .lineLimit(2...4)
                    .padding()
                    .background(Color.backgroundGray)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small))
                }

                // Subject Picker
                if !subjectsVM.subjects.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Subject (optional)")
                            .font(.appBody)
                            .fontWeight(.medium)
                        Picker("Subject", selection: $selectedSubjectId) {
                            Text("General").tag(nil as String?)
                            ForEach(subjectsVM.subjects) { subject in
                                HStack {
                                    Text(subject.icon)
                                    Text(subject.name)
                                }
                                .tag(subject.id as String?)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }

                // Card Count
                VStack(alignment: .leading, spacing: 8) {
                    Text("Number of cards: \(cardCount)")
                        .font(.appBody)
                        .fontWeight(.medium)
                    Stepper("", value: $cardCount, in: 5...20, step: 5)
                        .labelsHidden()
                }

                Spacer()

                // Generate Button
                Button {
                    guard !topic.isEmpty else { return }
                    if consentManager.hasGrantedConsent {
                        Task {
                            await viewModel.generateFlashcards(
                                childId: childId,
                                subjectId: selectedSubjectId,
                                topic: topic,
                                count: cardCount
                            )
                            if viewModel.errorMessage == nil {
                                dismiss()
                            }
                        }
                    } else {
                        showAIConsent = true
                    }
                } label: {
                    HStack {
                        if viewModel.isGenerating {
                            ProgressView().tint(.white)
                            Text(LocalizedStringKey("generating_cards"))
                        } else {
                            Image(systemName: "sparkles")
                            Text(LocalizedStringKey("generate_with_ai"))
                        }
                    }
                    .font(.appButtonLabel)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(topic.isEmpty ? Color.primaryPurple.opacity(0.5) : Color.primaryPurple)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                }
                .disabled(topic.isEmpty || viewModel.isGenerating)

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.appCaption)
                        .foregroundStyle(Color.accentRed)
                }
            }
            .padding(AppSpacing.lg)
            .background(Color.backgroundGray)
            .navigationTitle("Generate Flashcards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showAIConsent) {
                AIDataConsentView { granted in
                    showAIConsent = false
                    // Immediately generate after the user grants consent
                    if granted {
                        Task {
                            await viewModel.generateFlashcards(
                                childId: childId,
                                subjectId: selectedSubjectId,
                                topic: topic,
                                count: cardCount
                            )
                            if viewModel.errorMessage == nil {
                                dismiss()
                            }
                        }
                    }
                }
            }
            .task {
                await subjectsVM.loadSubjects(childId: childId)
            }
        }
        .preferredColorScheme(.light)
    }
}
