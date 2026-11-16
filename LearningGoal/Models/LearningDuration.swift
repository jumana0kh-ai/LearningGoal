


import Foundation

enum LearningDuration: String, CaseIterable, Identifiable, Codable {
    case week = "Week"
    case month = "Month"
    case year = "Year"

    var id: String { rawValue }
}
