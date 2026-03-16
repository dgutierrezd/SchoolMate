import SwiftUI
import AuthenticationServices
import CryptoKit

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var fullName = ""
    @State private var toastData: ToastData?
    @State private var currentNonce: String?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.primaryPurple, Color.deepIndigo],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    // Logo + Tagline
                    VStack(spacing: 12) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 60))
                            .foregroundStyle(.white)

                        Text("SchoolMate AI")
                            .font(.appTitle)
                            .foregroundStyle(.white)

                        Text(LocalizedStringKey("auth_tagline"))
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 60)

                    // Form Card
                    VStack(spacing: 16) {
                        if isSignUp {
                            CustomTextField(
                                title: "full_name".localized,
                                text: $fullName,
                                icon: "person.fill"
                            )
                        }

                        CustomTextField(
                            title: "email".localized,
                            text: $email,
                            icon: "envelope.fill",
                            keyboardType: .emailAddress,
                            autocapitalization: .never
                        )

                        CustomSecureField(
                            title: "password".localized,
                            text: $password,
                            icon: "lock.fill"
                        )

                        // Primary Action Button
                        Button {
                            Task {
                                if isSignUp {
                                    await authViewModel.signUp(
                                        email: email,
                                        password: password,
                                        fullName: fullName
                                    )
                                } else {
                                    await authViewModel.signIn(
                                        email: email,
                                        password: password
                                    )
                                }
                            }
                        } label: {
                            HStack {
                                if authViewModel.isLoading {
                                    ProgressView().tint(Color.primaryPurple)
                                } else {
                                    Text(
                                        isSignUp
                                            ? LocalizedStringKey("create_account")
                                            : LocalizedStringKey("sign_in")
                                    )
                                    .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundStyle(Color.primaryPurple)
                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                        }
                        .disabled(authViewModel.isLoading)

                        // Divider
                        HStack {
                            Rectangle().fill(.white.opacity(0.3)).frame(height: 1)
                            Text(LocalizedStringKey("or"))
                                .foregroundStyle(.white.opacity(0.6))
                                .font(.caption)
                            Rectangle().fill(.white.opacity(0.3)).frame(height: 1)
                        }

                        // Apple Sign In / Sign Up
                        if isSignUp {
                            SignInWithAppleButton(.signUp) { request in
                                let nonce = Self.randomNonceString()
                                currentNonce = nonce
                                request.requestedScopes = [.email, .fullName]
                                request.nonce = Self.sha256(nonce)
                            } onCompletion: { result in
                                handleAppleSignIn(result)
                            }
                            .signInWithAppleButtonStyle(.white)
                            .frame(height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                        } else {
                            SignInWithAppleButton(.signIn) { request in
                                let nonce = Self.randomNonceString()
                                currentNonce = nonce
                                request.requestedScopes = [.email, .fullName]
                                request.nonce = Self.sha256(nonce)
                            } onCompletion: { result in
                                handleAppleSignIn(result)
                            }
                            .signInWithAppleButtonStyle(.white)
                            .frame(height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                        }
                    }
                    .padding(24)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large))

                    // Toggle sign in / sign up
                    Button {
                        withAnimation(.spring()) { isSignUp.toggle() }
                    } label: {
                        Text(
                            isSignUp
                                ? LocalizedStringKey("already_have_account")
                                : LocalizedStringKey("no_account")
                        )
                        .foregroundStyle(.white.opacity(0.8))
                        .font(.subheadline)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .toast($toastData)
        .onChange(of: authViewModel.errorMessage) {
            if let error = authViewModel.errorMessage {
                withAnimation {
                    toastData = ToastData(message: error, style: .error)
                }
                authViewModel.errorMessage = nil
            }
        }
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
               let identityToken = credential.identityToken,
               let tokenString = String(data: identityToken, encoding: .utf8),
               let nonce = currentNonce {
                Task {
                    await authViewModel.signInWithApple(
                        idToken: tokenString,
                        nonce: nonce,
                        fullName: [credential.fullName?.givenName, credential.fullName?.familyName]
                            .compactMap { $0 }
                            .joined(separator: " ")
                    )
                }
            } else {
                authViewModel.errorMessage = "Apple Sign In failed. Please try again."
            }
        case .failure(let error):
            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                authViewModel.errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Nonce Helpers

    private static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    private static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Custom Text Fields

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.white.opacity(0.7))
                .frame(width: 20)
            TextField(title, text: $text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .foregroundStyle(.white)
        }
        .padding()
        .background(.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
    }
}

struct CustomSecureField: View {
    let title: String
    @Binding var text: String
    let icon: String
    @State private var isSecure = true

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.white.opacity(0.7))
                .frame(width: 20)
            if isSecure {
                SecureField(title, text: $text)
                    .foregroundStyle(.white)
            } else {
                TextField(title, text: $text)
                    .foregroundStyle(.white)
            }
            Button {
                isSecure.toggle()
            } label: {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .padding()
        .background(.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
    }
}
