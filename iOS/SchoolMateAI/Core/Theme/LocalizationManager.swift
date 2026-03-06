import SwiftUI

extension Bundle {
    static var localizedBundle: Bundle {
        let language = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return Bundle.main
        }
        return bundle
    }
}

extension String {
    var localized: String {
        NSLocalizedString(self, bundle: .localizedBundle, comment: "")
    }

    func localized(_ args: CVarArg...) -> String {
        String(format: self.localized, arguments: args)
    }
}
