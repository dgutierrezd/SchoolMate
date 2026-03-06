import Foundation

@MainActor
class HomeworkViewModel: ObservableObject {
    @Published var homework: [Homework] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedFilter: HomeworkStatus?

    private let service = HomeworkService.shared

    var filteredHomework: [Homework] {
        guard let filter = selectedFilter else { return homework }
        return homework.filter { $0.status == filter }
    }

    var pendingCount: Int {
        homework.filter { $0.status == .pending || $0.status == .inProgress }.count
    }

    var completedCount: Int {
        homework.filter { $0.status == .completed }.count
    }

    func loadHomework(childId: String) async {
        isLoading = true
        do {
            homework = try await service.fetchHomework(childId: childId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func markComplete(id: String) async {
        do {
            let updated = try await service.markComplete(id: id)
            if let index = homework.firstIndex(where: { $0.id == id }) {
                homework[index] = updated
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteHomework(id: String) async {
        do {
            try await service.deleteHomework(id: id)
            homework.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createHomework(_ request: CreateHomeworkRequest) async {
        isLoading = true
        do {
            let created = try await service.createHomework(request)
            homework.append(created)
            homework.sort { $0.dueDate < $1.dueDate }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
