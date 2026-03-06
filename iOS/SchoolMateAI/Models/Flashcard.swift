import Foundation

struct FlashcardDeck: Codable, Identifiable {
    let id: String
    let childId: String
    var subjectId: String?
    var title: String
    var description: String?
    var totalCards: Int
    var masteredCards: Int
    let createdAt: Date
    var subjects: SubjectRef?

    enum CodingKeys: String, CodingKey {
        case id
        case childId = "child_id"
        case subjectId = "subject_id"
        case title, description
        case totalCards = "total_cards"
        case masteredCards = "mastered_cards"
        case createdAt = "created_at"
        case subjects
    }

    var progress: Double {
        guard totalCards > 0 else { return 0 }
        return Double(masteredCards) / Double(totalCards)
    }
}

struct Flashcard: Codable, Identifiable {
    let id: String
    let deckId: String
    var front: String
    var back: String
    var hint: String?
    var difficulty: FlashcardDifficulty
    var lastReviewed: Date?
    var mastered: Bool
    var reviewCount: Int
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case deckId = "deck_id"
        case front, back, hint, difficulty
        case lastReviewed = "last_reviewed"
        case mastered
        case reviewCount = "review_count"
        case createdAt = "created_at"
    }
}

enum FlashcardDifficulty: String, Codable, CaseIterable {
    case easy
    case medium
    case hard

    var label: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
}

struct GenerateFlashcardsRequest: Codable {
    let childId: String
    var subjectId: String?
    let topic: String
    var count: Int?

    enum CodingKeys: String, CodingKey {
        case childId = "child_id"
        case subjectId = "subject_id"
        case topic, count
    }
}

struct GenerateFlashcardsResponse: Codable {
    let deck: FlashcardDeck
    let cards: [Flashcard]
}
