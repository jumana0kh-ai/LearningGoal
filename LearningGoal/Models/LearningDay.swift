

import Foundation

enum DayStatus: String, Codable {
    case learned
    case frozen
}

struct LearningDay: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date
    var status: DayStatus

    // Actual time the user logged or froze the day.
    var actionDate: Date?

    init(
        date: Date,
        status: DayStatus,
        actionDate: Date = Date()
    ) {
        self.date = date
        self.status = status
        self.actionDate = actionDate
    }
}
