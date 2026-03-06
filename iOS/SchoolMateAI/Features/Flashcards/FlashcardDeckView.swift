import SwiftUI

struct FlashcardDeckView: View {
    var preselectedChild: Child? = nil
    @StateObject private var viewModel = FlashcardsViewModel()
    @StateObject private var childrenVM = ChildrenViewModel()
    @State private var selectedChild: Child?
    @State private var showGenerate = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundGray.ignoresSafeArea()

                VStack(spacing: 0) {
                // Child selector
                if !childrenVM.children.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppSpacing.sm) {
                            ForEach(childrenVM.children) { child in
                                Button {
                                    selectedChild = child
                                    Task { await viewModel.loadDecks(childId: child.id) }
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
                                        selectedChild?.id == child.id ? .white : .primary
                                    )
                                    .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.sm)
                    }
                }

                if viewModel.isLoading && viewModel.decks.isEmpty {
                    DeckListSkeleton()
                    Spacer()
                } else if viewModel.decks.isEmpty {
                    Spacer()
                    VStack(spacing: AppSpacing.md) {
                        Image(systemName: "rectangle.stack")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.primaryPurple.opacity(0.5))
                        Text("No study decks yet")
                            .font(.appBody)
                            .foregroundStyle(.secondary)
                        Button {
                            showGenerate = true
                        } label: {
                            Label(
                                "generate_with_ai".localized,
                                systemImage: "sparkles"
                            )
                            .font(.appButtonLabel)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.primaryPurple)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                        }
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: AppSpacing.md) {
                            ForEach(viewModel.decks) { deck in
                                NavigationLink(destination: FlashcardStudyView(
                                    deck: deck,
                                    viewModel: viewModel
                                )) {
                                    DeckCard(deck: deck)
                                }
                            }
                        }
                        .padding(AppSpacing.md)
                    }
                }
            }
            } // end ZStack
            .navigationTitle(LocalizedStringKey("flashcard_decks"))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showGenerate = true
                    } label: {
                        Image(systemName: "sparkles")
                    }
                }
            }
            .sheet(isPresented: $showGenerate) {
                if let child = selectedChild {
                    GenerateFlashcardsView(
                        childId: child.id,
                        viewModel: viewModel
                    )
                }
            }
            .task {
                if let preselected = preselectedChild {
                    selectedChild = preselected
                    childrenVM.children = [preselected]
                    await viewModel.loadDecks(childId: preselected.id)
                } else {
                    await childrenVM.loadChildren()
                    selectedChild = childrenVM.children.first
                    if let child = selectedChild {
                        await viewModel.loadDecks(childId: child.id)
                    }
                }
            }
        }
    }
}

struct DeckCard: View {
    let deck: FlashcardDeck

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(deck.title)
                        .font(.appHeadline)
                        .foregroundStyle(Color.textPrimary)
                    if let subject = deck.subjects {
                        HStack(spacing: 4) {
                            Text(subject.icon)
                            Text(subject.name)
                                .font(.appCaption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }

            // Progress bar
            VStack(alignment: .leading, spacing: 4) {
                ProgressView(value: deck.progress)
                    .tint(Color.accentGreen)
                Text("\(deck.masteredCards)/\(deck.totalCards) mastered")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            }
        }
        .cardStyle()
    }
}
