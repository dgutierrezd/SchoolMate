import Foundation

class ProfileService {
    static let shared = ProfileService()
    private let api = APIClient.shared

    private init() {}

    func fetchProfile() async throws -> User {
        try await api.request(path: "/profile")
    }

    func updateProfile(fullName: String?, language: String?) async throws -> User {
        struct UpdateRequest: Codable {
            let full_name: String?
            let language: String?
        }
        return try await api.request(
            path: "/profile",
            method: "PUT",
            body: UpdateRequest(full_name: fullName, language: language)
        )
    }
}
