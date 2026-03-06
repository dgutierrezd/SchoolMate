import EventKit

class CalendarService {
    static let shared = CalendarService()
    private let eventStore = EKEventStore()

    private init() {}

    func requestAccess() async -> Bool {
        if #available(iOS 17.0, *) {
            do {
                return try await eventStore.requestFullAccessToEvents()
            } catch {
                return false
            }
        } else {
            return await withCheckedContinuation { continuation in
                eventStore.requestAccess(to: .event) { granted, _ in
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    func addHomeworkToCalendar(
        title: String,
        description: String?,
        dueDate: Date,
        priority: String
    ) async -> Bool {
        let granted = await requestAccess()
        guard granted else { return false }

        let event = EKEvent(eventStore: eventStore)
        event.title = "📚 \(title)"
        if let description, !description.isEmpty {
            event.notes = description
        }
        event.startDate = dueDate
        event.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: dueDate) ?? dueDate
        event.calendar = eventStore.defaultCalendarForNewEvents

        // Add a reminder alarm based on priority
        let alarmOffset: TimeInterval
        switch priority {
        case "high":
            alarmOffset = -3600      // 1 hour before
        case "medium":
            alarmOffset = -7200      // 2 hours before
        default:
            alarmOffset = -86400     // 1 day before
        }
        event.addAlarm(EKAlarm(relativeOffset: alarmOffset))

        do {
            try eventStore.save(event, span: .thisEvent)
            return true
        } catch {
            return false
        }
    }

    func removeHomeworkFromCalendar(title: String, dueDate: Date) {
        let startDate = Calendar.current.date(byAdding: .hour, value: -1, to: dueDate) ?? dueDate
        let endDate = Calendar.current.date(byAdding: .hour, value: 2, to: dueDate) ?? dueDate
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let events = eventStore.events(matching: predicate)

        for event in events where event.title == "📚 \(title)" {
            try? eventStore.remove(event, span: .thisEvent)
        }
    }
}
