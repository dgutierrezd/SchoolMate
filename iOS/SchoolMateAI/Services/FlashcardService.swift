import Foundation

class FlashcardService {
    static let shared = FlashcardService()
    private let api = APIClient.shared

    private init() {}

    func fetchDecks(childId: String) async throws -> [FlashcardDeck] {
        try await api.request(
            path: "/flashcards/decks",
            queryItems: [URLQueryItem(name: "childId", value: childId)]
        )
    }

    func fetchCards(deckId: String) async throws -> [Flashcard] {
        try await api.request(path: "/flashcards/decks/\(deckId)/cards")
    }

    func generateFlashcards(request: GenerateFlashcardsRequest) async throws -> GenerateFlashcardsResponse {
        try await api.request(
            path: "/flashcards/generate",
            method: "POST",
            body: request
        )
    }

    func createDeck(childId: String, subjectId: String?, title: String, description: String?) async throws -> FlashcardDeck {
        struct CreateDeckRequest: Codable {
            let childId: String
            let subjectId: String?
            let title: String
            let description: String?
            enum CodingKeys: String, CodingKey {
                case childId = "child_id"
                case subjectId = "subject_id"
                case title, description
            }
        }

        return try await api.request(
            path: "/flashcards/decks",
            method: "POST",
            body: CreateDeckRequest(
                childId: childId,
                subjectId: subjectId,
                title: title,
                description: description
            )
        )
    }

    func addCard(deckId: String, front: String, back: String, hint: String?, difficulty: String) async throws -> Flashcard {
        struct AddCardRequest: Codable {
            let front: String
            let back: String
            let hint: String?
            let difficulty: String
        }

        return try await api.request(
            path: "/flashcards/decks/\(deckId)/cards",
            method: "POST",
            body: AddCardRequest(front: front, back: back, hint: hint, difficulty: difficulty)
        )
    }

    func markMastered(cardId: String) async throws -> Flashcard {
        try await api.request(
            path: "/flashcards/\(cardId)/master",
            method: "PATCH"
        )
    }
}
