import Foundation

class AuthService {
    static let shared = AuthService()
    private let api = APIClient.shared

    private init() {}

    func signIn(email: String, password: String) async throws -> AuthResponse {
        let body = ["email": email, "password": password]
        let response: AuthResponse = try await api.request(
            path: "/auth/signin",
            method: "POST",
            body: body
        )
        api.accessToken = response.session.accessToken
        api.refreshToken = response.session.refreshToken
        return response
    }

    func signUp(email: String, password: String, fullName: String) async throws -> AuthResponse {
        let body = ["email": email, "password": password, "fullName": fullName]
        let response: AuthResponse = try await api.request(
            path: "/auth/signup",
            method: "POST",
            body: body
        )
        api.accessToken = response.session.accessToken
        api.refreshToken = response.session.refreshToken
        return response
    }

    func refreshSession() async throws {
        guard let token = api.refreshToken else {
            throw APIError.unauthorized
        }

        let body = ["refreshToken": token]
        let response: AuthResponse = try await api.request(
            path: "/auth/refresh",
            method: "POST",
            body: body
        )
        api.accessToken = response.session.accessToken
        api.refreshToken = response.session.refreshToken
    }

    func signOut() async throws {
        try await api.requestVoid(path: "/auth/signout", method: "DELETE")
        api.clearTokens()
    }

    /// Permanently deletes the authenticated user's account and all associated data.
    /// Clears local tokens regardless of server response so the user is always logged out.
    func deleteAccount() async throws {
        try await api.requestVoid(path: "/auth/account", method: "DELETE")
        api.clearTokens()
    }

    var isAuthenticated: Bool {
        api.accessToken != nil
    }

    func clearSession() {
        api.clearTokens()
    }
}
