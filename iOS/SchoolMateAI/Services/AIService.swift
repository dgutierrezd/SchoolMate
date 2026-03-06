import Foundation

class AIService {
    static let shared = AIService()
    private let api = APIClient.shared

    private init() {}

    func sendMessage(
        childId: String,
        message: String,
        language: String = "en"
    ) -> AsyncThrowingStream<ChatStreamDelta, Error> {
        let body = SendMessageRequest(
            childId: childId,
            message: message,
            language: language
        )
        return api.streamRequest(path: "/ai/chat", body: body)
    }

    func fetchChatHistory(childId: String, limit: Int = 100) async throws -> [ChatMessage] {
        try await api.request(
            path: "/ai/chat/history/\(childId)",
            queryItems: [URLQueryItem(name: "limit", value: "\(limit)")]
        )
    }

    func clearChatHistory(childId: String) async throws {
        try await api.requestVoid(
            path: "/ai/chat/history/\(childId)",
            method: "DELETE"
        )
    }
}
