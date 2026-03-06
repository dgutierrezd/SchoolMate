import Foundation

@MainActor
class ChildrenViewModel: ObservableObject {
    @Published var children: [Child] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = ChildrenService.shared

    func loadChildren() async {
        isLoading = true
        do {
            children = try await service.fetchChildren()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func addChild(name: String, grade: String, school: String?, avatarColor: String, avatarEmoji: String) async {
        isLoading = true
        do {
            let request = CreateChildRequest(
                name: name,
                grade: grade,
                school: school,
                avatarColor: avatarColor,
                avatarEmoji: avatarEmoji
            )
            let child = try await service.addChild(request)
            children.append(child)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func deleteChild(id: String) async {
        do {
            try await service.deleteChild(id: id)
            children.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func regenerateAIContext(childId: String) async {
        do {
            let context = try await service.regenerateAIContext(childId: childId)
            if let index = children.firstIndex(where: { $0.id == childId }) {
                children[index].aiContext = context
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
