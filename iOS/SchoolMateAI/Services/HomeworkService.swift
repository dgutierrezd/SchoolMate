import Foundation

class HomeworkService {
    static let shared = HomeworkService()
    private let api = APIClient.shared

    private init() {}

    func fetchHomework(childId: String, status: String? = nil) async throws -> [Homework] {
        var queryItems = [URLQueryItem(name: "childId", value: childId)]
        if let status {
            queryItems.append(URLQueryItem(name: "status", value: status))
        }
        return try await api.request(path: "/homework", queryItems: queryItems)
    }

    func createHomework(_ request: CreateHomeworkRequest) async throws -> Homework {
        try await api.request(path: "/homework", method: "POST", body: request)
    }

    func updateHomework(id: String, updates: [String: Any]) async throws -> Homework {
        // Encode updates manually since [String: Any] isn't Codable
        struct DynamicCodable: Encodable {
            let data: [String: Any]

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: DynamicKey.self)
                for (key, value) in data {
                    let codingKey = DynamicKey(stringValue: key)!
                    if let stringValue = value as? String {
                        try container.encode(stringValue, forKey: codingKey)
                    } else if let intValue = value as? Int {
                        try container.encode(intValue, forKey: codingKey)
                    } else if let boolValue = value as? Bool {
                        try container.encode(boolValue, forKey: codingKey)
                    }
                }
            }
        }

        return try await api.request(
            path: "/homework/\(id)",
            method: "PUT",
            body: DynamicCodable(data: updates)
        )
    }

    func deleteHomework(id: String) async throws {
        try await api.requestVoid(path: "/homework/\(id)", method: "DELETE")
    }

    func markComplete(id: String) async throws -> Homework {
        try await api.request(path: "/homework/\(id)/complete", method: "PATCH")
    }
}

struct DynamicKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}
