import Foundation

class ChildrenService {
    static let shared = ChildrenService()
    private let api = APIClient.shared

    private init() {}

    func fetchChildren() async throws -> [Child] {
        try await api.request(path: "/children")
    }

    func addChild(_ request: CreateChildRequest) async throws -> Child {
        try await api.request(path: "/children", method: "POST", body: request)
    }

    func updateChild(id: String, request: CreateChildRequest) async throws -> Child {
        try await api.request(path: "/children/\(id)", method: "PUT", body: request)
    }

    func deleteChild(id: String) async throws {
        try await api.requestVoid(path: "/children/\(id)", method: "DELETE")
    }

    func regenerateAIContext(childId: String) async throws -> String {
        struct AIContextResponse: Codable {
            let aiContext: String
            enum CodingKeys: String, CodingKey {
                case aiContext = "ai_context"
            }
        }
        let response: AIContextResponse = try await api.request(
            path: "/children/\(childId)/ai-context",
            method: "POST"
        )
        return response.aiContext
    }
}
