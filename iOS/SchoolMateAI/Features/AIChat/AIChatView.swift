import SwiftUI

struct AIChatView: View {
    var preselectedChild: Child? = nil
    @StateObject private var viewModel = AIChatViewModel()
    @StateObject private var childrenVM = ChildrenViewModel()
    @StateObject private var consentManager = AIConsentManager.shared
    @State private var selectedChild: Child?
    @State private var messageText = ""
    @State private var showVoiceInput = false
    @State private var showAIConsent = false

    private var suggestedQuestions: [String] {
        guard let child = selectedChild else { return [] }
        return [
            "suggested_how_doing".localized(child.name),
            "suggested_study_tips".localized(child.name),
        ]
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Child selector
                if !childrenVM.children.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppSpacing.sm) {
                            ForEach(childrenVM.children) { child in
                                Button {
                                    selectedChild = child
                                    Task { await viewModel.loadHistory(childId: child.id) }
                                } label: {
                                    HStack(spacing: 6) {
                                        Text(child.avatarEmoji)
                                        Text(child.name)
                                            .font(.appCaption)
                                            .fontWeight(.medium)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedChild?.id == child.id
                                            ? Color.primaryPurple
                                            : Color.backgroundGray
                                    )
                                    .foregroundStyle(
                                        selectedChild?.id == child.id ? .white : .primary
                                    )
                                    .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.sm)
                    }
                    .background(Color.cardBackground)
                }

                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        if viewModel.isLoadingHistory {
                            ChatSkeleton()
                        }

                        LazyVStack(spacing: AppSpacing.md) {
                            // Suggested questions when empty
                            if viewModel.messages.isEmpty && !viewModel.isLoadingHistory {
                                VStack(spacing: AppSpacing.md) {
                                    Image(systemName: "brain")
                                        .font(.system(size: 48))
                                        .foregroundStyle(Color.primaryPurple.opacity(0.5))
                                    Text("Ask me anything about your child's studies!")
                                        .font(.appBody)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.center)

                                    ForEach(suggestedQuestions, id: \.self) { question in
                                        Button {
                                            messageText = question
                                        } label: {
                                            Text(question)
                                                .font(.appCaption)
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 8)
                                                .background(Color.softLavender)
                                                .foregroundStyle(Color.primaryPurple)
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                                .padding(.top, AppSpacing.xxl)
                            }

                            ForEach(viewModel.messages) { message in
                                MessageBubbleView(message: message)
                                    .id(message.id)
                            }

                            // Streaming message
                            if viewModel.isStreaming && !viewModel.streamingText.isEmpty {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(viewModel.streamingText)
                                            .font(.appBody)
                                            .foregroundStyle(.primary)
                                    }
                                    .padding(12)
                                    .background(Color.backgroundGray)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    Spacer(minLength: 60)
                                }
                                .padding(.horizontal, AppSpacing.md)
                                .id("streaming")
                            }
                        }
                        .padding(.vertical, AppSpacing.md)
                    }
                    .onChange(of: viewModel.messages.count) {
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: viewModel.streamingText) {
                        withAnimation {
                            proxy.scrollTo("streaming", anchor: .bottom)
                        }
                    }
                }

                // Input bar
                if selectedChild != nil {
                    if consentManager.hasGrantedConsent {
                        HStack(spacing: AppSpacing.sm) {
                            Button {
                                showVoiceInput = true
                            } label: {
                                Image(systemName: "mic.fill")
                                    .foregroundStyle(Color.primaryPurple)
                            }

                            TextField(
                                "ai_chat_placeholder".localized,
                                text: $messageText,
                                axis: .vertical
                            )
                            .lineLimit(1...4)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.backgroundGray)
                            .clipShape(RoundedRectangle(cornerRadius: 20))

                            Button {
                                guard let child = selectedChild, !messageText.isEmpty else { return }
                                let text = messageText
                                messageText = ""
                                Task {
                                    await viewModel.sendMessage(text, childId: child.id)
                                }
                            } label: {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(
                                        messageText.isEmpty || viewModel.isStreaming
                                            ? Color.primaryPurple.opacity(0.3)
                                            : Color.primaryPurple
                                    )
                            }
                            .disabled(messageText.isEmpty || viewModel.isStreaming)
                        }
                        .padding(AppSpacing.md)
                        .background(Color.cardBackground)
                    } else {
                        // Consent not yet granted — prompt the user before any data is sent
                        Button {
                            showAIConsent = true
                        } label: {
                            HStack(spacing: AppSpacing.sm) {
                                Image(systemName: "hand.raised.fill")
                                Text("ai_consent_required_cta".localized)
                                    .font(.appBody)
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(AppSpacing.md)
                            .background(Color.primaryPurple)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                        }
                        .padding(AppSpacing.md)
                        .background(Color.cardBackground)
                    }
                } else if !childrenVM.isLoading {
                    VStack(spacing: AppSpacing.sm) {
                        Text("Add a child first to start chatting with AI")
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(AppSpacing.md)
                    .background(Color.cardBackground)
                }
            }
            .background(Color.backgroundGray)
            .navigationTitle(LocalizedStringKey("ask_ai"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            if let child = selectedChild {
                                Task { await viewModel.clearHistory(childId: child.id) }
                            }
                        } label: {
                            Label(
                                "new_conversation".localized,
                                systemImage: "plus.message"
                            )
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showVoiceInput) {
                VoiceInputView { transcribedText in
                    messageText = transcribedText
                }
            }
            .sheet(isPresented: $showAIConsent) {
                AIDataConsentView { granted in
                    showAIConsent = false
                    // If consent was just granted, load history for the selected child
                    if granted, let child = selectedChild {
                        Task { await viewModel.loadHistory(childId: child.id) }
                    }
                }
            }
            .task {
                if let preselected = preselectedChild {
                    selectedChild = preselected
                    childrenVM.children = [preselected]
                    // Only load AI history once user has consented
                    if consentManager.hasGrantedConsent {
                        await viewModel.loadHistory(childId: preselected.id)
                    } else {
                        showAIConsent = true
                    }
                } else {
                    await childrenVM.loadChildren()
                    selectedChild = childrenVM.children.first
                    if let child = selectedChild {
                        if consentManager.hasGrantedConsent {
                            await viewModel.loadHistory(childId: child.id)
                        } else {
                            showAIConsent = true
                        }
                    }
                }
            }
        }
    }
}
