import { Router, Request, Response } from "express";

const router = Router();

const PAGE_STYLE = `
  body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; color: #2C3E50; line-height: 1.6; }
  h1 { color: #4A6FA5; }
  h2 { color: #2C3E50; margin-top: 24px; }
  .date { color: #888; font-size: 14px; }
  ul { padding-left: 20px; }
`;

router.get("/privacy", (_req: Request, res: Response) => {
  res.type("html").send(`<!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Privacy Policy - SchoolMate AI</title><style>${PAGE_STYLE}</style></head><body>
<h1>Privacy Policy</h1>
<p class="date">Last updated: March 6, 2026</p>

<h2>1. Introduction</h2>
<p>Welcome to SchoolMate AI ("we," "our," or "us"). We are committed to protecting the privacy of our users, especially the children whose educational data is managed through our app. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application SchoolMate AI (the "App").</p>
<p>By using the App, you agree to the collection and use of information in accordance with this policy. If you do not agree with the terms of this Privacy Policy, please do not access the App.</p>

<h2>2. Information We Collect</h2>
<p>We collect the following types of information:</p>
<p><strong>Account Information:</strong> When you create an account, we collect your name, email address, and authentication credentials. If you sign in with Apple, we receive your Apple ID token and, optionally, your name and email.</p>
<p><strong>Child Information:</strong> You may provide your child's name, grade level, school name, and avatar preferences. This information is used solely to personalize the educational experience.</p>
<p><strong>Educational Data:</strong> Homework assignments, subjects, flashcard decks, study progress, and AI chat interactions related to your child's education.</p>
<p><strong>Device Information:</strong> We may collect device type, operating system version, and unique device identifiers for app functionality and troubleshooting purposes.</p>
<p><strong>Usage Data:</strong> We collect information about how you interact with the App, including features used, session duration, and navigation patterns, to improve the user experience.</p>

<h2>3. How We Use Your Information</h2>
<p>We use the information we collect to:</p>
<ul>
<li>Provide, maintain, and improve the App's features and functionality</li>
<li>Personalize the educational experience for each child</li>
<li>Generate AI-powered study content, summaries, and recommendations</li>
<li>Send homework reminders and notifications you have opted into</li>
<li>Respond to your comments, questions, and support requests</li>
<li>Monitor and analyze usage patterns to improve the App</li>
<li>Detect, prevent, and address technical issues or security threats</li>
</ul>

<h2>4. Children's Privacy (COPPA Compliance)</h2>
<p>SchoolMate AI is designed for parents and guardians to manage their children's educational data. We do not knowingly collect personal information directly from children under the age of 13 without parental consent.</p>
<p>All child-related data is entered and managed by the parent or guardian account holder. Parents have full control over their children's data and can view, modify, or delete it at any time through the App.</p>
<p>If we learn that we have collected personal information from a child under 13 without verification of parental consent, we will delete that information as quickly as possible. If you believe we might have any information from or about a child under 13, please contact us at privacy@schoolmateai.com.</p>

<h2>5. Data Sharing and Disclosure</h2>
<p>We do not sell, trade, or rent your personal information to third parties. We may share your information only in the following circumstances:</p>
<p><strong>Service Providers:</strong> We use trusted third-party services (such as Supabase for data storage and authentication) that process data on our behalf under strict confidentiality agreements.</p>
<p><strong>AI Processing:</strong> Educational content and chat messages may be processed by AI services to generate study materials and responses. This data is not used to train AI models and is processed in accordance with our data processing agreements.</p>
<p><strong>Legal Requirements:</strong> We may disclose your information if required by law, court order, or governmental regulation, or if we believe disclosure is necessary to protect our rights, your safety, or the safety of others.</p>

<h2>6. Data Storage and Security</h2>
<p>Your data is stored securely using industry-standard encryption and security measures. We use Supabase, which provides enterprise-grade security including:</p>
<ul>
<li>Encryption in transit (TLS/SSL) and at rest (AES-256)</li>
<li>Row-level security policies to ensure data isolation</li>
<li>Regular security audits and compliance monitoring</li>
<li>Secure authentication with token-based access control</li>
</ul>
<p>While we implement commercially reasonable security measures, no method of electronic storage or transmission over the Internet is 100% secure. We cannot guarantee absolute security of your data.</p>

<h2>7. Data Retention</h2>
<p>We retain your personal information for as long as your account is active or as needed to provide you services. You may request deletion of your account and associated data at any time by contacting us at privacy@schoolmateai.com.</p>
<p>Upon account deletion, we will remove your personal data within 30 days, except where retention is required by law or for legitimate business purposes such as resolving disputes or enforcing our agreements.</p>

<h2>8. Your Rights</h2>
<p>Depending on your location, you may have the following rights regarding your personal data:</p>
<ul>
<li>Access: Request a copy of the personal data we hold about you</li>
<li>Correction: Request correction of inaccurate or incomplete data</li>
<li>Deletion: Request deletion of your personal data</li>
<li>Portability: Request a machine-readable copy of your data</li>
<li>Restriction: Request restriction of processing of your data</li>
<li>Objection: Object to processing of your data for certain purposes</li>
</ul>
<p>To exercise any of these rights, please contact us at privacy@schoolmateai.com.</p>

<h2>9. Third-Party Services</h2>
<p>The App may contain links to third-party websites or services that are not operated by us. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services. We encourage you to review the privacy policies of any third-party services you access.</p>

<h2>10. Changes to This Privacy Policy</h2>
<p>We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date. You are advised to review this Privacy Policy periodically for any changes.</p>
<p>Continued use of the App after any modifications to the Privacy Policy constitutes your acknowledgment of the modifications and your consent to abide by the updated policy.</p>

<h2>11. Contact Us</h2>
<p>If you have any questions or concerns about this Privacy Policy or our data practices, please contact us at:</p>
<p>SchoolMate AI<br>Email: privacy@schoolmateai.com</p>
</body></html>`);
});

