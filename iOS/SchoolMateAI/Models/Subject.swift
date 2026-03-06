import Foundation
import SwiftUI

struct Subject: Codable, Identifiable, Hashable {
    let id: String
    let childId: String
    var name: String
    var teacherName: String?
    var color: String
    var icon: String
    var notes: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case childId = "child_id"
        case name
        case teacherName = "teacher_name"
        case color, icon, notes
        case createdAt = "created_at"
    }

    var swiftUIColor: Color {
        Color(hex: color)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Subject, rhs: Subject) -> Bool {
        lhs.id == rhs.id
    }
}

struct CreateSubjectRequest: Codable {
    let childId: String
    let name: String
    var teacherName: String?
    var color: String?
    var icon: String?
    var notes: String?

    enum CodingKeys: String, CodingKey {
        case childId = "child_id"
        case name
        case teacherName = "teacher_name"
        case color, icon, notes
    }
}
