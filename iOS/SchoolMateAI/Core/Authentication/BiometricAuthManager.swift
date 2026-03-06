import LocalAuthentication

class BiometricAuthManager {
    enum BiometricType {
        case faceID
        case touchID
        case none
    }

    static var biometricType: BiometricType {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        default:
            return .none
        }
    }

    static var isBiometricAvailable: Bool {
        biometricType != .none
    }

    static var biometricLabel: String {
        switch biometricType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .none: return "Biometric"
        }
    }

    static var biometricIcon: String {
        switch biometricType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .none: return "lock.shield"
        }
    }

    static var isBiometricEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "biometricAuthEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "biometricAuthEnabled") }
    }
}
