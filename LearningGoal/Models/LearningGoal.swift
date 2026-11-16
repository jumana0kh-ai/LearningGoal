

import Foundation

struct LearningGoal: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var duration: LearningDuration
    var startDate: Date = Date()
}
