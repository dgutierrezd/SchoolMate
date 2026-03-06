import SwiftUI

struct TabBarView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label(
                        "dashboard".localized,
                        systemImage: "house.fill"
                    )
                }
                .tag(0)

            HomeworkListView()
                .tabItem {
                    Label(
                        "homework".localized,
                        systemImage: "list.clipboard.fill"
                    )
                }
                .tag(1)

            FlashcardDeckView()
                .tabItem {
                    Label(
                        "flashcard_decks".localized,
                        systemImage: "rectangle.stack.fill"
                    )
                }
                .tag(2)

            AIChatView()
                .tabItem {
                    Label(
                        "ask_ai".localized,
                        systemImage: "brain"
                    )
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label(
                        "settings".localized,
                        systemImage: "gearshape.fill"
                    )
                }
                .tag(4)
        }
        .tint(Color.primaryPurple)
    }
}
