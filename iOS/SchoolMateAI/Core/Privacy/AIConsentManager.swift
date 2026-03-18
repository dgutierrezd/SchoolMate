import Foundation
import Combine

/// Manages the user's explicit consent for sharing personal data with the third-party AI service.
/// Consent is persisted in UserDefaults under "aiDataConsentGranted".
class AIConsentManager: ObservableObject {
    static let shared = AIConsentManager()

    private let consentKey = "aiDataConsentGranted"

    @Published private(set) var hasGrantedConsent: Bool

    private init() {
        self.hasGrantedConsent = UserDefaults.standard.bool(forKey: "aiDataConsentGranted")
    }

    /// Call when the user explicitly taps "I Agree" on the consent sheet.
    func grantConsent() {
        UserDefaults.standard.set(true, forKey: consentKey)
        hasGrantedConsent = true
    }

    /// Call when the user revokes consent (e.g., from Settings).
    func revokeConsent() {
        UserDefaults.standard.set(false, forKey: consentKey)
        hasGrantedConsent = false
    }
}
