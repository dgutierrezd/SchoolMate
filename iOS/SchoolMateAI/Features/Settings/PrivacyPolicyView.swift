import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text("Privacy Policy")
                    .font(.appTitle)
                    .foregroundStyle(Color.textPrimary)

                Text("Last updated: March 18, 2026")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)

                Group {
                    PolicySection(
                        title: "1. Introduction",
                        content: """
                        Welcome to SchoolMate AI ("we," "our," or "us"). We are committed to protecting the privacy \
                        of our users, especially the children whose educational data is managed through our app. This \
                        Privacy Policy explains how we collect, use, disclose, and safeguard your information when you \
                        use our mobile application SchoolMate AI (the "App").

                        By using the App, you agree to the collection and use of information in accordance with this \
                        policy. If you do not agree with the terms of this Privacy Policy, please do not access the App.
                        """
                    )

                    PolicySection(
                        title: "2. Information We Collect",
                        content: """
                        We collect the following types of information:

                        Account Information: When you create an account, we collect your name, email address, and \
                        authentication credentials.

                        Child Information: You may provide your child's name, grade level, school name, and avatar \
                        preferences. This information is used solely to personalize the educational experience.

                        Educational Data: Homework assignments, subjects, flashcard decks, study progress, and AI \
                        chat interactions related to your child's education.

                        Device Information: We may collect device type, operating system version, and unique device \
                        identifiers for app functionality and troubleshooting purposes.

                        Usage Data: We collect information about how you interact with the App, including features \
                        used, session duration, and navigation patterns, to improve the user experience.
                        """
                    )

                    PolicySection(
                        title: "3. How We Use Your Information",
                        content: """
                        We use the information we collect to:

                        \u{2022} Provide, maintain, and improve the App's features and functionality
                        \u{2022} Personalize the educational experience for each child
                        \u{2022} Generate AI-powered study content, summaries, and recommendations
                        \u{2022} Send homework reminders and notifications you have opted into
                        \u{2022} Respond to your comments, questions, and support requests
                        \u{2022} Monitor and analyze usage patterns to improve the App
                        \u{2022} Detect, prevent, and address technical issues or security threats
                        """
                    )
                }

                Group {
                    PolicySection(
                        title: "4. Children's Privacy (COPPA Compliance)",
                        content: """
                        SchoolMate AI is designed for parents and guardians to manage their children's educational \
                        data. We do not knowingly collect personal information directly from children under the age \
                        of 13 without parental consent.

                        All child-related data is entered and managed by the parent or guardian account holder. \
                        Parents have full control over their children's data and can view, modify, or delete it at \
                        any time through the App.

                        If we learn that we have collected personal information from a child under 13 without \
                        verification of parental consent, we will delete that information as quickly as possible. \
                        If you believe we might have any information from or about a child under 13, please contact \
                        us at privacy@schoolmateai.com.
                        """
                    )

                    PolicySection(
                        title: "5. Data Sharing with Third-Party AI Service",
                        content: """
                        We do not sell, trade, or rent your personal information to third parties. We may share \
                        your information only in the following circumstances:

                        Service Providers: We use Supabase for secure data storage and authentication. Supabase \
                        processes data on our behalf under strict confidentiality and data processing agreements.

                        Third-Party AI Processing (requires your explicit consent): To provide AI-powered features \
                        — including the AI Chat assistant and AI-generated flashcards — SchoolMate AI sends certain \
                        data to OpenAI (openai.com) via our secure backend. The data transmitted includes:

                        • Your child's name, grade level, and school name
                        • Homework assignment titles and subjects
                        • Messages you type in the AI Chat
                        • Flashcard topics you enter

                        This data is sent solely to generate educational responses and study materials. OpenAI \
                        does not use this data to train its models when accessed through the API, and we have a \
                        Data Processing Agreement in place with OpenAI consistent with applicable privacy laws. \
                        You will be asked for your explicit permission before any data is sent to OpenAI. You may \
                        withdraw this permission at any time in Settings → AI Data Sharing.

                        Legal Requirements: We may disclose your information if required by law, court order, or \
                        governmental regulation, or if we believe disclosure is necessary to protect our rights, \
                        your safety, or the safety of others.
                        """
                    )

                    PolicySection(
                        title: "6. Data Storage and Security",
                        content: """
                        Your data is stored securely using industry-standard encryption and security measures. We \
                        use Supabase, which provides enterprise-grade security including:

                        \u{2022} Encryption in transit (TLS/SSL) and at rest (AES-256)
                        \u{2022} Row-level security policies to ensure data isolation
                        \u{2022} Regular security audits and compliance monitoring
                        \u{2022} Secure authentication with token-based access control

                        While we implement commercially reasonable security measures, no method of electronic \
                        storage or transmission over the Internet is 100% secure. We cannot guarantee absolute \
                        security of your data.
                        """
                    )

                    PolicySection(
                        title: "7. Data Retention",
                        content: """
                        We retain your personal information for as long as your account is active or as needed to \
                        provide you services. You may request deletion of your account and associated data at any \
                        time by contacting us at privacy@schoolmateai.com.

                        Upon account deletion, we will remove your personal data within 30 days, except where \
                        retention is required by law or for legitimate business purposes such as resolving disputes \
                        or enforcing our agreements.
                        """
                    )
                }

                Group {
                    PolicySection(
                        title: "8. Your Rights",
                        content: """
                        Depending on your location, you may have the following rights regarding your personal data:

                        \u{2022} Access: Request a copy of the personal data we hold about you
                        \u{2022} Correction: Request correction of inaccurate or incomplete data
                        \u{2022} Deletion: Request deletion of your personal data
                        \u{2022} Portability: Request a machine-readable copy of your data
                        \u{2022} Restriction: Request restriction of processing of your data
                        \u{2022} Objection: Object to processing of your data for certain purposes

                        To exercise any of these rights, please contact us at privacy@schoolmateai.com.
                        """
                    )

                    PolicySection(
                        title: "9. Third-Party Services",
                        content: """
                        The App may contain links to third-party websites or services that are not operated by us. \
                        We have no control over and assume no responsibility for the content, privacy policies, or \
                        practices of any third-party sites or services. We encourage you to review the privacy \
                        policies of any third-party services you access.
                        """
                    )

                    PolicySection(
                        title: "10. Changes to This Privacy Policy",
                        content: """
                        We may update our Privacy Policy from time to time. We will notify you of any changes by \
                        posting the new Privacy Policy on this page and updating the "Last updated" date. You are \
                        advised to review this Privacy Policy periodically for any changes.

                        Continued use of the App after any modifications to the Privacy Policy constitutes your \
                        acknowledgment of the modifications and your consent to abide by the updated policy.
                        """
                    )

                    PolicySection(
                        title: "11. Contact Us",
                        content: """
                        If you have any questions or concerns about this Privacy Policy or our data practices, \
                        please contact us at:

                        SchoolMate AI
                        Email: privacy@schoolmateai.com
                        """
                    )
                }
            }
            .padding(AppSpacing.md)
        }
        .background(Color.backgroundGray)
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PolicySection: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(.appHeadline)
                .foregroundStyle(Color.textPrimary)
            Text(content)
                .font(.appBody)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