router.get("/terms", (_req: Request, res: Response) => {
  res.type("html").send(`<!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Terms of Service - SchoolMate AI</title><style>${PAGE_STYLE}</style></head><body>
<h1>Terms of Service</h1>
<p class="date">Last updated: March 6, 2026</p>

<h2>1. Acceptance of Terms</h2>
<p>By downloading, installing, or using SchoolMate AI (the "App"), you agree to be bound by these Terms of Service ("Terms"). If you do not agree to these Terms, do not use the App.</p>
<p>These Terms constitute a legally binding agreement between you and SchoolMate AI ("we," "our," or "us"). Please read them carefully before using the App.</p>

<h2>2. Description of Service</h2>
<p>SchoolMate AI is an educational management application designed for parents and guardians to:</p>
<ul>
<li>Track and manage their children's homework assignments</li>
<li>Organize subjects and academic information</li>
<li>Create and study AI-generated flashcard decks</li>
<li>Interact with an AI assistant for educational support</li>
<li>Receive reminders and notifications about upcoming assignments</li>
<li>Sync homework due dates with device calendars</li>
</ul>
<p>The App is intended as a supplementary educational tool and does not replace professional educational guidance or instruction.</p>

<h2>3. User Accounts</h2>
<p>To use the App, you must create an account using a valid email address and password, or through Apple Sign In. You are responsible for:</p>
<ul>
<li>Maintaining the confidentiality of your account credentials</li>
<li>All activities that occur under your account</li>
<li>Providing accurate and complete registration information</li>
<li>Notifying us immediately of any unauthorized use of your account</li>
</ul>
<p>You must be at least 18 years of age or the age of legal majority in your jurisdiction to create an account. The App is designed for use by parents and guardians, not directly by children under 13.</p>

<h2>4. Acceptable Use</h2>
<p>You agree to use the App only for lawful purposes and in accordance with these Terms. You agree not to:</p>
<ul>
<li>Use the App in any way that violates applicable laws or regulations</li>
<li>Attempt to gain unauthorized access to our systems or other user accounts</li>
<li>Transmit any malicious code, viruses, or harmful content</li>
<li>Use the App to harass, abuse, or harm another person</li>
<li>Interfere with or disrupt the App's functionality or servers</li>
<li>Use automated systems or bots to access the App</li>
<li>Reverse engineer, decompile, or disassemble any part of the App</li>
<li>Use the AI features to generate inappropriate, harmful, or misleading content</li>
<li>Share your account credentials with others</li>
</ul>

<h2>5. AI-Generated Content</h2>
<p>The App uses artificial intelligence to generate educational content including flashcards, study summaries, and chat responses. Regarding AI-generated content:</p>
<ul>
<li>AI content is provided for educational purposes only and may not always be accurate</li>
<li>We do not guarantee the correctness, completeness, or reliability of AI-generated content</li>
<li>AI responses should not be considered professional educational, medical, or legal advice</li>
<li>Parents and guardians should review AI-generated content for appropriateness</li>
<li>We continuously work to improve AI accuracy but cannot ensure error-free results</li>
</ul>
<p>You acknowledge that AI-generated content is a supplementary learning tool and should be used alongside proper educational resources and professional guidance.</p>

<h2>6. User Content</h2>
<p>You retain ownership of any content you submit through the App, including child profiles, homework entries, and chat messages ("User Content"). By submitting User Content, you grant us a limited, non-exclusive license to use, process, and store such content solely for the purpose of providing and improving the App's services.</p>
<p>You are solely responsible for the accuracy and legality of the User Content you provide. You represent that you have the right to submit all User Content and that it does not infringe upon any third party's rights.</p>

<h2>7. Intellectual Property</h2>
<p>The App, including its design, features, code, graphics, and content (excluding User Content), is owned by SchoolMate AI and is protected by copyright, trademark, and other intellectual property laws.</p>
<p>We grant you a limited, non-exclusive, non-transferable, revocable license to use the App for personal, non-commercial purposes in accordance with these Terms.</p>

<h2>8. Subscriptions and Payments</h2>
<p>The App may offer premium features through subscription plans. If you purchase a subscription:</p>
<ul>
<li>Payment will be charged to your Apple ID account at confirmation of purchase</li>
<li>Subscriptions automatically renew unless canceled at least 24 hours before the end of the current period</li>
<li>Your account will be charged for renewal within 24 hours prior to the end of the current period</li>
<li>You can manage and cancel subscriptions in your Apple ID account settings</li>
<li>No refunds will be provided for partial subscription periods</li>
</ul>

<h2>9. Disclaimer of Warranties</h2>
<p>THE APP IS PROVIDED ON AN "AS IS" AND "AS AVAILABLE" BASIS WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.</p>

<h2>10. Limitation of Liability</h2>
<p>TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, SCHOOLMATE AI SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, INCLUDING BUT NOT LIMITED TO LOSS OF DATA, LOSS OF PROFITS, OR PERSONAL INJURY, ARISING OUT OF OR IN CONNECTION WITH YOUR USE OF THE APP.</p>

<h2>11. Indemnification</h2>
<p>You agree to indemnify, defend, and hold harmless SchoolMate AI and its officers, directors, employees, and agents from and against any claims, damages, losses, liabilities, and expenses arising out of or related to your use of the App, your violation of these Terms, or your violation of any rights of a third party.</p>

<h2>12. Termination</h2>
<p>We may terminate or suspend your account and access to the App at any time, without prior notice or liability, for any reason, including if you breach these Terms. You may terminate your account at any time by contacting us at support@schoolmateai.com.</p>

<h2>13. Governing Law</h2>
<p>These Terms shall be governed by and construed in accordance with the laws of the United States, without regard to its conflict of law provisions.</p>

<h2>14. Changes to Terms</h2>
<p>We reserve the right to modify these Terms at any time. We will provide notice of significant changes by updating the "Last updated" date. Your continued use of the App after any changes constitutes your acceptance of the revised Terms.</p>

<h2>15. Severability</h2>
<p>If any provision of these Terms is found to be unenforceable or invalid, that provision shall be limited or eliminated to the minimum extent necessary so that the remaining provisions shall remain in full force and effect.</p>

<h2>16. Contact Us</h2>
<p>If you have any questions about these Terms of Service, please contact us at:</p>
<p>SchoolMate AI<br>Email: support@schoolmateai.com</p>
</body></html>`);
});

export default router;
