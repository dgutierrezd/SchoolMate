import Foundation

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var children: [Child] = []
    @Published var selectedChild: Child?
    @Published var todayHomework: [Homework] = []
    @Published var overdueHomework: [Homework] = []
    @Published var upcomingHomework: [Homework] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let childrenService = ChildrenService.shared
    private let homeworkService = HomeworkService.shared

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "good_morning".localized
        case 12..<18:
            return "good_afternoon".localized
        default:
            return "good_evening".localized
        }
    }

    var completedThisWeek: Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return todayHomework.filter {
            $0.status == .completed && $0.updatedAt >= startOfWeek
        }.count
    }

    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            children = try await childrenService.fetchChildren()
            if selectedChild == nil {
                selectedChild = children.first
            }
            if let child = selectedChild {
                await loadHomework(for: child.id)
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func loadHomework(for childId: String) async {
        do {
            let allHomework = try await homeworkService.fetchHomework(childId: childId)
            let now = Date()
            let endOfToday = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: now)!)

            todayHomework = allHomework.filter {
                $0.status != .completed && Calendar.current.isDateInToday($0.dueDate)
            }
            overdueHomework = allHomework.filter {
                $0.status != .completed && $0.dueDate < now && !Calendar.current.isDateInToday($0.dueDate)
            }
            upcomingHomework = allHomework.filter {
                $0.status != .completed && $0.dueDate >= endOfToday
            }.prefix(5).map { $0 }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func selectChild(_ child: Child) async {
        selectedChild = child
        await loadHomework(for: child.id)
    }
}
