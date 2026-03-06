import Foundation

struct ChatMessage: Codable, Identifiable {
    let id: String
    let childId: String
    let parentId: String
    let role: MessageRole
    let content: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case childId = "child_id"
        case parentId = "parent_id"
        case role, content
        case createdAt = "created_at"
    }
}

enum MessageRole: String, Codable {
    case user
    case assistant
}

struct SendMessageRequest: Codable {
    let childId: String
    let message: String
    let language: String?
}

struct ChatStreamDelta: Codable {
    let delta: String?
    let done: Bool?
}
