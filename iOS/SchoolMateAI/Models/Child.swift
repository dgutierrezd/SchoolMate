import Foundation

struct Child: Codable, Identifiable, Hashable {
    let id: String
    let parentId: String
    var name: String
    var grade: String
    var school: String?
    var avatarColor: String
    var avatarEmoji: String
    var aiContext: String?
    let createdAt: Date
    var updatedAt: Date
    var subjects: [Subject]?

    enum CodingKeys: String, CodingKey {
        case id
        case parentId = "parent_id"
        case name, grade, school
        case avatarColor = "avatar_color"
        case avatarEmoji = "avatar_emoji"
        case aiContext = "ai_context"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case subjects
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Child, rhs: Child) -> Bool {
        lhs.id == rhs.id
    }
}

struct CreateChildRequest: Codable {
    let name: String
    let grade: String
    var school: String?
    var avatarColor: String?
    var avatarEmoji: String?

    enum CodingKeys: String, CodingKey {
        case name, grade, school
        case avatarColor = "avatar_color"
        case avatarEmoji = "avatar_emoji"
    }
}
