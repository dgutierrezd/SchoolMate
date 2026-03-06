import Foundation

@MainActor
class SubjectsViewModel: ObservableObject {
    @Published var subjects: [Subject] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api = APIClient.shared

    func loadSubjects(childId: String) async {
        isLoading = true
        do {
            subjects = try await api.request(
                path: "/subjects",
                queryItems: [URLQueryItem(name: "childId", value: childId)]
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func addSubject(childId: String, name: String, teacherName: String?, color: String, icon: String) async {
        do {
            let request = CreateSubjectRequest(
                childId: childId,
                name: name,
                teacherName: teacherName,
                color: color,
                icon: icon
            )
            let subject: Subject = try await api.request(
                path: "/subjects",
                method: "POST",
                body: request
            )
            subjects.append(subject)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteSubject(id: String) async {
        do {
            try await api.requestVoid(path: "/subjects/\(id)", method: "DELETE")
            subjects.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
