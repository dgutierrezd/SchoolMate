import SwiftUI

struct ProfileView: View {
    @State private var profile: User?
    @State private var fullName = ""
    @State private var isLoading = true
    @State private var isSaving = false
    @State private var toastData: ToastData?
    @Environment(\.dismiss) private var dismiss

    private let profileService = ProfileService.shared

    var body: some View {
        ZStack {
            Color.backgroundGray.ignoresSafeArea()

            if isLoading {
                ProgressView()
            } else {
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Avatar
                        VStack(spacing: AppSpacing.md) {
                            ZStack {
                                Circle()
                                    .fill(Color.primaryPurple.opacity(0.2))
                                    .frame(width: 100, height: 100)
                                Image(systemName: "person.fill")
                                    .font(.system(size: 44))
                                    .foregroundStyle(Color.primaryPurple)
                            }
                        }
                        .padding(.top, AppSpacing.lg)

                        // Form
                        VStack(spacing: AppSpacing.md) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("full_name".localized)
                                    .font(.appCaption)
                                    .foregroundStyle(.secondary)
                                TextField("full_name".localized, text: $fullName)
                                    .font(.appBody)
                                    .padding(12)
                                    .background(Color.cardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppCornerRadius.small)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("email".localized)
                                    .font(.appCaption)
                                    .foregroundStyle(.secondary)
                                Text(profile?.email ?? "-")
                                    .font(.appBody)
                                    .foregroundStyle(.secondary)
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.cardBackground.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small))
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("member_since".localized)
                                    .font(.appCaption)
                                    .foregroundStyle(.secondary)
                                if let createdAt = profile?.createdAt {
                                    Text(createdAt, style: .date)
                                        .font(.appBody)
                                        .foregroundStyle(.secondary)
                                        .padding(12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.cardBackground.opacity(0.5))
                                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small))
                                }
                            }
                        }
                        .padding(AppSpacing.md)

                        // Save Button
                        Button {
                            Task { await saveProfile() }
                        } label: {
                            HStack {
                                if isSaving {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("save".localized)
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                fullName.isEmpty || fullName == profile?.fullName
                                    ? Color.primaryPurple.opacity(0.5)
                                    : Color.primaryPurple
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                        }
                        .disabled(fullName.isEmpty || fullName == profile?.fullName || isSaving)
                        .padding(.horizontal, AppSpacing.md)
                    }
                }
            }
        }
        .navigationTitle("profile".localized)
        .navigationBarTitleDisplayMode(.large)
        .toast($toastData)
        .task {
            await loadProfile()
        }
    }

    private func loadProfile() async {
        isLoading = true
        do {
            let p = try await profileService.fetchProfile()
            profile = p
            fullName = p.fullName
        } catch {
            toastData = ToastData(message: error.localizedDescription, style: .error)
        }
        isLoading = false
    }

    private func saveProfile() async {
        isSaving = true
        do {
            let updated = try await profileService.updateProfile(
                fullName: fullName,
                language: nil
            )
            profile = updated
            toastData = ToastData(message: "profile_updated".localized, style: .success)
        } catch {
            toastData = ToastData(message: error.localizedDescription, style: .error)
        }
        isSaving = false
    }
}
