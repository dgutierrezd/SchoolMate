import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showSplash = true

    var body: some View {
        ZStack {
            Group {
                if authViewModel.isCheckingSession {
                    // Show nothing behind the splash while we validate
                    Color.clear
                } else if authViewModel.isAuthenticated {
                    TabBarView()
                        .transition(.opacity)
                } else {
                    LoginView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: authViewModel.isAuthenticated)

            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .task {
            // Validate stored session while splash is visible
            await authViewModel.checkSession()

            // Keep splash for at least 1.5s for branding, then dismiss
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            withAnimation(.easeOut(duration: 0.5)) {
                showSplash = false
            }
        }
    }
}
