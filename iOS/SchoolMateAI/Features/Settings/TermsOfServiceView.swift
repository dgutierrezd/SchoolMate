import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text("Terms of Service")
                    .font(.appTitle)
                    .foregroundStyle(Color.textPrimary)

                Text("Last updated: March 6, 2026")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)

                Group {
                    PolicySection(
                        title: "1. Acceptance of Terms",
                        content: """
                        By downloading, installing, or using SchoolMate AI (the "App"), you agree to be bound by \
                        these Terms of Service ("Terms"). If you do not agree to these Terms, do not use the App.

                        These Terms constitute a legally binding agreement between you and SchoolMate AI ("we," \
                        "our," or "us"). Please read them carefully before using the App.
                        """
                    )

                    PolicySection(
                        title: "2. Description of Service",
                        content: """
                        SchoolMate AI is an educational management application designed for parents and guardians to:

                        \u{2022} Track and manage their children's homework assignments
                        \u{2022} Organize subjects and academic information
                        \u{2022} Create and study AI-generated flashcard decks
                        \u{2022} Interact with an AI assistant for educational support
                        \u{2022} Receive reminders and notifications about upcoming assignments
                        \u{2022} Sync homework due dates with device calendars

                        The App is intended as a supplementary educational tool and does not replace professional \
                        educational guidance or instruction.
                        """
                    )

                    PolicySection(
                        title: "3. User Accounts",
                        content: """
                        To use the App, you must create an account using a valid email address and password, or \
                        through Apple Sign In. You are responsible for:

                        \u{2022} Maintaining the confidentiality of your account credentials
                        \u{2022} All activities that occur under your account
                        \u{2022} Providing accurate and complete registration information
                        \u{2022} Notifying us immediately of any unauthorized use of your account

                        You must be at least 18 years of age or the age of legal majority in your jurisdiction to \
                        create an account. The App is designed for use by parents and guardians, not directly by \
                        children under 13.
                        """
                    )

                    PolicySection(
                        title: "4. Acceptable Use",
                        content: """
                        You agree to use the App only for lawful purposes and in accordance with these Terms. \
                        You agree not to:

                        \u{2022} Use the App in any way that violates applicable laws or regulations
                        \u{2022} Attempt to gain unauthorized access to our systems or other user accounts
                        \u{2022} Transmit any malicious code, viruses, or harmful content
                        \u{2022} Use the App to harass, abuse, or harm another person
                        \u{2022} Interfere with or disrupt the App's functionality or servers
                        \u{2022} Use automated systems or bots to access the App
                        \u{2022} Reverse engineer, decompile, or disassemble any part of the App
                        \u{2022} Use the AI features to generate inappropriate, harmful, or misleading content
                        \u{2022} Share your account credentials with others
                        """
                    )
                }

                Group {
                    PolicySection(
                        title: "5. AI-Generated Content",
                        content: """
                        The App uses artificial intelligence to generate educational content including flashcards, \
                        study summaries, and chat responses. Regarding AI-generated content:

                        \u{2022} AI content is provided for educational purposes only and may not always be accurate
                        \u{2022} We do not guarantee the correctness, completeness, or reliability of AI-generated content
                        \u{2022} AI responses should not be considered professional educational, medical, or legal advice
                        \u{2022} Parents and guardians should review AI-generated content for appropriateness
                        \u{2022} We continuously work to improve AI accuracy but cannot ensure error-free results

                        You acknowledge that AI-generated content is a supplementary learning tool and should be \
                        used alongside proper educational resources and professional guidance.
                        """
                    )

                    PolicySection(
                        title: "6. User Content",
                        content: """
                        You retain ownership of any content you submit through the App, including child profiles, \
                        homework entries, and chat messages ("User Content"). By submitting User Content, you grant \
                        us a limited, non-exclusive license to use, process, and store such content solely for the \
                        purpose of providing and improving the App's services.

                        You are solely responsible for the accuracy and legality of the User Content you provide. \
                        You represent that you have the right to submit all User Content and that it does not \
                        infringe upon any third party's rights.
                        """
                    )

                    PolicySection(
                        title: "7. Intellectual Property",
                        content: """
                        The App, including its design, features, code, graphics, and content (excluding User \
                        Content), is owned by SchoolMate AI and is protected by copyright, trademark, and other \
                        intellectual property laws.

                        We grant you a limited, non-exclusive, non-transferable, revocable license to use the \
                        App for personal, non-commercial purposes in accordance with these Terms. This license \
                        does not include the right to:

                        \u{2022} Modify or create derivative works based on the App
                        \u{2022} Use the App for any commercial purpose
                        \u{2022} Remove any proprietary notices from the App
                        \u{2022} Transfer or sublicense your rights to any third party
                        """
                    )

                    PolicySection(
                        title: "8. Subscriptions and Payments",
                        content: """
                        The App may offer premium features through subscription plans. If you purchase a subscription:

                        \u{2022} Payment will be charged to your Apple ID account at confirmation of purchase
                        \u{2022} Subscriptions automatically renew unless canceled at least 24 hours before the \
                        end of the current period
                        \u{2022} Your account will be charged for renewal within 24 hours prior to the end of \
                        the current period
                        \u{2022} You can manage and cancel subscriptions in your Apple ID account settings
                        \u{2022} No refunds will be provided for partial subscription periods

                        Free trial periods, if offered, will automatically convert to paid subscriptions unless \
                        canceled before the trial ends. Any unused portion of a free trial will be forfeited \
                        upon purchasing a subscription.
                        """
                    )
                }

                Group {
                    PolicySection(
                        title: "9. Disclaimer of Warranties",
                        content: """
                        THE APP IS PROVIDED ON AN "AS IS" AND "AS AVAILABLE" BASIS WITHOUT WARRANTIES OF ANY \
                        KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF \
                        MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.

                        We do not warrant that:
                        \u{2022} The App will be uninterrupted, timely, secure, or error-free
                        \u{2022} The results obtained from using the App will be accurate or reliable
                        \u{2022} Any errors in the App will be corrected
                        \u{2022} AI-generated content will be free from inaccuracies
                        """
                    )

                    PolicySection(
                        title: "10. Limitation of Liability",
                        content: """
                        TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, SCHOOLMATE AI SHALL NOT BE LIABLE FOR \
                        ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, INCLUDING BUT NOT \
                        LIMITED TO LOSS OF DATA, LOSS OF PROFITS, OR PERSONAL INJURY, ARISING OUT OF OR IN \
                        CONNECTION WITH YOUR USE OF THE APP.

                        OUR TOTAL LIABILITY FOR ALL CLAIMS ARISING OUT OF OR RELATING TO THESE TERMS OR THE APP \
                        SHALL NOT EXCEED THE AMOUNT YOU PAID US IN THE TWELVE (12) MONTHS PRECEDING THE CLAIM, \
                        OR ONE HUNDRED DOLLARS ($100), WHICHEVER IS GREATER.
                        """
                    )

                    PolicySection(
                        title: "11. Indemnification",
                        content: """
                        You agree to indemnify, defend, and hold harmless SchoolMate AI and its officers, \
                        directors, employees, and agents from and against any claims, damages, losses, \
                        liabilities, and expenses (including reasonable attorneys' fees) arising out of or \
                        related to:

                        \u{2022} Your use of the App
                        \u{2022} Your violation of these Terms
                        \u{2022} Your violation of any rights of a third party
                        \u{2022} Any User Content you submit through the App
                        """
                    )

                    PolicySection(
                        title: "12. Termination",
                        content: """
                        We may terminate or suspend your account and access to the App at any time, without prior \
                        notice or liability, for any reason, including if you breach these Terms.

                        Upon termination:
                        \u{2022} Your right to use the App will immediately cease
                        \u{2022} We may delete your account data in accordance with our Privacy Policy
                        \u{2022} Any provisions of these Terms that by their nature should survive termination \
                        shall survive, including ownership provisions, warranty disclaimers, indemnity, and \
                        limitations of liability

                        You may terminate your account at any time by contacting us at support@schoolmateai.com.
                        """
                    )
                }

                Group {
                    PolicySection(
                        title: "13. Governing Law",
                        content: """
                        These Terms shall be governed by and construed in accordance with the laws of the \
                        United States, without regard to its conflict of law provisions. Any disputes arising \
                        under these Terms shall be resolved in the courts located within the jurisdiction of \
                        our principal place of business.
                        """
                    )

                    PolicySection(
                        title: "14. Changes to Terms",
                        content: """
                        We reserve the right to modify these Terms at any time. We will provide notice of \
                        significant changes by updating the "Last updated" date and, where appropriate, \
                        providing additional notice through the App.

                        Your continued use of the App after any changes to these Terms constitutes your \
                        acceptance of the revised Terms. If you do not agree to the updated Terms, you must \
                        stop using the App.
                        """
                    )

                    PolicySection(
                        title: "15. Severability",
                        content: """
                        If any provision of these Terms is found to be unenforceable or invalid, that provision \
                        shall be limited or eliminated to the minimum extent necessary so that the remaining \
                        provisions of these Terms shall remain in full force and effect.
                        """
                    )

                    PolicySection(
                        title: "16. Contact Us",
                        content: """
                        If you have any questions about these Terms of Service, please contact us at:

                        SchoolMate AI
                        Email: support@schoolmateai.com
                        """
                    )
                }
            }
            .padding(AppSpacing.md)
        }
        .background(Color.backgroundGray)
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}
