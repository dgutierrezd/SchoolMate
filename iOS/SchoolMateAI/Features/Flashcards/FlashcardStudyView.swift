import SwiftUI

struct FlashcardStudyView: View {
    let deck: FlashcardDeck
    @ObservedObject var viewModel: FlashcardsViewModel
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var showHint = false

    private var currentCard: Flashcard? {
        guard currentIndex < viewModel.currentCards.count else { return nil }
        return viewModel.currentCards[currentIndex]
    }

    private var progress: Double {
        guard !viewModel.currentCards.isEmpty else { return 0 }
        return Double(currentIndex + 1) / Double(viewModel.currentCards.count)
    }

    private var masteredCount: Int {
        viewModel.currentCards.filter { $0.mastered }.count
    }

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            if viewModel.isLoading && viewModel.currentCards.isEmpty {
                Spacer()
                ProgressView()
                Spacer()
            } else {
            // Progress
            VStack(spacing: 4) {
                ProgressView(value: progress)
                    .tint(Color.primaryPurple)
                HStack {
                    Text("\(min(currentIndex + 1, viewModel.currentCards.count)) / \(viewModel.currentCards.count)")
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(masteredCount) mastered")
                        .font(.appCaption)
                        .foregroundStyle(Color.accentGreen)
                }
            }
            .padding(.horizontal)

            Spacer()

            // Flashcard
            if let card = currentCard {
                FlashcardView(
                    card: card,
                    isFlipped: $isFlipped,
                    showHint: $showHint
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        isFlipped.toggle()
                    }
                }
            } else {
                // Completed all cards
                VStack(spacing: AppSpacing.md) {
                    Image(systemName: "party.popper.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(Color.accentGreen)
                    Text("Deck Complete!")
                        .font(.appTitle)
                        .foregroundStyle(Color.textPrimary)
                    Text("\(masteredCount)/\(viewModel.currentCards.count) cards mastered")
                        .font(.appBody)
                        .foregroundStyle(.secondary)

                    Button {
                        withAnimation {
                            currentIndex = 0
                            isFlipped = false
                            showHint = false
                        }
                    } label: {
                        Label("Study Again", systemImage: "arrow.counterclockwise")
                            .font(.appButtonLabel)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.primaryPurple)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer()

            // Controls
            if currentCard != nil {
                HStack(spacing: AppSpacing.xl) {
                    // Previous
                    Button {
                        goToPrevious()
                    } label: {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(Color.primaryPurple.opacity(currentIndex > 0 ? 1 : 0.3))
                    }
                    .disabled(currentIndex == 0)

                    // Mark mastered
                    Button {
                        Task {
                            if let card = currentCard {
                                await viewModel.markMastered(cardId: card.id)
                                goToNext()
                            }
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(Color.accentGreen)
                            Text("Got it!")
                                .font(.appCaption)
                                .foregroundStyle(Color.accentGreen)
                        }
                    }

                    // Next
                    Button {
                        goToNext()
                    } label: {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(Color.primaryPurple)
                    }
                }
                .padding(.bottom, AppSpacing.lg)
            }
            } // end loading else
        }
        .padding(AppSpacing.md)
        .background(Color.backgroundGray)
        .navigationTitle(deck.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadCards(deckId: deck.id)
        }
    }

    private func goToNext() {
        withAnimation {
            isFlipped = false
            showHint = false
            if currentIndex < viewModel.currentCards.count - 1 {
                currentIndex += 1
            } else {
                currentIndex = viewModel.currentCards.count // Show completion
            }
        }
    }

    private func goToPrevious() {
        withAnimation {
            isFlipped = false
            showHint = false
            if currentIndex > 0 {
                currentIndex -= 1
            }
        }
    }
}

struct FlashcardView: View {
    let card: Flashcard
    @Binding var isFlipped: Bool
    @Binding var showHint: Bool

    var body: some View {
        ZStack {
            // Front
            VStack(spacing: AppSpacing.md) {
                Spacer()
                Text(card.front)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.textPrimary)
                Spacer()

                if let hint = card.hint, showHint {
                    Text(hint)
                        .font(.appBody)
                        .foregroundStyle(Color.accentOrange)
                        .padding()
                        .background(Color.accentOrange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else if card.hint != nil {
                    Button("Show Hint") {
                        withAnimation { showHint = true }
                    }
                    .font(.appCaption)
                    .foregroundStyle(Color.accentOrange)
                }

                DifficultyIndicator(difficulty: card.difficulty)
            }
            .padding(AppSpacing.xl)
            .frame(maxWidth: .infinity, maxHeight: 400)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large))
            .shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 4)
            .opacity(isFlipped ? 0 : 1)
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )

            // Back
            VStack(spacing: AppSpacing.md) {
                Spacer()
                Text(card.back)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.textPrimary)
                Spacer()
            }
            .padding(AppSpacing.xl)
            .frame(maxWidth: .infinity, maxHeight: 400)
            .background(Color.softLavender)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large))
            .shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 4)
            .opacity(isFlipped ? 1 : 0)
            .rotation3DEffect(
                .degrees(isFlipped ? 0 : -180),
                axis: (x: 0, y: 1, z: 0)
            )
        }
    }
}

struct DifficultyIndicator: View {
    let difficulty: FlashcardDifficulty

    private var color: Color {
        switch difficulty {
        case .easy: return Color.accentGreen
        case .medium: return Color.accentOrange
        case .hard: return Color.accentRed
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(i < difficultyLevel ? color : color.opacity(0.2))
                    .frame(width: 8, height: 8)
            }
            Text(difficulty.label)
                .font(.appCaption)
                .foregroundStyle(.secondary)
        }
    }

    private var difficultyLevel: Int {
        switch difficulty {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
        }
    }
}
