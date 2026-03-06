import SwiftUI

struct LanguageSettingsView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage = "en"

    private let languages = [
        ("en", "English", "🇺🇸"),
        ("es", "Español", "🇪🇸"),
    ]

    var body: some View {
        List {
            ForEach(languages, id: \.0) { code, name, flag in
                Button {
                    selectedLanguage = code
                    UserDefaults.standard.set([code], forKey: "AppleLanguages")
                } label: {
                    HStack(spacing: AppSpacing.md) {
                        Text(flag)
                            .font(.title2)
                        Text(name)
                            .font(.appBody)
                            .foregroundStyle(.primary)
                        Spacer()
                        if selectedLanguage == code {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.primaryPurple)
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.backgroundGray)
        .navigationTitle(LocalizedStringKey("language"))
    }
}
