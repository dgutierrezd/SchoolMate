import SwiftUI

@main
struct SchoolMateAIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authViewModel = AuthViewModel()
    @AppStorage("selectedLanguage") private var selectedLanguage = "en"

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
                .environment(\.locale, Locale(identifier: selectedLanguage))
                .preferredColorScheme(.light)
                .id(selectedLanguage)
        }
    }
}

enum Config {
    #if DEBUG
    static let apiBaseURL = "http://192.168.40.5:3000"
    #else
    static let apiBaseURL = "https://schoolmate-production.up.railway.app"
    #endif
    static let supabaseURL = "https://jytfvfikzfvrzpqriczs.supabase.co"
    static let supabaseAnonKey = "sb_publishable_lN1Txez0HFGXPb9Rkfheeg_i-VIIlz6"
}
