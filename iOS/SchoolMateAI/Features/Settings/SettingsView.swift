import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage = "en"
    @State private var biometricEnabled = BiometricAuthManager.isBiometricEnabled

    var body: some View {
        NavigationStack {
            List {
                // Profile Section
                Section {
                    NavigationLink {
                        ProfileView()
                    } label: {
                        HStack(spacing: AppSpacing.md) {
                            ZStack {
                                Circle()
                                    .fill(Color.primaryPurple.opacity(0.2))
                                    .frame(width: 56, height: 56)
                                Image(systemName: "person.fill")
                                    .font(.title2)
                                    .foregroundStyle(Color.primaryPurple)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("profile".localized)
                                    .font(.appBody)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                Text("manage_profile".localized)
                                    .font(.appCaption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // Language
                Section {
                    NavigationLink {
                        LanguageSettingsView()
                    } label: {
                        Label(
                            "language".localized,
                            systemImage: "globe"
                        )
                    }
                }

                // Security
                if BiometricAuthManager.isBiometricAvailable {
                    Section {
                        Toggle(isOn: $biometricEnabled) {
                            Label(
                                BiometricAuthManager.biometricLabel,
                                systemImage: BiometricAuthManager.biometricIcon
                            )
                        }
                        .tint(Color.primaryPurple)
                        .onChange(of: biometricEnabled) { _, newValue in
                            BiometricAuthManager.isBiometricEnabled = newValue
                        }
                    }
                }

                // Children Management
                Section("Children") {
                    NavigationLink {
                        ChildrenListView()
                    } label: {
                        Label("Manage Children", systemImage: "person.2.fill")
                    }
                }

                // About
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                    NavigationLink {
                        TermsOfServiceView()
                    } label: {
                        Label("Terms of Service", systemImage: "doc.text.fill")
                    }
                }

                // Sign Out
                Section {
                    Button(role: .destructive) {
                        Task { await authViewModel.signOut() }
                    } label: {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                            Spacer()
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.backgroundGray)
            .navigationTitle("Settings")
        }
    }
}

struct ChildrenListView: View {
    @StateObject private var viewModel = ChildrenViewModel()
    @State private var showAddChild = false

    var body: some View {
        List {
            ForEach(viewModel.children) { child in
                NavigationLink(destination: ChildProfileView(child: child)) {
                    HStack(spacing: AppSpacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: child.avatarColor))
                                .frame(width: 40, height: 40)
                            Text(child.avatarEmoji)
                                .font(.title3)
                        }
                        VStack(alignment: .leading) {
                            Text(child.name)
                                .font(.appBody)
                                .fontWeight(.medium)
                            Text("\(child.grade) - \(child.school ?? "")")
                                .font(.appCaption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        Task { await viewModel.deleteChild(id: child.id) }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.backgroundGray)
        .navigationTitle("Children")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showAddChild = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddChild) {
            AddChildView()
        }
        .task {
            await viewModel.loadChildren()
        }
    }
}
