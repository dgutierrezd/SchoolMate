import Foundation

@MainActor
class FlashcardsViewModel: ObservableObject {
    @Published var decks: [FlashcardDeck] = []
    @Published var currentCards: [Flashcard] = []
    @Published var isLoading = false
    @Published var isGenerating = false
    @Published var errorMessage: String?

    private let service = FlashcardService.shared

    func loadDecks(childId: String) async {
        isLoading = true
        do {
            decks = try await service.fetchDecks(childId: childId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func loadCards(deckId: String) async {
        isLoading = true
        do {
            currentCards = try await service.fetchCards(deckId: deckId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func generateFlashcards(childId: String, subjectId: String?, topic: String, count: Int = 10) async {
        isGenerating = true
        errorMessage = nil
        do {
            let request = GenerateFlashcardsRequest(
                childId: childId,
                subjectId: subjectId,
                topic: topic,
                count: count
            )
            let response = try await service.generateFlashcards(request: request)
            decks.insert(response.deck, at: 0)
            currentCards = response.cards
        } catch {
            errorMessage = error.localizedDescription
        }
        isGenerating = false
    }

    func markMastered(cardId: String) async {
        do {
            let updated = try await service.markMastered(cardId: cardId)
            if let index = currentCards.firstIndex(where: { $0.id == cardId }) {
                let wasAlreadyMastered = currentCards[index].mastered
                currentCards[index] = updated

                // Update deck's mastered count if this card wasn't already mastered
                if !wasAlreadyMastered, let deckIndex = decks.firstIndex(where: { $0.id == updated.deckId }) {
                    decks[deckIndex].masteredCards = currentCards.filter { $0.mastered }.count
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
