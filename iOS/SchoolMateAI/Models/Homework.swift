import Foundation

struct Homework: Codable, Identifiable {
    let id: String
    let childId: String
    var subjectId: String?
    var title: String
    var description: String?
    var dueDate: Date
    var status: HomeworkStatus
    var priority: HomeworkPriority
    var attachmentURL: String?
    var aiSummary: String?
    let createdAt: Date
    var updatedAt: Date
    var subjects: SubjectRef?

    enum CodingKeys: String, CodingKey {
        case id
        case childId = "child_id"
        case subjectId = "subject_id"
        case title, description
        case dueDate = "due_date"
        case status, priority
        case attachmentURL = "attachment_url"
        case aiSummary = "ai_summary"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case subjects
    }

    var isOverdue: Bool {
        status != .completed && dueDate < Date()
    }

    var isDueToday: Bool {
        Calendar.current.isDateInToday(dueDate)
    }
}

enum HomeworkStatus: String, Codable, CaseIterable {
    case pending
    case inProgress = "in_progress"
    case completed
    case overdue
}

enum HomeworkPriority: String, Codable, CaseIterable {
    case low
    case medium
    case high
}

struct SubjectRef: Codable {
    let name: String
    let color: String
    let icon: String
}

struct CreateHomeworkRequest: Codable {
    let childId: String
    var subjectId: String?
    let title: String
    var description: String?
    let dueDate: Date
    var priority: String?
    var attachmentURL: String?

    enum CodingKeys: String, CodingKey {
        case childId = "child_id"
        case subjectId = "subject_id"
        case title, description
        case dueDate = "due_date"
        case priority
        case attachmentURL = "attachment_url"
    }
}
