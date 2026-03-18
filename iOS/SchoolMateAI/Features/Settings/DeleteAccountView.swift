import SwiftUI

struct DeleteAccountView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showConfirmationAlert = false
    @State private var showErrorToast = false
    @State private var toastData: ToastData?

    private let consequences: [(icon: String, color: Color, text: String)] = [
        ("person.fill",          Color.accentRed,    "delete_consequence_profile"),
        ("person.2.fill",        Color.accentRed,    "delete_consequence_children"),
        ("checklist",            Color.accentRed,    "delete_consequence_homework"),
        ("rectangle.stack.fill", Color.accentRed,    "delete_consequence_flashcards"),
        ("bubble.left.fill",     Color.accentRed,    "delete_consequence_chats"),
    ]

    var body: some View {
        ZStack {
            Color.backgroundGray.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing.lg) {

                    // Warning icon
                    warningHeader

                    // What gets deleted
                    consequencesCard

                    // Permanence notice
                    permanenceNotice

                    Spacer(minLength: AppSpacing.xl)

                    // Delete button
                    deleteButton

                    // Cancel
                    Button("delete_account_cancel".localized) {
                        dismiss()
                    }
                    .font(.appBody)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, AppSpacing.lg)
                }
                .padding(AppSpacing.md)
            }
        }
        .navigationTitle("delete_account_title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toast($toastData)
        .alert("delete_account_confirm_title".localized, isPresented: $showConfirmationAlert) {
            Button("delete_account_confirm_action".localized, role: .destructive) {
                Task { await performDeletion() }
            }
            Button("delete_account_cancel".localized, role: .cancel) {}
        } message: {
            Text("delete_account_confirm_message".localized)
        }
        .disabled(authViewModel.isDeletingAccount)
    }

    // MARK: - Sub-views

    private var warningHeader: some View {
        VStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(Color.accentRed.opacity(0.12))
                    .frame(width: 88, height: 88)
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.accentRed)
            }
            .padding(.top, AppSpacing.lg)

            Text("delete_account_title".localized)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color.textPrimary)

            Text("delete_account_subtitle".localized)
                .font(.appBody)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.md)
        }
    }

    private var consequencesCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("delete_account_what_deleted".localized)
                .font(.appCaption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, AppSpacing.md)
                .padding(.bottom, AppSpacing.sm)

            VStack(spacing: 0) {
                ForEach(Array(consequences.enumerated()), id: \.offset) { index, item in
                    HStack(spacing: AppSpacing.md) {
                        Image(systemName: item.icon)
                            .font(.body)
                            .foregroundStyle(item.color)
                            .frame(width: 24)

                        Text(item.text.localized)
                            .font(.appBody)
                            .foregroundStyle(Color.textPrimary)

                        Spacer()
                    }
                    .padding(AppSpacing.md)

                    if index < consequences.count - 1 {
                        Divider()
                            .padding(.leading, 56)
                    }
                }
            }
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        }
    }

    private var permanenceNotice: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(Color.accentOrange)
                .padding(.top, 2)

            Text("delete_account_permanent_notice".localized)
                .font(.appCaption)
                .foregroundStyle(Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppSpacing.md)
        .background(Color.accentOrange.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small))
    }

    private var deleteButton: some View {
        Button {
            showConfirmationAlert = true
        } label: {
            HStack(spacing: AppSpacing.sm) {
                if authViewModel.isDeletingAccount {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.85)
                } else {
                    Image(systemName: "trash.fill")
                }
                Text(
                    authViewModel.isDeletingAccount
                        ? "delete_account_deleting".localized
                        : "delete_account_action".localized
                )
                .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentRed)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
        }
        .disabled(authViewModel.isDeletingAccount)
    }

    // MARK: - Actions

    private func performDeletion() async {
        let success = await authViewModel.deleteAccount()
        if !success {
            toastData = ToastData(
                message: authViewModel.errorMessage ?? "delete_account_error".localized,
                style: .error
            )
        }
        // On success, authViewModel.isAuthenticated becomes false and
        // RootView automatically navigates to the login screen.
    }
}
