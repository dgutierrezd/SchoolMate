import SwiftUI

/// Presented the first time a user attempts to use any AI feature.
/// Satisfies App Store Review Guideline 5.1.1 by fully disclosing what data is
/// sent, identifying the third-party AI service, and obtaining explicit permission.
struct AIDataConsentView: View {
    /// Called with `true` when the user agrees, `false` when they decline.
    var onDecision: (Bool) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {

                    // MARK: - Header
                    VStack(spacing: AppSpacing.sm) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 52))
                            .foregroundStyle(Color.primaryPurple)
                        Text("ai_consent_title".localized)
                            .font(.appTitle)
                            .multilineTextAlignment(.center)
                        Text("ai_consent_subtitle".localized)
                            .font(.appBody)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, AppSpacing.lg)

                    Divider()

                    // MARK: - What data is shared
                    ConsentSection(
                        icon: "doc.text.magnifyingglass",
                        title: "ai_consent_data_title".localized,
                        body: "ai_consent_data_body".localized
                    )

                    // MARK: - Who receives the data
                    ConsentSection(
                        icon: "server.rack",
                        title: "ai_consent_recipient_title".localized,
                        body: "ai_consent_recipient_body".localized
                    )

                    // MARK: - How the data is used
                    ConsentSection(
                        icon: "sparkles",
                        title: "ai_consent_use_title".localized,
                        body: "ai_consent_use_body".localized
                    )

                    // MARK: - Data not used for training
                    ConsentSection(
                        icon: "lock.shield.fill",
                        title: "ai_consent_protection_title".localized,
                        body: "ai_consent_protection_body".localized
                    )

                    // MARK: - Privacy Policy link
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                                .foregroundStyle(Color.primaryPurple)
                            Text("ai_consent_privacy_link".localized)
                                .font(.appBody)
                                .foregroundStyle(Color.primaryPurple)
                                .underline()
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.appCaption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(AppSpacing.md)
                        .background(Color.softLavender)
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small))
                    }

                    Spacer(minLength: AppSpacing.lg)

                    // MARK: - Action Buttons
                    VStack(spacing: AppSpacing.sm) {
                        Button {
                            AIConsentManager.shared.grantConsent()
                            onDecision(true)
                        } label: {
                            Text("ai_consent_agree".localized)
                                .font(.appButtonLabel)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.primaryPurple)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                        }

                        Button {
                            onDecision(false)
                        } label: {
                            Text("ai_consent_decline".localized)
                                .font(.appButtonLabel)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.backgroundGray)
                                .foregroundStyle(.primary)
                                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                        }

                        Text("ai_consent_revoke_note".localized)
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(AppSpacing.lg)
            }
            .background(Color.backgroundGray)
            .navigationTitle("ai_consent_nav_title".localized)
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.light)
        .interactiveDismissDisabled()
    }
}

// MARK: - Helper subview

private struct ConsentSection: View {
    let icon: String
    let title: String
    let body: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: icon)
                    .foregroundStyle(Color.primaryPurple)
                    .frame(width: 24)
                Text(title)
                    .font(.appHeadline)
                    .foregroundStyle(Color.textPrimary)
            }
            Text(body)
                .font(.appBody)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 24 + AppSpacing.sm)
        }
        .padding(AppSpacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small))
    }
}
