

import Foundation

enum LearningDuration: String, CaseIterable, Identifiable, Codable {
    case week = "Week"
    case month = "Month"
    case year = "Year"

    var id: String {
        rawValue
    }

    var allowedFreezes: Int {
        switch self {
        case .week:
            return 2
        case .month:
            return 8
        case .year:
            return 96
        }
    }
}
