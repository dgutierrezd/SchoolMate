import Foundation

struct User: Codable, Identifiable {
    let id: String
    var fullName: String
    var email: String?
    var avatarURL: String?
    var language: String
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case email
        case avatarURL = "avatar_url"
        case language
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct AuthSession: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let user: AuthUser

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case user
    }
}

struct AuthUser: Codable {
    let id: String
    let email: String?
}

struct AuthResponse: Codable {
    let user: AuthUser
    let session: AuthSession
}
