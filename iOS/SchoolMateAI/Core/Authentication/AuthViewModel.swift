import SwiftUI
import LocalAuthentication

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authService = AuthService.shared

    init() {
        isAuthenticated = authService.isAuthenticated
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await authService.signIn(email: email, password: password)
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signUp(email: String, password: String, fullName: String) async {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await authService.signUp(
                email: email,
                password: password,
                fullName: fullName
            )
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signInWithApple(idToken: String, nonce: String) async {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await authService.signInWithApple(idToken: idToken, nonce: nonce)
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func authenticateWithBiometrics() async -> Bool {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        ) else {
            return false
        }
        do {
            return try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "biometric_reason".localized
            )
        } catch {
            return false
        }
    }

    func signOut() async {
        do {
            try await authService.signOut()
        } catch {
            // Clear local state even if server call fails
        }
        isAuthenticated = false
    }
}
