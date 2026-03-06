import Foundation

@MainActor
class AIChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var streamingText = ""
    @Published var isStreaming = false
    @Published var isLoadingHistory = false
    @Published var errorMessage: String?

    private let aiService = AIService.shared
    private var currentChildId: String?

    func loadHistory(childId: String) async {
        currentChildId = childId
        isLoadingHistory = true
        do {
            messages = try await aiService.fetchChatHistory(childId: childId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoadingHistory = false
    }

    func sendMessage(_ text: String, childId: String, language: String = "en") async {
        currentChildId = childId
        isStreaming = true
        streamingText = ""
        errorMessage = nil

        // Add user message immediately
        let userMessage = ChatMessage(
            id: UUID().uuidString,
            childId: childId,
            parentId: "",
            role: .user,
            content: text,
            createdAt: Date()
        )
        messages.append(userMessage)

        do {
            let stream = aiService.sendMessage(
                childId: childId,
                message: text,
                language: language
            )

            for try await delta in stream {
                if let text = delta.delta {
                    streamingText += text
                }
                if delta.done == true {
                    break
                }
            }

            // Add assistant message
            let assistantMessage = ChatMessage(
                id: UUID().uuidString,
                childId: childId,
                parentId: "",
                role: .assistant,
                content: streamingText,
                createdAt: Date()
            )
            messages.append(assistantMessage)
            streamingText = ""
        } catch {
            errorMessage = error.localizedDescription
        }

        isStreaming = false
    }

    func clearHistory(childId: String) async {
        do {
            try await aiService.clearChatHistory(childId: childId)
            messages = []
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
