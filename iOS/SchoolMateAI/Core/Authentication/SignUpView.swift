import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @Environment(\.dismiss) private var dismiss

    private var isFormValid: Bool {
        !fullName.isEmpty &&
        !email.isEmpty &&
        password.count >= 8 &&
        password == confirmPassword
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.primaryPurple, Color.deepIndigo],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 50))
                                .foregroundStyle(.white)
                            Text(LocalizedStringKey("create_account"))
                                .font(.appTitle)
                                .foregroundStyle(.white)
                        }
                        .padding(.top, 40)

                        VStack(spacing: 16) {
                            CustomTextField(
                                title: "full_name".localized,
                                text: $fullName,
                                icon: "person.fill"
                            )

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

                            CustomSecureField(
                                title: "Confirm Password",
                                text: $confirmPassword,
                                icon: "lock.rotation"
                            )

                            if password != confirmPassword && !confirmPassword.isEmpty {
                                Text("Passwords don't match")
                                    .font(.caption)
                                    .foregroundStyle(Color.accentRed)
                            }

                            Button {
                                Task {
                                    await authViewModel.signUp(
                                        email: email,
                                        password: password,
                                        fullName: fullName
                                    )
                                }
                            } label: {
                                HStack {
                                    if authViewModel.isLoading {
                                        ProgressView().tint(Color.primaryPurple)
                                    } else {
                                        Text(LocalizedStringKey("create_account"))
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isFormValid ? Color.white : Color.white.opacity(0.5))
                                .foregroundStyle(Color.primaryPurple)
                                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                            }
                            .disabled(!isFormValid || authViewModel.isLoading)
                        }
                        .padding(24)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large))
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }
}
